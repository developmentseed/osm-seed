#!/usr/bin/env bash
export VOLUME_DIR=/mnt/data

# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
	echo JAVACMD_OPTIONS=\"-server\" >~/.osmosis
else
	memory="${MEMORY_JAVACMD_OPTIONS//i/}"
	echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" >~/.osmosis
fi

# Fixing name for historical file
date=$(date '+%y%m%d_%H%M')
fullHistoryFile=$VOLUME_DIR/history-${date}.osh.pbf
# In case overwrite the file
if [ "$OVERWRITE_FHISTORY_FILE" == "true" ]; then
	fullHistoryFile=$VOLUME_DIR/history-latest.osh.pbf
fi

# State file nname
stateFile="$VOLUME_DIR/state.txt"
osm_tmp_file="osm_tmp.osm"

# Creating full history
osmosis --read-apidb-change \
	host=$POSTGRES_HOST \
	database=$POSTGRES_DB \
	user=$POSTGRES_USER \
	password=$POSTGRES_PASSWORD \
	validateSchemaVersion=no \
	readFullHistory=yes \
	--write-xml-change \
	compressionMethod=auto \
	$osm_tmp_file

# Convert file to PBF file
osmium cat $osm_tmp_file -o $fullHistoryFile
osmium fileinfo $fullHistoryFile

# Remove full-hitory osm file, keep only history-latest.osh.pbf files
rm $osm_tmp_file

# AWS
if [ $CLOUDPROVIDER == "aws" ]; then
	AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
	echo "$AWS_URL.s3.amazonaws.com/planet/full-history/$fullHistoryFile" >$stateFile
	# Upload to S3
	aws s3 cp $fullHistoryFile $AWS_S3_BUCKET/planet/full-history/$fullHistoryFile --acl public-read
	aws s3 cp $stateFile $AWS_S3_BUCKET/planet/full-history/$stateFile --acl public-read
fi

# Google Storagegit status
if [ $CLOUDPROVIDER == "gcp" ]; then
	echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/planet/full-history/$fullHistoryFile" >$stateFile
	# Upload to GS
	gsutil cp -a public-read $fullHistoryFile $GCP_STORAGE_BUCKET/planet/full-history/$fullHistoryFile
	gsutil cp -a public-read $stateFile $GCP_STORAGE_BUCKET/planet/full-history/$stateFile
fi
