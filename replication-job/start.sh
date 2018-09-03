#!/usr/bin/env bash
stateFile="state.txt"
workingDirectory="data"
minInterval=$(( $REPLICATION_INTERVAL * 60 * 1000 ))
# Creating a gcloud-service-key to authenticate the gcloud
if [ $STORAGE == "GS" ]; then
    echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud --quiet components update
    /root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT
fi

# Creating the replication file
osmosis -q \
--replicate-apidb \
minInterval=$minInterval \
iterations=1 \
host=$POSTGRES_HOST \
database=$POSTGRES_DB \
user=$POSTGRES_USER \
password=$POSTGRES_PASSWORD \
allowIncorrectSchemaVersion=true \
--write-replication \
workingDirectory=$workingDirectory