#!/usr/bin/env bash

workDir=/mnt/data
expire_dir=$workDir/imposm/imposm3_expire_dir
mkdir -p $expire_dir

s3_tiles_expired_log=$workDir/imposm/s3_tiles_expired_from_$(date +'%Y%m%d%H').log

function downloadExpiredTiles(){
    echo "Download expired tiles...."
    # Get S3 tiles files from the last 1 minute  
    dateStr="$(date -d '-1 min' +'%Y-%m-%dT%H:%M:%S.000Z')"
    
    echo "Date:${dateStr}" >> $s3_tiles_expired_log
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
        --query "Contents[?LastModified>'$dateStr']" > $workDir/imposm/tmp_s3_file.json

        # Filter tiles with extencion .tiles
        cat $workDir/imposm/tmp_s3_file.json | \
        jq -c '[ .[] | select( .Key | contains(".tiles")) ]' | \
        jq '.[].Key' | \
        sed 's/\"//g' > $workDir/imposm/tmp_s3_file.list

        while IFS= read -r tileFile
        do
            aws s3 cp ${AWS_S3_BUCKET}/${tileFile} $workDir/${tileFile}
            echo "${AWS_S3_BUCKET}/${tileFile}" >> $s3_tiles_expired_log
        done < $workDir/imposm/tmp_s3_file.list
        # Remove tmp files
        rm $workDir/imposm/tmp_s3_file.json
        rm $workDir/imposm/tmp_s3_file.list
    fi
}

while true; do
  downloadExpiredTiles
	sleep 1m
done