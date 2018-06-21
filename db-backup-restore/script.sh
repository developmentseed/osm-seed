#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD

# Creating a gcloud-service-key to uthenticate the gcloud
echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud --quiet components update
/root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT

date=`date '+%Y-%m-%d:%H:%M'`
backupFile=osm-seed-${date}.sql.gz
stateFile="state.txt"
restoreFile="backup.sql.gz"

if [ "$DB_ACTION" = "backup" ]; then
    # Backup database and make maximum compression at the slowest speed
    /usr/bin/pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB  | gzip -9 > $backupFile
    # Upload to S3
    gsutil cp $backupFile $GS_OSM_PATH/database/$backupFile
    # The file state.txt contain the later db path
    echo "$GS_OSM_PATH/database/$backupFile" > $stateFile 
    gsutil cp $stateFile $GS_OSM_PATH/database/$stateFile
elif [ "$DB_ACTION" = "restore" ]; then
    # Get the state.txt file from s3
    gsutil cp $GS_OSM_PATH/database/$stateFile .
    dbPath=$(head -n 1 $stateFile)
    echo $dbPath
    gsutil cp $dbPath $restoreFile
    gzip -f -d $restoreFile
    # Restore the database
    psql -h $POSTGRES_HOST -U $POSTGRES_USER  -d $POSTGRES_DB -f "${restoreFile%.*}"
else
    echo "The DB_ACTION = 'backup' or 'restore' must be set up"
fi