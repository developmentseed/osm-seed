#!/usr/bin/env bash
# Read the DB and create the planet osm file
date=`date '+%Y-%m-%d:%H:%M'`
planetFile=history-latest-${date}.osm
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
# Compress the file
bzip2 -v $planetFile
# Save the path file
echo "$S3_OSM_PATH/planet/full-history/$planetFileCompress" > $stateFile
# Upload to S3
aws s3 cp $planetFileCompress $S3_OSM_PATH/planet/full-history/$planetFileCompress --acl public-read
aws s3 cp $stateFile $S3_OSM_PATH/planet/full-history/$stateFile --acl public-read