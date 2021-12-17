#!/usr/bin/env bash
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
planetPBFFile=$VOLUME_DIR/planet-${date}.osm.pbf
# In case overwrite the file
if [ "$OVERWRITE_PLANET_FILE" == "true" ]; then
	planetPBFFile=$VOLUME_DIR/planet-latest.osm.pbf
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
	file=$planetPBFFile

# AWS
if [ $CLOUDPROVIDER == "aws" ]; then
	# Save the path file
	AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
	echo "$AWS_URL.s3.amazonaws.com/planet/$planetPBFFile" > $stateFile
	# Upload to S3
	aws s3 cp $planetPBFFile $AWS_S3_BUCKET/planet/$planetPBFFile --acl public-read 
	aws s3 cp $stateFile $AWS_S3_BUCKET/planet/$stateFile --acl public-read
fi

# Google Storage
if [ $CLOUDPROVIDER == "gcp" ]; then
	# Save the path file
	echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/planet/$planetPBFFile" > $stateFile
	# Upload to GS
	gsutil cp -a public-read $planetPBFFile $GCP_STORAGE_BUCKET/planet/$planetPBFFile
	gsutil cp -a public-read $stateFile $GCP_STORAGE_BUCKET/planet/$stateFile
fi
