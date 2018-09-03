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
iterations=0 \
host=$POSTGRES_HOST \
database=$POSTGRES_DB \
user=$POSTGRES_USER \
password=$POSTGRES_PASSWORD \
allowIncorrectSchemaVersion=true \
--write-replication \
workingDirectory=$workingDirectory

# osmosis -q --send-replication-data dataDirectory=data port=8080 notificationPort=8081

# # AWS
# if [ $STORAGE == "S3" ]; then 
#     # Save the path file
#     echo "$S3_OSM_PATH/planet/replicate-minute/$planetFileCompress" > $stateFile

#     # Upload to S3
#     aws s3 cp $planetPBFFile $S3_OSM_PATH/planet/full-history/$planetPBFFile
#     aws s3 cp $planetFileCompress $S3_OSM_PATH/planet/full-history/$planetFileCompress
#     aws s3 cp $stateFile $S3_OSM_PATH/planet/full-history/$stateFile --acl public-read
# fi

# # Google Storage
# if [ $STORAGE == "GS" ]; then 
#     # Save the path file
#     gsutil cp -r $workingDirectory $GS_OSM_PATH/minute
# fi