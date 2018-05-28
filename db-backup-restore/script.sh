#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD

date=`date '+%Y-%m-%d:%H'`
backupFile=osm-seed-${date}.sql.gz
stateFile="state.txt"
restoreFile="backup.sql.gz"

if [ "$ACTION" = "backup" ]; then
    # Backup database and make maximum compression at the slowest speed
    /usr/bin/pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB  | gzip -9 > $backupFile
    # Upload to S3
    aws s3 cp $backupFile $S3_OSM_PATH/database/$backupFile
    # The file state.txt contain the later db path
    echo "$S3_OSM_PATH/database/$backupFile" > $stateFile 
    aws s3 cp $stateFile $S3_OSM_PATH/database/$stateFile
elif [ "$ACTION" = "restore" ]; then
    # Get the state.txt file from s3
    aws s3 cp $S3_OSM_PATH/database/$stateFile .
    dbPath=$(head -n 1 $stateFile)
    echo $dbPath
    aws s3 cp $dbPath $restoreFile
    gzip -f -d $restoreFile
    # Restore the database
    psql -h $POSTGRES_HOST -U $POSTGRES_USER  -d $POSTGRES_DB -f "${restoreFile%.*}"
else
    echo "The ACTION = 'backup' or 'restore' must be set up"
fi