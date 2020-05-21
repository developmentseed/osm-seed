#!/usr/bin/env bash
set -e
flag=true

IMPOSM3_EXPIRE_DIR=/mnt/data/imposm3_expire_dir
mkdir -p $IMPOSM3_EXPIRE_DIR

IMPOSM3_EXPIRE_PURGED=/mnt/data/imposm3_expire_dir_purged
mkdir -p $IMPOSM3_EXPIRE_PURGED

function purgeCache(){
  echo "Purge cache..."
}

while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  # TEGOLA_SQL_DEBUG=EXECUTE_SQL 
  tegola serve --config=/opt/tegola_config/config.toml &
	while true; do
    purgeCache
		sleep 30s
	done
done