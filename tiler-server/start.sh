#!/bin/bash
echo Sleep for a while!;
sleep 100;
echo Starting tiles server!;
set -e
flag=true
export PATH=$PATH:/opt
while "$flag" = true; do
echo "trying to connect to $TEGOLA_POSTGRES_HOST"
  pg_isready -h $TEGOLA_POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  # TEGOLA_SQL_DEBUG=EXECUTE_SQL 
  tegola serve --config=/opt/tegola_config/config.toml
done
