#!/usr/bin/env bash
set -e
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
local_fullHistoryFile=$VOLUME_DIR/history-${date}.osh.pbf
cloud_fullHistoryFile=planet/full-history/history-${date}.osh.pbf

# In case overwrite the file
if [ "$OVERWRITE_FHISTORY_FILE" == "true" ]; then
	local_fullHistoryFile=$VOLUME_DIR/history-latest.osh.pbf
	cloud_fullHistoryFile=planet/full-history/history-latest.osh.pbf
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
osmium cat $osm_tmp_file -o $local_fullHistoryFile
osmium fileinfo $local_fullHistoryFile

# Remove full-hitory osm file, keep only history-latest.osh.pbf files
rm $osm_tmp_file

# AWS
if [ $CLOUDPROVIDER == "aws" ]; then
	AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
	echo "$AWS_URL.s3.amazonaws.com/$cloud_fullHistoryFile" >$stateFile
	# Upload history-planet.osm.pbf
	aws s3 cp $local_fullHistoryFile $AWS_S3_BUCKET/$cloud_fullHistoryFile --acl public-read
	# Upload state.txt
	aws s3 cp $stateFile $AWS_S3_BUCKET/planet/full-history/state.txt --acl public-read
fi

# Google Storage
if [ $CLOUDPROVIDER == "gcp" ]; then
	echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/$cloud_fullHistoryFile" >$stateFile
	# Upload history-planet.osm.pbf
	gsutil cp -a public-read $local_fullHistoryFile $GCP_STORAGE_BUCKET/$cloud_fullHistoryFile
	# Upload state.txt
	gsutil cp -a public-read $stateFile $GCP_STORAGE_BUCKET/planet/full-history/state.txt
fi

# Azure
if [ $CLOUDPROVIDER == "azure" ]; then
	# Save the path file
	echo "https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/$AZURE_CONTAINER_NAME/$cloud_fullHistoryFile" >$stateFile
	# Upload history-planet.osm.pbf
	az storage blob upload \
        --container-name $AZURE_CONTAINER_NAME \
        --file $local_fullHistoryFile \
        --name $cloud_fullHistoryFile \
        --output table
	# Upload state.txt
	az storage blob upload \
        --container-name $AZURE_CONTAINER_NAME \
        --file $stateFile \
        --name planet/full-history/state.txt \
        --output table
fi
