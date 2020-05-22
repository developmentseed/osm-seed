#!/usr/bin/env bash
set -e
flag=true

imposm3_expire_dir=/mnt/data/imposm3_expire_dir
mkdir -p $imposm3_expire_dir

imposm3_expire_purged=/mnt/data/imposm3_expire_dir_purged
mkdir -p $imposm3_expire_purged

function purgeCache(){
  echo "Purge cache..."
  # Get S3 tiles files from the last 1 minute 
  # TODO, Set the time apgo in ENV vars
  DATE=$(date -d '-1 min' +'%m/%d/%Y %H:%M:%S')
  if [ "$CLOUDPROVIDER" == "aws" ]; then
    aws s3api list-objects-v2 \
    --bucket planet.openhistoricalmap.org \
    --query "Contents[?LastModified>'$DATE']" > last_upload_files.json
    # Filter tiles with extencion .tiles
    cat last_upload_files.json | jq -c '[ .[] | select( .Key | contains(".tiles")) ]' | jq '.[].Key' > list_expired.list
    # Download tiles
    while IFS= read -r tileFile
    do
      aws s3 cp ${AWS_S3_BUCKET}/${tileFile} $imposm3_expire_dir
    done < list_expired.list
    # Purge
  fi
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