#!/usr/bin/env bash
mkdir -p /osm/planet/var/
sed -i 's/"env -/"/g' /usr/src/app/taginfo/sources/util.sh

download_planet_files() {
    # Check if URL_PLANET_FILE_STATE exist and set URL_PLANET_FILE
    if [[ ${URL_PLANET_FILE_STATE} && ${URL_PLANET_FILE_STATE-x} ]]; then
        wget -q -O state.planet.txt --no-check-certificate - $URL_PLANET_FILE_STATE
        URL_PLANET_FILE=$(cat state.planet.txt)
    fi
    # Check if URL_HISTORY_PLANET_FILE_STATE exist and set URL_HISTORY_PLANET_FILE
    if [[ ${URL_HISTORY_PLANET_FILE_STATE} && ${URL_HISTORY_PLANET_FILE_STATE-x} ]]; then
        wget -q -O state.history.txt --no-check-certificate - $URL_HISTORY_PLANET_FILE_STATE
        URL_HISTORY_PLANET_FILE=$(cat state.history.txt)
    fi
    # Download pbf files
    wget -O /osm/planet/var/current-planet.osm.pbf $URL_PLANET_FILE
    wget -O /osm/planet/var/current-history-planet.osh.pbf $URL_HISTORY_PLANET_FILE
}

process_data() {
    download_planet_files
    cd /usr/src/app/taginfo/sources/ && ./update_all.sh /usr/src/app/data
    mv /usr/src/app/data/taginfo-*.db /usr/src/app/data/
    mv /usr/src/app/data/*/taginfo-*.db /usr/src/app/data/
    # if BUCKET_NAME is set upload data 
    if ! aws s3 ls "s3://$BUCKET_NAME/$ENVIRONMENT" 2>&1 | grep -q 'An error occurred'; then
        aws s3 sync /usr/src/app/data/ s3://$AWS_S3_BUCKET/$ENVIRONMENT/  --exclude "*" --include "*.db"
    fi
}


start_web() {
    echo "Start...Taginfo web service"
    # if BUCKET_NAME is set download data 
    if ! aws s3 ls "s3://$BUCKET_NAME/$ENVIRONMENT" 2>&1 | grep -q 'An error occurred'; then
        aws s3 sync s3://$AWS_S3_BUCKET/$ENVIRONMENT/ /usr/src/app/data/
    fi
    cd /usr/src/app/taginfo/web && ./taginfo.rb
}

ACTION=$1
mkdir -p $DATA_DIR/update/log/
if [ "$ACTION" = "web" ]; then
    start_web
elif [ "$ACTION" = "data" ]; then
    process_data
fi
