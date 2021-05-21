#!/usr/bin/env bash
flag=true
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  ./tile_cache_downloader.sh & ./expire-watcher.sh
done