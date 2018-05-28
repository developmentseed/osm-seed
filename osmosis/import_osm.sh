#!/usr/bin/env bash
# Read the DB and create the planet osm file
planetFile="history-latest.osm"
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
# Upload to S3
aws s3 cp $planetFile.bz2 $S3_OSM_PATH/planet/full-history/$planetFile.bz2 --acl public-read