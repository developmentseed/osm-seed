#!/usr/bin/env bash
stateFile="state.txt"
workingDirectory="data"

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
    aws s3 sync $workingDirectory $S3_OSM_PATH/replication/changesets
fi

# Google Storage
if [ $STORAGE == "GS" ]; then
    # Creating a gcloud-service-key to authenticate the gcloud
    echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud --quiet components update
    /root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT
    # Sync to GS
    gsutil rsync -r $workingDirectory $GS_OSM_PATH/replication/changesets
fi