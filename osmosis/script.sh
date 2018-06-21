#!/usr/bin/env bash

# Creating a gcloud-service-key to uthenticate the gcloud
echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud --quiet components update
/root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT

# Read the DB and create the planet osm file
date=`date '+%Y-%m-%d:%H:%M'`
planetFile=history-latest-${date}.osm
planetPBFFile=history-latest-${date}.pbf
planetFileCompress=$planetFile.bz2
stateFile="state.txt"

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
# Save the path file
echo "$GS_OSM_PATH/planet/full-history/$planetFileCompress" > $stateFile
echo "$GS_OSM_PATH/planet/full-history/$planetPBFFile" >> $stateFile
# Upload to S3
gsutil cp $planetPBFFile $GS_OSM_PATH/planet/full-history/$planetPBFFile
gsutil cp $planetFileCompress $GS_OSM_PATH/planet/full-history/$planetFileCompress
gsutil cp $stateFile $GS_OSM_PATH/planet/full-history/$stateFile