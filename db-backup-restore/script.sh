#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD
date=`date '+%Y-%m-%d:%H:%M'`
backupFile=osm-seed-${date}.sql.gz
stateFile="state.txt"
restoreFile="backup.sql.gz"

# Creating a gcloud-service-key to uthenticate the gcloud
if [ $STORAGE == "GS" ]; then
echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud --quiet components update
/root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT
fi

# Backing up DataBase
if [ "$DB_ACTION" = "backup" ]; then
    # Backup database and make maximum compression at the slowest speed
    /usr/bin/pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB  | gzip -9 > $backupFile

    # AWS
    if [ $STORAGE == "S3" ]; then 
        # Upload to S3
        aws s3 cp $backupFile $S3_OSM_PATH/database/$backupFile
        # The file state.txt contain the latest version of DB path
        echo "$S3_OSM_PATH/database/$backupFile" > $stateFile 
        aws s3 cp $stateFile $S3_OSM_PATH/database/$stateFile
    fi

    # Google Storage
    if [ $STORAGE == "GS" ]; then 
        # Upload to GS
        gsutil cp $backupFile $GS_OSM_PATH/database/$backupFile
        # The file state.txt contain the latest version of DB path
        echo "$GS_OSM_PATH/database/$backupFile" > $stateFile 
        gsutil cp $stateFile $GS_OSM_PATH/database/$stateFile
    fi
fi

# Restoring DataBase
if [ "$DB_ACTION" = "restore" ]; then
    # AWS
    if [ $STORAGE == "S3" ]; then 
        # Get the state.txt file from S3
        aws s3 cp $S3_OSM_PATH/database/$stateFile .
        dbPath=$(head -n 1 $stateFile)
        aws s3 cp $dbPath $restoreFile
    fi

    # Google Storage
    if [ $STORAGE == "GS" ]; then 
    # Get the state.txt file from GS
        gsutil cp $GS_OSM_PATH/database/$stateFile .
        dbPath=$(head -n 1 $stateFile)
        gsutil cp $dbPath $restoreFile
    fi

    gzip -f -d $restoreFile
    psql -h $POSTGRES_HOST -U $POSTGRES_USER  -d $POSTGRES_DB -f "${restoreFile%.*}"
fi