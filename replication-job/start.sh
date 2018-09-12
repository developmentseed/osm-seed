#!/usr/bin/env bash
stateFile="state.txt"
workingDirectory="data"

if [ $STORAGE == "GS" ]; then
# Creating a gcloud-service-key to authenticate the gcloud
echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud --quiet components update
/root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
/root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT
fi

# Check if state.txt exist in the workingDirectory,
# in case the file does not exist locally and does not exist in the cloud the replication will start from 0
if [ ! -f $workingDirectory/state.txt ]; then
    echo "File $workingDirectory/state.txt does not exist"
    echo "let's get check the cloud"
    if [ $STORAGE == "S3" ]; then 
        aws s3 ls $S3_OSM_PATH$REPLICATION_FOLDER/state.txt
        if [[ $? -eq 0 ]]; then
            echo "File exist, let's get it"
            aws s3 cp $S3_OSM_PATH$REPLICATION_FOLDER/state.txt $workingDirectory/state.txt
        fi
    fi
    if [ $STORAGE == "GS" ]; then
        gsutil ls $GS_OSM_PATH$REPLICATION_FOLDER/state.txt
        if [[ $? -eq 0 ]]; then
            echo "File exist, let's get it"
            gsutil cp $GS_OSM_PATH$REPLICATION_FOLDER/state.txt $workingDirectory/state.txt
        fi
    fi
fi

# Creating the replication file
osmosis -q \
--replicate-apidb \
iterations=1 \
host=$POSTGRES_HOST \
database=$POSTGRES_DB \
user=$POSTGRES_USER \
password=$POSTGRES_PASSWORD \
allowIncorrectSchemaVersion=true \
--write-replication \
workingDirectory=$workingDirectory

# AWS
if [ $STORAGE == "S3" ]; then 
    # Sync to S3
    aws s3 sync $workingDirectory $S3_OSM_PATH$REPLICATION_FOLDER
fi

# Google Storage
if [ $STORAGE == "GS" ]; then
    # Sync to GS
    gsutil rsync -r $workingDirectory $GS_OSM_PATH$REPLICATION_FOLDER
fi