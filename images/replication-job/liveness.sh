#!/usr/bin/env bash
# Liveness check for OSM replication process
# Exit codes: 0=healthy, 1=unhealthy

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

echo "Process is healthy"
exit 0
