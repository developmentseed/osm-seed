#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD
export VOLUME_DIR=/mnt/data

date=$(date '+%y%m%d_%H%M')
backupFile=$VOLUME_DIR/osmseed-db-${date}.sql.gz
stateFile=$VOLUME_DIR/state.txt
restoreFile=$VOLUME_DIR/backup.sql.gz

echo "Start...$DB_ACTION action"
# Backing up DataBase
if [ "$DB_ACTION" == "backup" ]; then
	# Backup database and make maximum compression at the slowest speed
	pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB | gzip -9 >$backupFile

	# AWS
	if [ "$CLOUDPROVIDER" == "aws" ]; then
		# Upload to S3
		aws s3 cp $backupFile $AWS_S3_BUCKET/database/$backupFile
		# The file state.txt contain the latest version of DB path
		echo "$AWS_S3_BUCKET/database/$backupFile" > $stateFile
		aws s3 cp $stateFile $AWS_S3_BUCKET/database/$stateFile
	fi

	# Google Storage
	if [ "$CLOUDPROVIDER" == "gcp" ]; then
		# Upload to GS
		gsutil cp $backupFile $GCP_STORAGE_BUCKET/database/$backupFile
		# The file state.txt contain the latest version of DB path
		echo "$GCP_STORAGE_BUCKET/database/$backupFile" >$stateFile
		gsutil cp $stateFile $GCP_STORAGE_BUCKET/database/$stateFile
	fi
fi

# Restoring DataBase
if [ "$DB_ACTION" == "restore" ]; then
	# AWS
	wget -O $restoreFile $RESTORE_URL_FILE
	gunzip <$restoreFile | psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB
	echo " Import data to  $POSTGRES_DB has finished ..."
fi
