#!/usr/bin/env bash
set -e
flag=true
while "$flag" = true; do
  pg_isready -h $GIS_POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  tegola serve --config=/opt/tegola_config/config.toml
done