#!/usr/bin/env bash
set -e
flag=true

imposm3_expire_dir=/mnt/data/imposm3_expire_dir
mkdir -p $imposm3_expire_dir

while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  # TEGOLA_SQL_DEBUG=EXECUTE_SQL 
  tegola serve --config=/opt/tegola_config/config.toml
done