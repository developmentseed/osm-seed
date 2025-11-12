#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# OSM Replication Script with osmdbt and S3
# ============================================================================
# This script manages OSM replication using osmdbt tools:
# - Executes osmdbt-get-log and osmdbt-create-diff every minute
# - Uploads .osc.gz and state.txt files to S3 after integrity verification
#   * General state.txt (in root directory) - controls replication sequence
#   * Specific state.txt files (e.g., 870.state.txt for 870.osc.gz)
# - Uses local state.txt to control replication sequence
# - Recovers state.txt from S3 on restart
# - Sends Slack notifications for errors
# - Cleans up incomplete/orphaned files automatically
# - Allows restoration from S3 by copying state.txt and diffs
# ============================================================================

# ---- Configuration Variables ----
workingDirectory="${WORKING_DIRECTORY:-/mnt/data}"
tmpDirectory="${workingDirectory}/tmp"
runDirectory="${workingDirectory}/run"
changesDir="${workingDirectory}"
osmdbtConfig="/osmdbt-config.yaml"

# Replication variables
REPLICATION_SLOT="${REPLICATION_SLOT:-osm_repl}"
REPLICATION_PLUGIN="osm_logical"

# S3 Configuration
CLOUDPROVIDER="${CLOUDPROVIDER:-aws}"
AWS_S3_BUCKET="${AWS_S3_BUCKET:-}"
REPLICATION_FOLDER="${REPLICATION_FOLDER:-replication}"

# Slack Configuration
ENABLE_SLACK="${ENABLE_SEND_SLACK_MESSAGE:-false}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
slack_message_count=0
max_slack_messages_per_hour=10
slack_reset_time=$(date +%s)

# Timing
REPLICATION_INTERVAL=60  # seconds (1 minute)
INTEGRITY_CHECK_RETRIES=3
CLEANUP_INTERVAL=300  # seconds (5 minutes)

# Process tracking
processed_files_log="${workingDirectory}/processed_files.log"
osmdbt_pid_file="${runDirectory}/osmdbt.pid"

# ---- Directory Setup ----
mkdir -p "$workingDirectory" "$tmpDirectory" "$runDirectory"

# ---- osmdbt-config.yaml creation ----
cat <<EOF > "$osmdbtConfig"
database:
  host: ${POSTGRES_HOST:-localhost}
  port: ${POSTGRES_PORT:-5432}
  dbname: ${POSTGRES_DB:-osm}
  user: ${POSTGRES_USER:-osm}
  password: ${POSTGRES_PASSWORD}
  replication_slot: ${REPLICATION_SLOT}

log_dir: ${workingDirectory}
changes_dir: ${changesDir}
tmp_dir: ${tmpDirectory}
run_dir: ${runDirectory}
EOF

# ============================================================================
# Function: Initialize replication slot and environment
# ============================================================================
function ensure_replication_slot_exists() {
    export PGPASSWORD="${POSTGRES_PASSWORD}"
    
    local exists=$(psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -t -A -c \
        "SELECT count(*) FROM pg_replication_slots WHERE slot_name='$REPLICATION_SLOT';" 2>/dev/null | tr -d '[:space:]')
    
    if [ "$exists" = "1" ]; then
        echo "$(date +%F_%H:%M:%S): Replication slot '$REPLICATION_SLOT' already exists."
        return 0
    fi
    
    echo "$(date +%F_%H:%M:%S): Creating replication slot '$REPLICATION_SLOT' with plugin '$REPLICATION_PLUGIN'..."
    if psql -h "${POSTGRES_HOST}" -p "${POSTGRES_PORT}" \
        -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c \
        "SELECT * FROM pg_create_logical_replication_slot('$REPLICATION_SLOT', '$REPLICATION_PLUGIN');" >/dev/null 2>&1; then
        echo "$(date +%F_%H:%M:%S): Successfully created replication slot '$REPLICATION_SLOT'."
        return 0
    fi
    
    local error_msg="ERROR: Failed to create replication slot '$REPLICATION_SLOT'. The '$REPLICATION_PLUGIN' plugin may not be installed."
    echo "$error_msg"
    send_slack_message "🚨 ${ENVIROMENT:-production}: $error_msg"
    return 1
}

# ============================================================================
# Function: Recover/update state from S3 or local storage
# ============================================================================
function recover_state_file() {
    local state_file="${changesDir}/state.txt"
    
    # Check if state.txt exists locally
    if [ -f "$state_file" ]; then
        echo "$(date +%F_%H:%M:%S): Found local state.txt:"
        cat "$state_file"
        return 0
    fi
    
    echo "$(date +%F_%H:%M:%S): Local state.txt not found. Attempting to recover from S3..."
    
    if [ "$CLOUDPROVIDER" == "aws" ] && [ -n "$AWS_S3_BUCKET" ]; then
        local s3_state_path="${AWS_S3_BUCKET}/${REPLICATION_FOLDER}/state.txt"
        
        if aws s3 ls "$s3_state_path" >/dev/null 2>&1; then
            echo "$(date +%F_%H:%M:%S): Downloading state.txt from S3: $s3_state_path"
            if aws s3 cp "$s3_state_path" "$state_file"; then
                echo "$(date +%F_%H:%M:%S): Successfully recovered state.txt from S3:"
                cat "$state_file"
                send_slack_message "✅ ${ENVIROMENT:-production}: Recovered state.txt from S3. Continuing replication from last known sequence."
                return 0
            else
                echo "$(date +%F_%H:%M:%S): WARNING: Failed to download state.txt from S3"
            fi
        else
            echo "$(date +%F_%H:%M:%S): state.txt not found in S3. Starting fresh replication."
        fi
    fi
    
    echo "$(date +%F_%H:%M:%S): No state.txt found. Will start replication from beginning."
    return 0
}

# ============================================================================
# Function: Verify file integrity
# ============================================================================
function verify_file_integrity() {
    local file="$1"
    local file_type="$2"  # "osc" or "state"
    local retries=0
    
    while [ $retries -lt $INTEGRITY_CHECK_RETRIES ]; do
        if [ "$file_type" == "osc" ]; then
            # Verify .osc.gz file
            if [ ! -f "$file" ]; then
                echo "$(date +%F_%H:%M:%S): ERROR: File does not exist: $file"
                return 1
            fi
            
            # Check if file is complete (not truncated)
            if ! gzip -t "$file" 2>/dev/null; then
                echo "$(date +%F_%H:%M:%S): WARNING: gzip integrity check failed for $file (attempt $((retries + 1))/$INTEGRITY_CHECK_RETRIES)"
                retries=$((retries + 1))
                sleep 2
                continue
            fi
            
            # Check file size (should be > 0)
            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            if [ "$file_size" -eq 0 ]; then
                echo "$(date +%F_%H:%M:%S): WARNING: File is empty: $file"
                return 1
            fi
            
            echo "$(date +%F_%H:%M:%S): Integrity check passed for $file (size: $file_size bytes)"
            return 0
            
        elif [ "$file_type" == "state" ]; then
            # Verify state.txt file
            if [ ! -f "$file" ]; then
                echo "$(date +%F_%H:%M:%S): ERROR: state.txt does not exist: $file"
                return 1
            fi
            
            # Check if state.txt has required fields
            if ! grep -q "sequenceNumber=" "$file" 2>/dev/null; then
                echo "$(date +%F_%H:%M:%S): WARNING: state.txt missing sequenceNumber (attempt $((retries + 1))/$INTEGRITY_CHECK_RETRIES)"
                retries=$((retries + 1))
                sleep 1
                continue
            fi
            
            echo "$(date +%F_%H:%M:%S): Integrity check passed for state.txt"
            return 0
        fi
    done
    
    echo "$(date +%F_%H:%M:%S): ERROR: Integrity check failed after $INTEGRITY_CHECK_RETRIES attempts for $file"
    return 1
}

# ============================================================================
# Function: Upload files to S3 with integrity verification
# ============================================================================
function upload_file_to_s3() {
    local local_file="$1"
    local file_type="$2"  # "osc" or "state"
    
    if [ "$CLOUDPROVIDER" != "aws" ] || [ -z "$AWS_S3_BUCKET" ]; then
        echo "$(date +%F_%H:%M:%S): WARNING: S3 upload skipped (CLOUDPROVIDER=$CLOUDPROVIDER, AWS_S3_BUCKET not set)"
        return 0
    fi
    
    # Verify integrity before upload
    if ! verify_file_integrity "$local_file" "$file_type"; then
        local error_msg="🚨 ${ENVIROMENT:-production}: Integrity check failed for $local_file. File will not be uploaded."
        echo "$(date +%F_%H:%M:%S): $error_msg"
        send_slack_message "$error_msg"
        return 1
    fi
    
    # Determine S3 path
    local filename=$(basename "$local_file")
    local s3_path="${AWS_S3_BUCKET}/${REPLICATION_FOLDER}/${filename}"
    
    echo "$(date +%F_%H:%M:%S): Uploading $local_file to S3: $s3_path"
    
    if aws s3 cp "$local_file" "$s3_path" --acl public-read; then
        echo "$(date +%F_%H:%M:%S): Successfully uploaded $filename to S3"
        return 0
    else
        local error_msg="🚨 ${ENVIROMENT:-production}: Failed to upload $filename to S3"
        echo "$(date +%F_%H:%M:%S): $error_msg"
        send_slack_message "$error_msg"
        return 1
    fi
}

# ============================================================================
# Function: Upload all new replication files
# ============================================================================
function upload_replication_files() {
    local osc_file="$1"
    local general_state_file="${changesDir}/state.txt"
    
    # Extract base name from osc file (e.g., "870.osc.gz" -> "870")
    local osc_basename=$(basename "$osc_file" .osc.gz)
    local specific_state_file="${changesDir}/${osc_basename}.state.txt"
    
    local upload_success=true
    
    # Upload .osc.gz file
    if [ -f "$osc_file" ]; then
        if ! upload_file_to_s3 "$osc_file" "osc"; then
            upload_success=false
        fi
    else
        echo "$(date +%F_%H:%M:%S): WARNING: OSC file not found: $osc_file"
        upload_success=false
    fi
    
    # Upload specific state.txt (e.g., 870.state.txt for 870.osc.gz)
    if [ -f "$specific_state_file" ]; then
        echo "$(date +%F_%H:%M:%S): Found specific state file: $specific_state_file"
        if ! upload_file_to_s3 "$specific_state_file" "state"; then
            upload_success=false
        fi
    else
        echo "$(date +%F_%H:%M:%S): WARNING: Specific state.txt not found: $specific_state_file"
        # This is not necessarily a failure, as some setups may not generate specific state files
    fi
    
    # Upload general state.txt (always upload this one)
    if [ -f "$general_state_file" ]; then
        if ! upload_file_to_s3 "$general_state_file" "state"; then
            upload_success=false
        fi
    else
        echo "$(date +%F_%H:%M:%S): WARNING: General state.txt not found: $general_state_file"
        upload_success=false
    fi
    
    if [ "$upload_success" = true ]; then
        # Log successful processing
        echo "$(date +%F_%H:%M:%S): $osc_file: SUCCESS" >> "$processed_files_log"
        return 0
    else
        # Log failure
        echo "$(date +%F_%H:%M:%S): $osc_file: FAILURE" >> "$processed_files_log"
        return 1
    fi
}

# ============================================================================
# Function: Send Slack notifications
# ============================================================================
function send_slack_message() {
    if [ "$ENABLE_SLACK" != "true" ]; then
        return 0
    fi
    
    if [ -z "$SLACK_WEBHOOK_URL" ]; then
        echo "$(date +%F_%H:%M:%S): WARNING: SLACK_WEBHOOK_URL not set. Cannot send Slack message."
        return 1
    fi
    
    # Reset counter every hour
    local current_time=$(date +%s)
    if [ $((current_time - slack_reset_time)) -ge 3600 ]; then
        slack_message_count=0
        slack_reset_time=$current_time
    fi
    
    if [ "$slack_message_count" -ge "$max_slack_messages_per_hour" ]; then
        echo "$(date +%F_%H:%M:%S): Max Slack messages limit reached ($max_slack_messages_per_hour/hour). Message not sent."
        return 0
    fi
    
    local message="$1"
    local timestamp=$(date +%F_%H:%M:%S)
    local full_message="[OSM Replication] $timestamp - $message"
    
    # if curl -X POST -H 'Content-type: application/json' \
    #     --data "{\"text\": \"$full_message\"}" \
    #     "$SLACK_WEBHOOK_URL" >/dev/null 2>&1; then
    #     echo "$(date +%F_%H:%M:%S): Slack notification sent: $message"
    #     slack_message_count=$((slack_message_count + 1))
    #     return 0
    # else
    #     echo "$(date +%F_%H:%M:%S): WARNING: Failed to send Slack notification"
    #     return 1
    # fi
}

# ============================================================================
# Function: Clean up incomplete/orphaned files
# ============================================================================
function cleanup_orphaned_files() {
    echo "$(date +%F_%H:%M:%S): Cleaning up orphaned files..."
    
    local cleaned=0
    
    # Remove lock files
    find "$workingDirectory" -name "*.lock" -type f -mmin +10 -delete && cleaned=$((cleaned + 1))
    find "$runDirectory" -name "*.lock" -type f -mmin +10 -delete && cleaned=$((cleaned + 1))
    
    # Remove old log files (keep only recent ones)
    find "$workingDirectory" -name "*.log" -type f -mtime +7 -delete && cleaned=$((cleaned + 1))
    
    # Remove incomplete .osc.gz files (0 bytes or corrupted)
    while IFS= read -r -d '' file; do
        local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        if [ "$size" -eq 0 ] || ! gzip -t "$file" 2>/dev/null; then
            echo "$(date +%F_%H:%M:%S): Removing corrupted/incomplete file: $file"
            rm -f "$file"
            cleaned=$((cleaned + 1))
        fi
    done < <(find "$changesDir" -name "*.osc.gz" -type f -print0 2>/dev/null)
    
    # Remove orphaned specific state files (not matching any .osc.gz)
    # Note: We preserve the general state.txt file
    while IFS= read -r -d '' state_file; do
        local filename=$(basename "$state_file")
        # Skip the general state.txt file
        if [ "$filename" = "state.txt" ]; then
            continue
        fi
        
        # Extract base name (e.g., "870.state.txt" -> "870")
        local base=$(basename "$state_file" .state.txt)
        local osc_file="${changesDir}/${base}.osc.gz"
        
        if [ ! -f "$osc_file" ]; then
            echo "$(date +%F_%H:%M:%S): Removing orphaned specific state file: $state_file"
            rm -f "$state_file"
            cleaned=$((cleaned + 1))
        fi
    done < <(find "$changesDir" -name "*.state.txt" -type f -print0 2>/dev/null)
    
    if [ $cleaned -gt 0 ]; then
        echo "$(date +%F_%H:%M:%S): Cleaned up $cleaned orphaned/incomplete file(s)"
    else
        echo "$(date +%F_%H:%M:%S): No orphaned files found"
    fi
}

# ============================================================================
# Function: Verify sequence continuity
# ============================================================================
function verify_sequence_continuity() {
    local state_file="${changesDir}/state.txt"
    
    if [ ! -f "$state_file" ]; then
        echo "$(date +%F_%H:%M:%S): WARNING: state.txt not found for sequence verification"
        return 1
    fi
    
    local current_seq=$(grep "sequenceNumber=" "$state_file" | sed 's/.*sequenceNumber=\([0-9]*\).*/\1/')
    
    if [ -z "$current_seq" ]; then
        echo "$(date +%F_%H:%M:%S): ERROR: Could not extract sequence number from state.txt"
        return 1
    fi
    
    echo "$(date +%F_%H:%M:%S): Current sequence number: $current_seq"
    return 0
}

# ============================================================================
# Function: Execute osmdbt replication cycle
# ============================================================================
function execute_replication_cycle() {
    echo "$(date +%F_%H:%M:%S): Starting replication cycle..."
    
    # Clean up any existing lock files
    find "$workingDirectory" -name "replicate.lock" -delete
    find "$runDirectory" -name "*.lock" -delete
    
    # Execute osmdbt-get-log
    echo "$(date +%F_%H:%M:%S): Running osmdbt-get-log..."
    if ! /osmdbt/build/src/osmdbt-get-log -c "$osmdbtConfig" 2>&1 | tee -a "${workingDirectory}/osmdbt-get-log.log"; then
        local error_msg="🚨 ${ENVIROMENT:-production}: osmdbt-get-log failed"
        echo "$(date +%F_%H:%M:%S): $error_msg"
        send_slack_message "$error_msg"
        return 1
    fi
    
    # Execute osmdbt-create-diff
    echo "$(date +%F_%H:%M:%S): Running osmdbt-create-diff..."
    if ! /osmdbt/build/src/osmdbt-create-diff -c "$osmdbtConfig" 2>&1 | tee -a "${workingDirectory}/osmdbt-create-diff.log"; then
        local error_msg="🚨 ${ENVIROMENT:-production}: osmdbt-create-diff failed"
        echo "$(date +%F_%H:%M:%S): $error_msg"
        send_slack_message "$error_msg"
        return 1
    fi
    
    # Find the most recent .osc.gz file
    local latest_osc=$(find "$changesDir" -name "*.osc.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    
    if [ -n "$latest_osc" ] && [ -f "$latest_osc" ]; then
        echo "$(date +%F_%H:%M:%S): Found new OSC file: $latest_osc"
        
        # Check if already processed
        if grep -q "$latest_osc: SUCCESS" "$processed_files_log" 2>/dev/null; then
            echo "$(date +%F_%H:%M:%S): File already processed: $latest_osc"
            return 0
        fi
        
        # Upload files to S3
        if upload_replication_files "$latest_osc"; then
            echo "$(date +%F_%H:%M:%S): Replication cycle completed successfully"
            verify_sequence_continuity
            return 0
        else
            local error_msg="🚨 ${ENVIROMENT:-production}: Failed to upload replication files for $latest_osc"
            echo "$(date +%F_%H:%M:%S): $error_msg"
            send_slack_message "$error_msg"
            return 1
        fi
    else
        echo "$(date +%F_%H:%M:%S): No new OSC file generated in this cycle"
        return 0
    fi
}

# ============================================================================
# Function: Wait for PostgreSQL to be ready
# ============================================================================
function wait_for_postgresql() {
    echo "$(date +%F_%H:%M:%S): Waiting for PostgreSQL to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if pg_isready -h "${POSTGRES_HOST:-localhost}" -p "${POSTGRES_PORT:-5432}" >/dev/null 2>&1; then
            echo "$(date +%F_%H:%M:%S): PostgreSQL is ready."
            return 0
        fi
        attempt=$((attempt + 1))
        echo "$(date +%F_%H:%M:%S): PostgreSQL not ready yet, attempt $attempt/$max_attempts..."
        sleep 2
    done
    
    local error_msg="🚨 ${ENVIROMENT:-production}: PostgreSQL is not ready after $max_attempts attempts"
    echo "$(date +%F_%H:%M:%S): $error_msg"
    send_slack_message "$error_msg"
    return 1
}

# ============================================================================
# MAIN PROCESS
# ============================================================================
function main() {
    echo "============================================================================"
    echo "$(date +%F_%H:%M:%S): Starting OSM Replication Service"
    echo "============================================================================"
    echo "Working Directory: $workingDirectory"
    echo "Changes Directory: $changesDir"
    echo "Replication Slot: $REPLICATION_SLOT"
    echo "Replication Interval: ${REPLICATION_INTERVAL}s"
    echo "S3 Bucket: ${AWS_S3_BUCKET:-not configured}"
    echo "============================================================================"
    
    # Initialize processed files log
    touch "$processed_files_log"
    
    # Wait for PostgreSQL
    if ! wait_for_postgresql; then
        exit 1
    fi
    
    # Ensure replication slot exists
    if ! ensure_replication_slot_exists; then
        exit 1
    fi
    
    # Recover state from S3 or local storage
    recover_state_file
    
    # Initial cleanup
    cleanup_orphaned_files
    
    # Main replication loop
    local last_cleanup=$(date +%s)
    
    echo "$(date +%F_%H:%M:%S): Entering replication loop (interval: ${REPLICATION_INTERVAL}s)..."
    
    while true; do
        local cycle_start=$(date +%s)
        
        # Execute replication cycle
        execute_replication_cycle
        
        # Periodic cleanup (every CLEANUP_INTERVAL seconds)
        local current_time=$(date +%s)
        if [ $((current_time - last_cleanup)) -ge $CLEANUP_INTERVAL ]; then
            cleanup_orphaned_files
            last_cleanup=$current_time
        fi
        
        # Calculate sleep time to maintain 1-minute interval
        local cycle_duration=$(($(date +%s) - cycle_start))
        local sleep_time=$((REPLICATION_INTERVAL - cycle_duration))
        
        if [ $sleep_time -gt 0 ]; then
            echo "$(date +%F_%H:%M:%S): Cycle completed in ${cycle_duration}s. Sleeping for ${sleep_time}s..."
            sleep $sleep_time
        else
            echo "$(date +%F_%H:%M:%S): WARNING: Cycle took ${cycle_duration}s (longer than ${REPLICATION_INTERVAL}s interval)"
        fi
    done
}

# Run main function
main
