#!/usr/bin/env bash

# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
	echo JAVACMD_OPTIONS=\"-server\" >~/.osmosis
else
	memory="${MEMORY_JAVACMD_OPTIONS//i/}"
	echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" >~/.osmosis
fi
# Read the DB and create the planet osm file
date=$(date '+%Y-%m-%d:%H:%M')
planetPBFFile=history-latest-${date}.pbf
stateFile="state.txt"

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
	echo "$AWS_S3_BUCKET/planet/full-history/$planetPBFFile" >>$stateFile
	# Upload to S3
	aws s3 cp $planetPBFFile $AWS_S3_BUCKET/planet/full-history/$planetPBFFile
	aws s3 cp $stateFile $AWS_S3_BUCKET/planet/full-history/$stateFile
fi

# Google Storage
if [ $CLOUDPROVIDER == "gcp" ]; then
	# Save the path file
	echo "$GCP_STORAGE_BUCKET/planet/full-history/$planetPBFFile" >>$stateFile
	# Upload to GS
	gsutil cp $planetPBFFile $GCP_STORAGE_BUCKET/planet/full-history/$planetPBFFile
	gsutil cp $stateFile $GCP_STORAGE_BUCKET/planet/full-history/$stateFile
fi

# Clean backups older than 7 days

if [ $CLEAN_BACKUPS == "true" ]; then
	DATE=$(date --date="5 day ago" +"%Y-%m-%d")
	# AWS
	if [ $CLOUDPROVIDER == "aws" ]; then
		# Filter files from S3
		aws s3 ls $AWS_S3_BUCKET/planet/full-history/ |
			awk '{print $4}' |
			awk -F"history-latest-" '{$1=$1}1' |
			awk '/pbf/{print}' |
			awk -F".pbf" '{$1=$1}1' |
			awk '$1 < "'"$DATE"'" {print $0}' |
			sort -n >output
		# Delete filtered files
		while read file; do
			aws s3 rm $AWS_S3_BUCKET/planet/full-history/history-latest-$file.pbf
		done <output
		rm output
	fi
	# Google Storage
	if [ $CLOUDPROVIDER == "gcp" ]; then
		# Filter files from GS
		gsutil ls $GCP_STORAGE_BUCKET/planet/full-history/ |
			awk -F""$GCP_STORAGE_BUCKET"/planet/full-history/history-latest-" '{$1=$1}1' |
			awk '/pbf/{print}' |
			awk -F".pbf" '{$1=$1}1' |
			awk '$1 < "'"$DATE"'" {print $0}' |
			sort -n >output
		# Delete filtered files
		while read file; do
			gsutil rm $GCP_STORAGE_BUCKET/planet/full-history/history-latest-$file.pbf
		done <output
	fi
fi
