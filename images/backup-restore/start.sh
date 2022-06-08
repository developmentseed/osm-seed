#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD
export VOLUME_DIR=/mnt/data

date=$(date '+%y%m%d_%H%M')
local_backupFile=$VOLUME_DIR/osmseed-db-${date}.sql.gz
cloud_backupFile=database/osmseed-db-${date}.sql.gz
stateFile=$VOLUME_DIR/state.txt
restoreFile=$VOLUME_DIR/backup.sql.gz

echo "Start...$DB_ACTION action"
# Backing up DataBase
if [ "$DB_ACTION" == "backup" ]; then
	# Backup database and make maximum compression at the slowest speed
	pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB | gzip -9 >$local_backupFile

	# AWS
	if [ "$CLOUDPROVIDER" == "aws" ]; then
		echo "$AWS_S3_BUCKET/$cloud_backupFile" > $stateFile
		# Upload db backup file
		aws s3 cp $local_backupFile $AWS_S3_BUCKET/$cloud_backupFile
		# Upload state.txt file
		aws s3 cp $stateFile $AWS_S3_BUCKET/database/state.txt
	fi

	# GCP
	if [ "$CLOUDPROVIDER" == "gcp" ]; then
		echo "$GCP_STORAGE_BUCKET/$cloud_backupFile" > $stateFile
		# Upload db backup file
		gsutil cp $local_backupFile $GCP_STORAGE_BUCKET/$cloud_backupFile
		# Upload state.txt file
		gsutil cp $stateFile $GCP_STORAGE_BUCKET/database/state.txt
	fi

	# Azure
	if [ "$CLOUDPROVIDER" == "azure" ]; then
		# Save the path file
		echo "blob://$AZURE_STORAGE_ACCOUNT/$AZURE_CONTAINER_NAME/$cloud_backupFile" > $stateFile
		# Upload db backup file
		az storage blob upload \
			--container-name $AZURE_CONTAINER_NAME \
			--file $local_backupFile \
			--name $cloud_backupFile \
			--output table
		# Upload state.txt file
		az storage blob upload \
			--container-name $AZURE_CONTAINER_NAME \
			--file $stateFile \
			--name database/state.txt \
			--output table
	fi
fi

# Restoring DataBase
if [ "$DB_ACTION" == "restore" ]; then
	# AWS
	flag=true
	while "$flag" = true; do
	pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
	flag=false
	wget -O $restoreFile $RESTORE_URL_FILE
	gunzip <$restoreFile | psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB
	echo " Import data to  $POSTGRES_DB has finished ..."
	done
fi
