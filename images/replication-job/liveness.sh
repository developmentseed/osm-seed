#!/usr/bin/env bash
# Script to check if Osmosis (Java) is running and also check how old processed_files.log is.
# If processed_files.log is older than MAX_AGE_MINUTES, then kill Osmosis.

LOG_FILE="/mnt/data/processed_files.log"
MAX_AGE_MINUTES=10

get_file_age_in_minutes() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo 999999
    return
  fi
  local now
  local mtime
  now=$(date +%s)
  mtime=$(stat -c %Y "$file")
  local diff=$(( (now - mtime) / 60 )) 
  echo "$diff"
}

# Check if Osmosis (Java) is running
OSMOSIS_COUNT=$(ps -ef | grep -E 'java.*osmosis' | grep -v grep | wc -l)

if [ "$OSMOSIS_COUNT" -ge 1 ]; then
  echo "Osmosis is running."
  # Check how old the processed_files.log file is
  file_age=$(get_file_age_in_minutes "$LOG_FILE")
  echo "processed_files.log file age in minutes: $file_age"
  if [ "$file_age" -ge "$MAX_AGE_MINUTES" ]; then
    echo "processed_files.log is older than $MAX_AGE_MINUTES minutes. Attempting to kill Osmosis and restart the container..."
    # Kill the Osmosis process
    pkill -f "java.*osmosis" || true
    echo "Osmosis is not terminating. Force-killing the container..."
    echo "Container force-restart triggered."
    exit 2
  else
    echo "processed_files.log is not too old. No action needed."
    exit 0
  fi
else
  echo "Osmosis is not running!"
  exit 1
fi
