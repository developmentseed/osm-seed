#!/bin/bash
set -e
stateFile="state.txt"
PBFFile="osm.pbf"
limitFile="limitFile.geojson"

# directories to keep the imposm's cache for updating the db
workDir=/mnt/data
cachedir=$workDir/cachedir
mkdir -p $cachedir
diffdir=$workDir/diff
mkdir -p $diffdir
imposm3_expire_dir=$workDir/imposm3_expire_dir
mkdir -p $imposm3_expire_dir
# imposm3_expire_state_dir=$workDir/imposm3_expire_state
# mkdir -p $imposm3_expire_state_dir
# Setting directory
settingDir=/osm
# Folder to store the imposm expider files in s3 or gs
BUCKET_IMPOSM_FOLDER=imposm

# Create config file to set variable  for imposm
echo "{" > $workDir/config.json
echo "\"cachedir\": \"$cachedir\","  >> $workDir/config.json
echo "\"diffdir\": \"$diffdir\","  >> $workDir/config.json
echo "\"connection\": \"postgis://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB\"," >> $workDir/config.json
echo "\"mapping\": \"config/imposm3.json\","  >> $workDir/config.json
echo "\"replication_url\": \"$REPLICATION_URL\""  >> $workDir/config.json
echo "}" >> $workDir/config.json

function getData () {
    # Import from pubic url, usualy it come from osm
    if [ $TILER_IMPORT_FROM == "osm" ]; then 
        wget $TILER_IMPORT_PBF_URL -O $PBFFile
    fi

    if [ $TILER_IMPORT_FROM == "osmseed" ]; then 
        if [ $CLOUDPROVIDER == "aws" ]; then 
            # Get the state.txt file from S3
            aws s3 cp $AWS_S3_BUCKET/planet/full-history/$stateFile .
            PBFCloudPath=$(tail -n +1 $stateFile)
            aws s3 cp $PBFCloudPath $PBFFile
        fi
        # Google storage
        if [ $CLOUDPROVIDER == "gcp" ]; then 
            # Get the state.txt file from GS
            gsutil cp $GCP_STORAGE_BUCKET/planet/full-history/$stateFile .
            PBFCloudPath=$(tail -n +1 $stateFile)
            gsutil cp $PBFCloudPath $PBFFile
        fi
    fi
}

function uploadExpiredFiles(){
        # create statte file
        # dateStr=$(date '+%y%m%d%H%M%S')
        # stateFile=$imposm3_expire_state_dir/expired_${dateStr}.txt
        # bucketStateFile=${stateFile#*"$workDir"}
        
        for file in $(find $imposm3_expire_dir -type f -cmin -1); do
            bucketFile=${file#*"$workDir"}
            echo $(date +%F_%H:%M:%S)": New file..." $file
            # echo $file >> $stateFile
            # AWS
            if [ "$CLOUDPROVIDER" == "aws" ]; then
                aws s3 cp $file ${AWS_S3_BUCKET}/${BUCKET_IMPOSM_FOLDER}${bucketFile} --acl public-read
            fi
            # Google Storage
            if [ "$CLOUDPROVIDER" == "gcp" ]; then
                gsutil cp -a public-read $file ${GCP_STORAGE_BUCKET}${BUCKET_IMPOSM_FOLDER}${bucketFile}
            fi
        done
        # Upload state File
        # if [[ -f "$stateFile" ]]; then
        #     # AWS
        #     if [ "$CLOUDPROVIDER" == "aws" ]; then
        #         aws s3 cp $stateFile ${AWS_S3_BUCKET}/${BUCKET_IMPOSM_FOLDER}${bucketStateFile} --acl public-read
        #     fi
        #     # Google Storage
        #     if [ "$CLOUDPROVIDER" == "gcp" ]; then
        #         gsutil cp -a public-read $stateFile ${GCP_STORAGE_BUCKET}${BUCKET_IMPOSM_FOLDER}${bucketStateFile}
        #     fi
        # fi
}

function updateData(){
    if [ "$OVERWRITE_STATE" = "true" ]; then
        rm $diffdir/last.state.txt
    fi
    # Verify if last.state.txt exist
    if [ -f "$diffdir/last.state.txt" ]; then
        echo "Exist... $diffdir/last.state.txt"        
    else 
        # OverWrite the last.state.txt file with REPLICATION_URL and sequenceNumber=0
        echo "timestamp=0001-01-01T00\:00\:00Z 
        sequenceNumber=0
        replicationUrl=$REPLICATION_URL" > $diffdir/last.state.txt
    fi

    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm run -config $workDir/config.json -expiretiles-dir $imposm3_expire_dir &
        while true
        do 
            echo "Updating...$(date +%F_%H-%M-%S)"
            uploadExpiredFiles
            sleep 1m
        done
    else
        imposm run -config $workDir/config.json -limitto $workDir/$limitFile -expiretiles-dir $imposm3_expire_dir &
        while true
        do 
            echo "Updating...$(date +%F_%H-%M-%S)"
            uploadExpiredFiles
            sleep 1m
        done
    fi
}

function importData () {
    echo "Execute the missing functions"
    psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" -a -f config/postgis_helpers.sql
    echo "Import Natural Earth"
    ./scripts/natural_earth.sh
    echo "Import OSM Land"
    ./scripts/osm_land.sh
    echo "Import PBF file"

    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm import \
        -config $workDir/config.json \
        -read $PBFFile \
        -write \
        -diff -cachedir $cachedir -diffdir $diffdir
    else
        wget $TILER_IMPORT_LIMIT -O $workDir/$limitFile
        imposm import \
        -config $workDir/config.json \
        -read $PBFFile \
        -write \
        -diff -cachedir $cachedir -diffdir $diffdir \
        -limitto $workDir/$limitFile
    fi

    imposm import \
    -config $workDir/config.json \
    -deployproduction
    # -diff -cachedir $cachedir -diffdir $diffdir

    # These index will help speed up tegola tile generation
    psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" -a -f config/postgis_index.sql

    # Update the DB
    updateData
}


echo "Connecting... to postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB"
flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
        # Change flag to false to stop ping the DB
        flag=false
        hasData=$(psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" \
        -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" | sed -n 3p | sed 's/ //g')
        # After import there are more than 70 tables
        
        if [ $hasData  \> 70 ]; then
            echo "Update the DB with osm data"
            updateData
        else
            echo "Import PBF data to DB"
            getData
            if [ -f $PBFFile ]; then
                echo "Start importing the data"
                importData
            fi
        fi
done
