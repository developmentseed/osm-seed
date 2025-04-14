#!/usr/bin/env bash
pgrep -f openstreetmap-cgimap > /dev/null
cgimap_status=$?

# Check PostgreSQL connection
PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1;" > /dev/null 2>&1
postgres_status=$?

# Exit code logic
if [ $cgimap_status -eq 0 ] && [ $postgres_status -eq 0 ]; then
  echo "cgimap and PostgreSQL are healthy"
  exit 0
else
  [ $cgimap_status -ne 0 ] && echo "cgimap not running" >&2
  [ $postgres_status -ne 0 ] && echo "cannot connect to PostgreSQL" >&2
  exit 1
fi