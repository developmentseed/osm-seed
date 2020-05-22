#!/usr/bin/env bash

workDir=/mnt/data
imposm3_expire_dir=$workDir/imposm/imposm3_expire_dir
mkdir -p $imposm3_expire_dir
imposm3_expire_purged=$workDir/imposm3_expire_dir_purged
mkdir -p $imposm3_expire_purge

function downloadExpiredTiles(){
    echo "Download expired tiles...."
    # Get S3 tiles files from the last 1 minute  
    dateStr="$(date -d '-1 min' +'%Y-%m-%dT%H:%M:%S.000Z')"
    # 2020-05-22T19:51:05.000Z
    # PURGE_CACHE_FROM = -1 min, by default
    # eg. -50 min, -4 hour, -4 day
    # if [[ ! -z "$PURGE_TILE_CACHE_FROM" ]]
    # then
    #   dateStr=$(date -d $PURGE_TILE_CACHE_FROM +'%m/%d/%Y %H:%M:%S')
    # fi
    # echo $PURGE_TILE_CACHE_FROM
    echo "Getting expired tiles from... $dateStr"
    # TODO downloader for GS
    if [ "$CLOUDPROVIDER" == "aws" ]; then

        # Download the list of latets files according to dateStr
        aws s3api list-objects-v2 \
        --bucket ${AWS_S3_BUCKET#*"s3://"} \
        --query "Contents[?LastModified>'$dateStr']" > $workDir/imposm/tile_expired.json

        # Filter tiles with extencion .tiles
        cat $workDir/imposm/tile_expired.json | \
        jq -c '[ .[] | select( .Key | contains(".tiles")) ]' | \
        jq '.[].Key' | \
        sed 's/\"//g' > $workDir/imposm/tiles_expired.list

        while IFS= read -r tileFile
        do
            aws s3 cp ${AWS_S3_BUCKET}/${tileFile} $workDir/${tileFile}
        done < $workDir/imposm/tiles_expired.list
    fi
}

flag=true
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  # TEGOLA_SQL_DEBUG=EXECUTE_SQL 
  tegola serve --config=/opt/tegola_config/config.toml &
	while true; do
    downloadExpiredTiles
		sleep 1m
	done
done