#!/usr/bin/env bash
# Read the DB and create the planet osm file
date=`date '+%Y-%m-%d:%H:%M'`
planetFile=history-latest-${date}.osm
planetPBFFile=history-latest-${date}.pbf
planetFileCompress=$planetFile.bz2
stateFile="state.txt"

# Creating a gcloud-service-key to authenticate the gcloud
if [ $STORAGE == "GS" ]; then
    echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud --quiet components update
    /root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT
fi

# Creating the replication file
osmosis --read-apidb \
host=$POSTGRES_HOST \
database=$POSTGRES_DB \
user=$POSTGRES_USER \
password=$POSTGRES_PASSWORD \
validateSchemaVersion=no \
--write-xml \
file=$planetFile

# PBF File
osmconvert $planetFile -o=$planetPBFFile
# Compress the file
bzip2 -v $planetFile

# AWS
if [ $STORAGE == "S3" ]; then 
    # Save the path file
    echo "$S3_OSM_PATH/planet/full-history/$planetFileCompress" > $stateFile
    echo "$S3_OSM_PATH/planet/full-history/$planetPBFFile" >> $stateFile
    # Upload to S3
    aws s3 cp $planetPBFFile $S3_OSM_PATH/planet/full-history/$planetPBFFile
    aws s3 cp $planetFileCompress $S3_OSM_PATH/planet/full-history/$planetFileCompress
    aws s3 cp $stateFile $S3_OSM_PATH/planet/full-history/$stateFile --acl public-read
fi

# Google Storage
if [ $STORAGE == "GS" ]; then 
    # Save the path file
    echo "$GS_OSM_PATH/planet/full-history/$planetFileCompress" > $stateFile
    echo "$GS_OSM_PATH/planet/full-history/$planetPBFFile" >> $stateFile
    # Upload to GS
    gsutil cp $planetPBFFile $GS_OSM_PATH/planet/full-history/$planetPBFFile
    gsutil cp $planetFileCompress $GS_OSM_PATH/planet/full-history/$planetFileCompress
    gsutil cp $stateFile $GS_OSM_PATH/planet/full-history/$stateFile
fi

# This part of the code will clean the backups that have an aging of more than a week,
# this can be activated according to a environment variable.
if [ $CLEAN_BACKUPS == "true" ]; then
    DATE=$(date --date="5 day ago" +"%Y-%m-%d")
    # AWS
    if [ $STORAGE == "S3" ]; then 
        # Filter files from S3
        aws s3 ls $S3_OSM_PATH/planet/full-history/ | \
        awk '{print $4}' | \
        awk -F"history-latest-" '{$1=$1}1' | \
        awk '/osm.bz2/{print}' | \
        awk -F".osm.bz2" '{$1=$1}1' |\
        awk '$1 < "'"$DATE"'" {print $0}' | \
        sort -n > output
        # Delete filtered files
        while read file; do
            aws s3 rm $S3_OSM_PATH/planet/full-history/history-latest-$file.osm.bz2
            aws s3 rm $S3_OSM_PATH/planet/full-history/history-latest-$file.pbf
        done < output
        rm output
    fi
    # Google Storage
    if [ $STORAGE == "GS" ]; then 
        # Filter files from GS
        gsutil ls $GS_OSM_PATH/planet/full-history/ | \
        awk -F""$GS_OSM_PATH"/planet/full-history/history-latest-" '{$1=$1}1' | \
        awk '/osm.bz2/{print}' | \
        awk -F".osm.bz2" '{$1=$1}1' |\
        awk '$1 < "'"$DATE"'" {print $0}' | \
        sort -n > output
        # Delete filtered files
        while read file; do
            gsutil rm $GS_OSM_PATH/planet/full-history/history-latest-$file.osm.bz2
            gsutil rm $GS_OSM_PATH/planet/full-history/history-latest-$file.pbf
        done < output
    fi
fi