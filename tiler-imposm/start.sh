#!/bin/bash
set -e
mkdir -p /tmp
stateFile="state.txt"
PBFFile="osm.pbf"
flag=true

# Creating a gcloud-service-key to authenticate the gcloud
if [ $STORAGE == "GS" ]; then
    echo $GCLOUD_SERVICE_KEY | base64 --decode --ignore-garbage > gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud --quiet components update
    /root/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file gcloud-service-key.json
    /root/google-cloud-sdk/bin/gcloud config set project $GCLOUD_PROJECT
fi

function getData () {
    # Import from pubic url, ussualy it come from osm
    if [ $IMPORT_PROM == "osm" ]; then 
        wget $TILER_IMPORT_PBF_URL -O $PBFFile
    fi

    if [ $IMPORT_PROM == "osmseed" ]; then 
        if [ $STORAGE == "S3" ]; then 
            # Get the state.txt file from S3
            aws s3 cp $S3_OSM_PATH/planet/full-history/$stateFile .
            PBFCloudPath=$(tail -n +1 $stateFile)
            aws s3 cp $PBFCloudPath $PBFFile
        fi
        # Google storage
        if [ $STORAGE == "GS" ]; then 
            # Get the state.txt file from GS
            gsutil cp $GS_OSM_PATH/planet/full-history/$stateFile .
            echo "gsutil cp $GS_OSM_PATH/planet/full-history/$stateFile ."
            PBFCloudPath=$(tail -n +1 $stateFile)
            echo $PBFCloudPath
            gsutil cp $PBFCloudPath $PBFFile
        fi
    fi
}

function importData () {
    echo "Execute the missing functions"
    psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" -a -f postgis_helpers.sql
    psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" -a -f postgis_index.sql
    echo "Import Natural Earth"
    ./scripts/natural_earth.sh
    echo "Impor OMS Land"
    ./scripts/osm_land.sh
    echo "Import PBF file"
    imposm import -connection postgis://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB -mapping imposm3.json -read $PBFFile -write
    imposm import -connection postgis://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB -mapping imposm3.json -deployproduction
}

while "$flag" = true; do
    pg_isready -h $GIS_POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
        # Change flag to false to stop ping the DB
        flag=false
        hasData=$(psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" \
        -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" | sed -n 3p | sed 's/ //g')
        # After import there are more than 70 tables
        if [ $hasData  \> 70 ]; then
            echo "Update the DB with osm data"
        else
            echo "Import PBF data to DB"
            getData
            if [ -f $PBFFile ]; then
                echo "Start importing the data"
                importData
            fi
        fi
done
