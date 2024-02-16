#!/bin/bash
set -e

STATEFILE="state.txt"
PBFFILE="osm.pbf"
LIMITFILE="limitFile.geojson"

# directories to keep the imposm's cache for updating the db
WORKDIR=/mnt/data
CACHE_DIR=$WORKDIR/cachedir
DIFF_DIR=$WORKDIR/diff
IMPOSM3_EXPIRE_DIR=$WORKDIR/imposm3_expire_dir

# # Setting directory
# settingDir=/osm
# Folder to store the imposm expider files in s3 or gs
BUCKET_IMPOSM_FOLDER=imposm
INIT_FILE=/mnt/data/init_done

mkdir -p "$CACHE_DIR" "$DIFF_DIR" "$IMPOSM3_EXPIRE_DIR"

# Create config file to set variables for imposm
{
    echo "{"
    echo "\"cachedir\": \"$CACHE_DIR\","
    echo "\"diffdir\": \"$DIFF_DIR\","
    echo "\"connection\": \"postgis://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB\","
    echo "\"mapping\": \"config/imposm3.json\","
    echo "\"replication_url\": \"$REPLICATION_URL\""
    echo "}"
} >"$WORKDIR/config.json"

function getData() {
    ### Get the PBF file from the cloud provider or public URL
    if [ "$TILER_IMPORT_FROM" == "osm" ]; then
        wget "$TILER_IMPORT_PBF_URL" -O "$PBFFILE"
    elif [ "$TILER_IMPORT_FROM" == "osmseed" ]; then
        if [ "$CLOUDPROVIDER" == "aws" ]; then
            # Get the state.txt file from S3
            aws s3 cp "$AWS_S3_BUCKET/planet/full-history/$STATEFILE" .
            PBFCloudPath=$(tail -n +1 "$STATEFILE")
            aws s3 cp "$PBFCloudPath" "$PBFFILE"
        elif [ "$CLOUDPROVIDER" == "gcp" ]; then
            # Get the state.txt file from GS
            gsutil cp "$GCP_STORAGE_BUCKET/planet/full-history/$STATEFILE" .
            PBFCloudPath=$(tail -n +1 "$STATEFILE")
            gsutil cp "$PBFCloudPath" "$PBFFILE"
        fi
    fi
}

function uploadExpiredFiles() {
    ### Upload the expired files to the cloud provider
    for file in $(find $IMPOSM3_EXPIRE_DIR -type f -cmin -1); do
        bucketFile=${file#*"$WORKDIR"}
        echo $(date +%F_%H:%M:%S)":" $file
        # AWS
        if [ "$CLOUDPROVIDER" == "aws" ]; then
            aws s3 cp $file ${AWS_S3_BUCKET}/${BUCKET_IMPOSM_FOLDER}${bucketFile} --acl public-read
        fi
        # Google Storage
        if [ "$CLOUDPROVIDER" == "gcp" ]; then
            gsutil cp -a public-read $file ${GCP_STORAGE_BUCKET}${BUCKET_IMPOSM_FOLDER}${bucketFile}
        fi
    done
}

function updateData() {
    ### Update the DB with the new data form minute replication
    if [ "$OVERWRITE_STATE" = "true" ]; then
        rm $DIFF_DIR/last.state.txt
    fi

    # Check if last.state.txt exists
    if [ -f "$DIFF_DIR/last.state.txt" ]; then
        echo "Exist... $DIFF_DIR/last.state.txt"
    else
        # Create last.state.txt file with REPLICATION_URL and SEQUENCE_NUMBER from env vars
        echo "timestamp=0001-01-01T00\:00\:00Z 
        sequenceNumber=$SEQUENCE_NUMBER
        replicationUrl=$REPLICATION_URL" >$DIFF_DIR/last.state.txt
    fi

    # Check if the limit file exists
    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm run -config "$WORKDIR/config.json" -expiretiles-dir "$IMPOSM3_EXPIRE_DIR" &
    else
        imposm run -config "$WORKDIR/config.json" -limitto "$WORKDIR/$LIMITFILE" -expiretiles-dir "$IMPOSM3_EXPIRE_DIR" &
    fi

    while true; do
        echo "Upload expired files... $(date +%F_%H-%M-%S)"
        uploadExpiredFiles
        sleep 1m
    done
}

function importData() {
    ### Import the PBF  and Natural Earth files to the DB
    echo "Execute the missing functions"
    psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" -a -f config/postgis_helpers.sql

    echo "Import Natural Earth..."
    ./scripts/natural_earth.sh

    echo "Import OSM Land..."
    ./scripts/osm_land.sh

    echo "Import PBF file..."
    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm import \
            -config $WORKDIR/config.json \
            -read $PBFFILE \
            -write \
            -diff -cachedir $CACHE_DIR -diffdir $DIFF_DIR
    else
        wget $TILER_IMPORT_LIMIT -O $WORKDIR/$LIMITFILE
        imposm import \
            -config $WORKDIR/config.json \
            -read $PBFFILE \
            -write \
            -diff -cachedir $CACHE_DIR -diffdir $DIFF_DIR \
            -limitto $WORKDIR/$LIMITFILE
    fi

    imposm import \
        -config $WORKDIR/config.json \
        -deployproduction

    # These index will help speed up tegola tile generation
    psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" -a -f config/postgis_index.sql

    touch $INIT_FILE

    # Update the DB
    updateData
}

echo "Connecting to $POSTGRES_HOST DB"
flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    echo "Check if $INIT_FILE exists"
    if ([[ -f $INIT_FILE ]]); then
        echo "Update the DB with osm data"
        updateData
    else
        echo "Import PBF data to DB"
        getData
        if [ -f $PBFFILE ]; then
            echo "Start importing the data"
            importData
        fi
    fi
done
