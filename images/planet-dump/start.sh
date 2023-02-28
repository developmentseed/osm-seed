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

# Read the DB and create the planet osm file
date=$(date '+%y%m%d_%H%M')
local_planetPBFFile=$VOLUME_DIR/planet-${date}.osm.pbf
cloud_planetPBFFile=planet/planet-${date}.osm.pbf

# In case overwrite the file
if [ "$OVERWRITE_PLANET_FILE" == "true" ]; then
	local_planetPBFFile=$VOLUME_DIR/planet-latest.osm.pbf
	cloud_planetPBFFile=planet/planet-latest.osm.pbf
fi

stateFile="$VOLUME_DIR/state.txt"

# Creating the replication file
osmosis --read-apidb \
	host=$POSTGRES_HOST \
	database=$POSTGRES_DB \
	user=$POSTGRES_USER \
	password=$POSTGRES_PASSWORD \
	validateSchemaVersion=no \
	--write-pbf \
	file=$local_planetPBFFile

# AWS
if [ $CLOUDPROVIDER == "aws" ]; then
	# Save the path file
	AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
	echo "$AWS_URL.s3.amazonaws.com/$cloud_planetPBFFile" > $stateFile
	# Upload planet.osm.pbf file to s3
	aws s3 cp $local_planetPBFFile $AWS_S3_BUCKET/$cloud_planetPBFFile --acl public-read
	# Upload state.txt file to s3
	aws s3 cp $stateFile $AWS_S3_BUCKET/planet/state.txt --acl public-read
fi

# gcp
if [ $CLOUDPROVIDER == "gcp" ]; then
	# Save the path file
	echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/$cloud_planetPBFFile" > $stateFile
	# Upload planet.osm.pbf file to cloud storage
	gsutil cp -a public-read $local_planetPBFFile $GCP_STORAGE_BUCKET/$cloud_planetPBFFile
	# Upload state.txt file to cloud storage
	gsutil cp -a public-read $stateFile $GCP_STORAGE_BUCKET/planet/state.txt
fi

# Azure
if [ $CLOUDPROVIDER == "azure" ]; then
	# Save the path file
	echo "https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/$AZURE_CONTAINER_NAME/$cloud_planetPBFFile" > $stateFile
	# Upload planet.osm.pbf file to blob storage
	az storage blob upload \
        --container-name $AZURE_CONTAINER_NAME \
        --file $local_planetPBFFile \
        --name $cloud_planetPBFFile \
        --output table
	# Upload state.txt file to blob storage
	az storage blob upload \
        --container-name $AZURE_CONTAINER_NAME \
        --file $stateFile \
        --name planet/state.txt \
        --output table
fi
