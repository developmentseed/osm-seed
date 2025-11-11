#!/usr/bin/env bash
set -x

# ---- Directory variables ----
workingDirectory="/mnt/data"
tmpDirectory="$workingDirectory/tmp"
runDirectory="$workingDirectory/run"

# ---- Directory setup ----
mkdir -p "$workingDirectory"
mkdir -p "$tmpDirectory"
mkdir -p "$runDirectory"

# Slack setup
slack_message_count=0
max_slack_messages=2

# ---- osmdbt-config.yaml creation ----
cat <<EOF > /osmdbt-config.yaml
database:
  host: ${POSTGRES_HOST:-localhost}
  port: ${POSTGRES_PORT:-5432}
  dbname: ${POSTGRES_DB:-osm}
  user: ${POSTGRES_USER:-osm}
  password: ${POSTGRES_PASSWORD}
  replication_slot: ${REPLICATION_SLOT:-osm_repl}

log_dir: ${workingDirectory}
changes_dir: ${workingDirectory}
tmp_dir: ${tmpDirectory}
run_dir: ${runDirectory}
EOF


# Remove lock file if it exists (avoids replication issues on restart)
[ -e "$workingDirectory/replicate.lock" ] && rm -f "$workingDirectory/replicate.lock"


function ensure_replication_slot_exists() {
    export PGPASSWORD="${POSTGRES_PASSWORD}"
    local slot="${REPLICATION_SLOT:-osm_repl}"
    local plugin="osm_logical"
    
    # Check if slot already exists
    local slot_count=$(psql -h "${POSTGRES_HOST:-localhost}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-osm}" -d "${POSTGRES_DB:-osm}" -t -A -c \
        "SELECT count(*) FROM pg_replication_slots WHERE slot_name='$slot';" 2>/dev/null | tr -d '[:space:]')
    
    if [ "$slot_count" = "1" ]; then
        echo "Replication slot '$slot' already exists."
        return 0
    fi
    
    # Try to create the slot
    psql -h "${POSTGRES_HOST:-localhost}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-osm}" -d "${POSTGRES_DB:-osm}" -c \
        "SELECT * FROM pg_create_logical_replication_slot('$slot', '$plugin');"


}


# --- Function: retrieve last known state from S3 or local storage
function get_current_state_file() {
    # Check if state.txt exists locally
    if [ ! -f "$workingDirectory/state.txt" ]; then
        echo "File $workingDirectory/state.txt does not exist in local storage"
        # If using AWS, try downloading state.txt from the S3 bucket
        if [ "$CLOUDPROVIDER" == "aws" ]; then
            aws s3 ls "$AWS_S3_BUCKET/$REPLICATION_FOLDER/state.txt" >/dev/null
            if [[ $? -eq 0 ]]; then
                echo "File exists in S3, downloading..."
                aws s3 cp "$AWS_S3_BUCKET/$REPLICATION_FOLDER/state.txt" "$workingDirectory/state.txt"
            fi
        fi
    else
        echo "File $workingDirectory/state.txt found locally:"
        cat "$workingDirectory/state.txt"
    fi
}

# --- Function: upload files to cloud (S3)
function upload_file_cloud() {
    local local_file="$1"
    local cloud_file="$REPLICATION_FOLDER/${local_file#*"$workingDirectory/"}"
    echo "$(date +%F_%H:%M:%S): Upload file $local_file to $CLOUDPROVIDER ($cloud_file)"
    if [ "$CLOUDPROVIDER" == "aws" ]; then
        aws s3 cp "$local_file" "$AWS_S3_BUCKET/$cloud_file" --acl public-read
    fi
}

# --- Function: send Slack notifications
function send_slack_message() {
    if [ "${ENABLE_SEND_SLACK_MESSAGE}" != "true" ]; then
        echo "Slack messaging is disabled. Set ENABLE_SEND_SLACK_MESSAGE to true to enable."
        return
    fi
    if [ -z "${SLACK_WEBHOOK_URL}" ]; then
        echo "SLACK_WEBHOOK_URL is not set. Unable to send message to Slack."
        return 1
    fi
    if [ "$slack_message_count" -ge "$max_slack_messages" ]; then
        echo "Max Slack messages limit reached. No further messages will be sent."
        return
    fi
    local message="$1"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$message\"}" "$SLACK_WEBHOOK_URL"
    echo "Message sent to Slack: $message"
    slack_message_count=$((slack_message_count + 1))
}

# --- Function: track and upload minute replication files
function monitor_minute_replication() {
    processed_files_log="$workingDirectory/processed_files.log"
    max_log_size_mb=1
    while true; do
        if [ -e "$processed_files_log" ]; then
            log_size=$(du -m "$processed_files_log" | cut -f1)
            # Clean log if too large (avoids disk fill)
            if [ "$log_size" -gt "$max_log_size_mb" ]; then
                echo "$(date +%F_%H:%M:%S): Cleaning processed_files_log..." >"$processed_files_log"
            fi
            # Check for new .gz files created in the last minute
            for local_minute_file in $(find "$workingDirectory/" -name "*.gz" -cmin -1); do
                if [ -f "$local_minute_file" ]; then
                    echo "Processing $local_minute_file..."
                    # Ensure this file hasn't already been processed (success or failure)
                    if ! grep -q "$local_minute_file: SUCCESS" "$processed_files_log" && ! grep -q "$local_minute_file: FAILURE" "$processed_files_log"; then
                        # Integrity test for .gz files
                        if gzip -t "$local_minute_file" 2>/dev/null; then
                            upload_file_cloud "$local_minute_file"
                            local_state_file="${local_minute_file%.osc.gz}.state.txt"
                            upload_file_cloud "$local_state_file"
                            echo "$local_minute_file: SUCCESS" >>"$processed_files_log"
                            upload_file_cloud "$workingDirectory/state.txt"
                        else
                            echo "$(date +%F_%H:%M:%S): $local_minute_file is corrupted and will not be uploaded." >>"$processed_files_log"
                            echo "$local_minute_file: FAILURE" >>"$processed_files_log"
                            # Rollback state.txt to previous sequence
                            current_state_id=$(( $(echo "$local_minute_file" | sed 's/[^0-9]//g' | sed 's/^0*//') - 1 ))
                            sed -i "s/sequenceNumber=.*/sequenceNumber=$current_state_id/" "$workingDirectory/state.txt"
                            rm "$local_minute_file"
                            echo "Stopping any existing osmdbt processes..."
                            pkill -f "osmdbt"
                            echo "Regenerating $local_minute_file..."
                            send_slack_message "${ENVIROMENT}: Corrupted file $local_minute_file detected. Regenerating the file..."
                            generate_replication
                        fi
                    fi
                fi
            done
        else
            echo "File $processed_files_log not found. Creating log file."
            echo "$processed_files_log" >"$processed_files_log"
        fi
        sleep 10s
    done
}

# --- Function: run osmdbt replication tool (adjust command/options as needed)
function generate_replication() {
    # Launch osmdbt-get-log for this minute
    /osmdbt/build/src/osmdbt-get-log \
        -c /osmdbt-config.yaml 
}

# --- MAIN PROCESS STARTS HERE ---
get_current_state_file

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if pg_isready -h "${POSTGRES_HOST:-localhost}" -p "${POSTGRES_PORT:-5432}" >/dev/null 2>&1; then
        echo "PostgreSQL is ready."
        break
    fi
    attempt=$((attempt + 1))
    echo "PostgreSQL not ready yet, attempt $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERROR: PostgreSQL is not ready after $max_attempts attempts"
    exit 1
fi

# Ensure replication slot exists before starting replication
if ! ensure_replication_slot_exists; then
    echo "ERROR: Failed to ensure replication slot exists. Exiting."
    exit 1
fi

# Launch replication in background and start monitoring
generate_replication &
monitor_minute_replication
