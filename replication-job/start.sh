#!/usr/bin/env bash

# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
	echo JAVACMD_OPTIONS=\"-server\" >~/.osmosis
else
	memory="${MEMORY_JAVACMD_OPTIONS//i/}"
	echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" >~/.osmosis
fi

workingDirectory="data"

# Check if state.txt exist in the workingDirectory,
# in case the file does not exist locally and does not exist in the cloud the replication will start from 0
if [ ! -f $workingDirectory/state.txt ]; then
	echo "File $workingDirectory/state.txt does not exist"
	echo "let's get check the cloud"
	if [ $CLOUDPROVIDER == "aws" ]; then
		aws s3 ls $AWS_S3_BUCKET$REPLICATION_FOLDER/state.txt
		if [[ $? -eq 0 ]]; then
			echo "File exist, let's get it"
			aws s3 cp $AWS_S3_BUCKET$REPLICATION_FOLDER/state.txt $workingDirectory/state.txt
		fi
	fi
	if [ $CLOUDPROVIDER == "gcp" ]; then
		gsutil ls $GCP_STORAGE_BUCKET$REPLICATION_FOLDER/state.txt
		if [[ $? -eq 0 ]]; then
			echo "File exist, let's get it"
			gsutil cp $GCP_STORAGE_BUCKET$REPLICATION_FOLDER/state.txt $workingDirectory/state.txt
		fi
	fi
fi
# Creating the replication file
osmosis -q \
	--replicate-apidb \
	iterations=0 \
	minInterval=60000 \
	host=$POSTGRES_HOST \
	database=$POSTGRES_DB \
	user=$POSTGRES_USER \
	password=$POSTGRES_PASSWORD \
	validateSchemaVersion=no \
	--write-replication \
	workingDirectory=$workingDirectory &
while true; do
	echo "Sync bucket at ..." $AWS_S3_BUCKET$REPLICATION_FOLDER $(date +%F_%H-%M-%S)

	for file in $(find $workingDirectory/ -cmin -1); do
		if [ -f "$file" ]; then
			bucketFile=${file#*"$workingDirectory"}
				# AWS
				if [ $CLOUDPROVIDER == "aws" ]; then
					echo "copy $file to $AWS_S3_BUCKET$REPLICATION_FOLDER$bucketFile"
					aws s3 cp $file $AWS_S3_BUCKET$REPLICATION_FOLDER$bucketFile --acl public-read
				fi
				# Google Storage
				if [ $CLOUDPROVIDER == "gcp" ]; then
					echo "copy $file to $GCP_STORAGE_BUCKET$REPLICATION_FOLDER$bucketFile"
					gsutil cp -a public-read $file $GCP_STORAGE_BUCKET$REPLICATION_FOLDER$bucketFile
				fi
		fi
	done
	sleep 1m
done
