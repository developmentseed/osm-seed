#!/usr/bin/env bash

workDir=/mnt/data
imposm3_expire_dir=$workDir/imposm/imposm3_expire_dir
mkdir -p $imposm3_expire_dir
imposm3_expire_purged=$workDir/imposm3_expire_dir_purged
mkdir -p $imposm3_expire_purge

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
    cat last_upload_files.json | jq -c '[ .[] | select( .Key | contains(".tiles")) ]' | jq '.[].Key' > list.list
    sed 's/\"//g' list.list > list_expired.list
    # Download tiles
    while IFS= read -r tileFile
    do
      aws s3 cp ${AWS_S3_BUCKET}/${tileFile} $workDir/${tileFile}
      # Purge
      echo tegola --config=/opt/tegola_config/config.toml cache purge --tile-list=$workDir/${tileFile} --tile-name-format="/zxy" --min-zoom 0 --max-zoom 20  --overwrite
      # err=$?
      # if [[ $err != "0" ]]; then
      #   #error
      #   echo "tegola exited with error code $err"
      # fi
    done < list_expired.list
  fi
}

flag=true

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