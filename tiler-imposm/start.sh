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
echo "\"connection\": \"postgis://$TEGOLA_POSTGRES_USER:$TEGOLA_POSTGRES_PASSWORD@$TEGOLA_POSTGRES_HOST/$TEGOLA_POSTGRES_DB\"," >> config.json
echo "\"mapping\": \"$IMPOSM_MAPPING_FILE\""  >> config.json
echo "}" >> config.json

function getData () {
    # Import from pubic url, ussualy it come from osm
    if [ $IMPOSM_IMPORT_FROM == "osm" ]; then 
        wget $IMPOSM_IMPORT_PBF_URL -O $PBFFile
    fi

    if [ $IMPOSM_IMPORT_FROM == "osmseed" ]; then 
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

function updateData () {
    if [ -z "$TILER_IMPORT_LIMIT" ]; then
        imposm run -config config.json -cachedir $cachedir -diffdir $diffdir &
        while true
        do 
            echo "Updating...$(date +%F_%H-%M-%S)"
            sleep 1m
        done
    else
        echo "fucker" & imposm run -config config.json -cachedir $cachedir -diffdir $diffdir -limitto /mnt/data/$limitFile &
        while true
        do 
            echo "Updating...$(date +%F_%H-%M-%S)"
            sleep 1m
        done
    fi
}

function initializeDatabase () {
    echo "Execute the missing functions"
    psql "postgresql://$TEGOLA_POSTGRES_USER:$TEGOLA_POSTGRES_PASSWORD@$TEGOLA_POSTGRES_HOST/$TEGOLA_POSTGRES_DB" -a -f postgis_helpers.sql
    psql "postgresql://$TEGOLA_POSTGRES_USER:$TEGOLA_POSTGRES_PASSWORD@$TEGOLA_POSTGRES_HOST/$TEGOLA_POSTGRES_DB" -a -f postgis_index.sql
    echo "Import Natural Earth"
    ./scripts/natural_earth.sh
    echo "Import OMS Land"
    ./scripts/osm_land.sh
}

function importData () {
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
    # Update the DB
    updateData
}

echo "Connecting... to postgresql://$TEGOLA_POSTGRES_USER:$TEGOLA_POSTGRES_PASSWORD@$TEGOLA_POSTGRES_HOST/$TEGOLA_POSTGRES_DB"

while "$flag" = true; do
    echo "trying to connect to $TEGOLA_POSTGRES_HOST..."
    pg_isready -h $TEGOLA_POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
        # Change flag to false to stop ping the DB
        flag=false
        hasData=$(psql "postgresql://$TEGOLA_POSTGRES_USER:$TEGOLA_POSTGRES_PASSWORD@$TEGOLA_POSTGRES_HOST/$TEGOLA_POSTGRES_DB" \
        -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" | sed -n 3p | sed 's/ //g')

        echo $hasData
        echo $IMPOSM_IMPORT_PBF_URL

        # After import there are more than 70 tables
        if [ $hasData  \> 70 ]; then
            echo "Start importing data to existing database"
            updateData
        else
            echo "Start importing the data"
            initializeDatabase
            if [ -n $IMPOSM_IMPORT_PBF_URL ]; then
                echo "Import PBF data to DB"
                getData
                importData
            fi
        fi
done
