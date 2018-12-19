#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD
date=$(date '+%Y-%m-%d:%H:%M')
backupFile=osm-seed-${date}.sql.gz
stateFile="state.txt"
restoreFile="backup.sql.gz"

# Backing up DataBase
if [ "$DB_ACTION" == "backup" ]; then
	# Backup database and make maximum compression at the slowest speed
	# --quote-all-identifiers
	pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB | gzip -9 >$backupFile

	# AWS
	if [ "$STORAGE" == "S3" ]; then
		# Upload to S3
		aws s3 cp $backupFile $S3_OSM_PATH/database/$backupFile
		# The file state.txt contain the latest version of DB path
		echo "$S3_OSM_PATH/database/$backupFile" >$stateFile
		aws s3 cp $stateFile $S3_OSM_PATH/database/$stateFile
	fi

	# Google Storage
	if [ "$STORAGE" == "GS" ]; then
		# Upload to GS
		gsutil cp $backupFile $GS_OSM_PATH/database/$backupFile
		# The file state.txt contain the latest version of DB path
		echo "$GS_OSM_PATH/database/$backupFile" >$stateFile
		gsutil cp $stateFile $GS_OSM_PATH/database/$stateFile
	fi
fi

# Restoring DataBase
if [ "$DB_ACTION" == "restore" ]; then
	# AWS
	if [ "$STORAGE" == "S3" ]; then
		# Get the state.txt file from S3
		aws s3 cp $S3_OSM_PATH/database/$stateFile .
		dbPath=$(head -n 1 $stateFile)
		aws s3 cp $dbPath $restoreFile
	fi

	# Google Storage
	if [ "$STORAGE" == "GS" ]; then
		# Get the state.txt file from GS
		gsutil cp $GS_OSM_PATH/database/$stateFile .
		dbPath=$(head -n 1 $stateFile)
		gsutil cp $dbPath $restoreFile
	fi

	gunzip <$restoreFile | psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB
fi

# This part of the code will clean the backups that have an aging of more than a week,
# this can be activated according to a environment variable.
if [ $CLEAN_BACKUPS == "true" ]; then
	DATE=$(date --date="5 day ago" +"%Y-%m-%d")
	# AWS
	if [ $STORAGE == "S3" ]; then
		# Filter files from S3
		aws s3 ls $S3_OSM_PATH/database/ |
			awk '{print $4}' |
			awk -F"osm-seed-" '{$1=$1}1' |
			awk '/sql.gz/{print}' |
			awk -F".sql.gz" '{$1=$1}1' |
			awk '$1 < "'"$DATE"'" {print $0}' |
			sort -n >output
		# Delete filtered files
		while read file; do
			aws s3 rm $S3_OSM_PATH/database/osm-seed-$file.sql.gz
		done <output
		rm output
	fi
	# Google Storage
	if [ $STORAGE == "GS" ]; then
		# Filter files from GS
		gsutil ls $GS_OSM_PATH/database/ |
			awk -F""$GS_OSM_PATH"/database/osm-seed-" '{$1=$1}1' |
			awk '/sql.gz/{print}' |
			awk -F".sql.gz" '{$1=$1}1' |
			awk '$1 < "'"$DATE"'" {print $0}' |
			sort -n >output
		# Delete filtered files
		while read file; do
			gsutil rm $GS_OSM_PATH/database/osm-seed-$file.sql.gz
		done <output
	fi
fi
