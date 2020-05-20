#!/bin/bash
set -e
mkdir -p /tmp
stateFile="state.txt"
PBFFile="osm.pbf"
limitFile="limitFile.geojson"
flag=true

# directories to keep the imposm's cache for updating the db
cachedir="/mnt/data/cachedir"
mkdir -p $cachedir
diffdir="/mnt/data/diff"
mkdir -p $diffdir

# Create config file to set variable  for imposm
echo "{" > config.json
echo "\"cachedir\": \"$cachedir\","  >> config.json
echo "\"diffdir\": \"$diffdir\","  >> config.json
echo "\"connection\": \"postgis://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB\"," >> config.json
echo "\"mapping\": \"imposm3.json\","  >> config.json
echo "\"replication_url\": \"$REPLICATION_URL\""  >> config.json
echo "}" >> config.json

function getData () {
    # Import from pubic url, ussualy it come from osm
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

function updateData(){
    # Before updating lets overWrite the last.state.txt file
    echo "timestamp=0001-01-01T00\:00\:00Z
    sequenceNumber=$SEQUENCE_NUMBER
    replicationUrl=$REPLICATION_URL" > $diffdir/last.state.txt

    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm run -config config.json -cachedir $cachedir -diffdir $diffdir &
        while true
        do 
            echo "Updating...$(date +%F_%H-%M-%S)"
            sleep 1m
        done
    else
        imposm run -config config.json -cachedir $cachedir -diffdir $diffdir -limitto /mnt/data/$limitFile &
        while true
        do 
            echo "Updating...$(date +%F_%H-%M-%S)"
            sleep 1m
        done
    fi
}

function importData () {
    echo "Execute the missing functions"
    psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" -a -f postgis_helpers.sql
    echo "Import Natural Earth"
    ./scripts/natural_earth.sh
    echo "Import OSM Land"
    ./scripts/osm_land.sh
    echo "Import PBF file"

    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm import \
        -config config.json \
        -read $PBFFile \
        -write \
        -diff -cachedir $cachedir -diffdir $diffdir
    else
        wget $TILER_IMPORT_LIMIT -O /mnt/data/$limitFile
        imposm import \
        -config config.json \
        -read $PBFFile \
        -write \
        -diff -cachedir $cachedir -diffdir $diffdir \
        -limitto /mnt/data/$limitFile
    fi

    imposm import \
    -config config.json \
    -deployproduction
    # -diff -cachedir $cachedir -diffdir $diffdir

    # These index will help speed up tegola tile generation
    psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB" -a -f postgis_index.sql

    # Update the DB
    updateData
}


echo "Connecting... to postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB"

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
