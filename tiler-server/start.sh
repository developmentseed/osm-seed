#!/usr/bin/env bash
set -e
# until psql -h $GIS_POSTGRES_HOST -U $GIS_POSTGRES_USER -d $GIS_POSTGRES_DB -c "select 1" > /dev/null 2>&1; do
#   echo "Waiting for postgres server"
#   sleep 2
# done

flag=true
while "$flag" = true; do
  pg_isready -h $GIS_POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  tegola serve --config=/opt/tegola_config/config.toml
done