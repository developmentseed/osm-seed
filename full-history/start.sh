#!/usr/bin/env bash

# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
	echo JAVACMD_OPTIONS=\"-server\" >~/.osmosis
else
	memory="${MEMORY_JAVACMD_OPTIONS//i/}"
	echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" >~/.osmosis
fi

# Fixing name for file
date=$(date '+%y%m%d_%H%M')
fullHistoryFile=history-${date}.osm.bz2
# In case overwrite the file
if [ "$OVERWRITE_FHISTORY_FILE" == "true" ]; then
	fullHistoryFile=history-latest.osm.bz2
fi
# State file
stateFile="state.txt"

# Creating full history
osmosis --read-apidb-change \
	host=$POSTGRES_HOST \
	database=$POSTGRES_DB \
	user=$POSTGRES_USER \
	password=$POSTGRES_PASSWORD \
	validateSchemaVersion=no \
	readFullHistory=yes \
  	--write-xml-change \
	compressionMethod=bzip2 \
	$fullHistoryFile

# AWS
if [ $CLOUDPROVIDER == "aws" ]; then
	echo "https://$AWS_S3_BUCKET.s3.amazonaws.com/planet/full-history/$fullHistoryFile" > $stateFile
	# Upload to S3
	aws s3 cp $fullHistoryFile $AWS_S3_BUCKET/planet/full-history/$fullHistoryFile --acl public-read 
	aws s3 cp $stateFile $AWS_S3_BUCKET/planet/full-history/$stateFile --acl public-read 
fi

# Google Storage
if [ $CLOUDPROVIDER == "gcp" ]; then
	echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/planet/full-history/$fullHistoryFile" > $stateFile
	# Upload to GS
	gsutil cp -a public-read $fullHistoryFile $GCP_STORAGE_BUCKET/planet/full-history/$fullHistoryFile
	gsutil cp -a public-read $stateFile $GCP_STORAGE_BUCKET/planet/full-history/$stateFile
fi
