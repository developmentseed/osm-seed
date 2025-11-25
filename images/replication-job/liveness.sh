#!/usr/bin/env bash
# Liveness check for OSM replication process
# Checks if main process is running, PostgreSQL connection, and if log file is being updated
# Exit codes: 0=healthy, 1=process not running or DB unreachable, 2=process stuck

LOG_FILE="${WORKING_DIRECTORY:-/mnt/data}/logs/processed_files.log"
MAX_AGE_MINUTES="${MAX_LOG_AGE_MINUTES:-10}"

# Check if main process (start.sh) is running
if ! pgrep -f "start.sh" >/dev/null 2>&1; then
  echo "Main process (start.sh) is not running!"
  exit 1
fi

# Check PostgreSQL connection
export PGPASSWORD="${POSTGRES_PASSWORD:-}"
if ! pg_isready -h "${POSTGRES_HOST:-localhost}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-osm}" -d "${POSTGRES_DB:-osm}" >/dev/null 2>&1; then
  echo "PostgreSQL is not reachable!"
  exit 1
fi

# Check log file age
if [ ! -f "$LOG_FILE" ]; then
  echo "Log file not found: $LOG_FILE"
  exit 1
fi

# Get file age in minutes
now=$(date +%s)
mtime=$(stat -c %Y "$LOG_FILE" 2>/dev/null || stat -f %m "$LOG_FILE" 2>/dev/null || echo "0")
file_age=$(( (now - mtime) / 60 ))

# If log is too old, process might be stuck
if [ "$file_age" -ge "$MAX_AGE_MINUTES" ]; then
  echo "Log file is older than $MAX_AGE_MINUTES minutes (age: $file_age min). Process may be stuck."
  exit 2
fi

echo "Process is healthy (log age: $file_age min)"
exit 0
