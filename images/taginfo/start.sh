#!/usr/bin/env bash
set -x
WORKDIR=/usr/src/app
DATADIR=/usr/src/app/data
DATADOWNLOAD=/osm/planet/var
mkdir -p $DATADIR/
mkdir -p $DATADOWNLOAD/
mkdir -p $DATADIR/update/log/

updates_source_code() {
    echo "Update...Procesor source code"
    sed -i 's/"env -/"/g' $WORKDIR/taginfo/sources/util.sh
    sed -i '/configure do/a \ \ \ \ set :port, 80' $WORKDIR/taginfo/web/taginfo.rb
    sed -i "/configure do/a \ \ \ \ set :bind, '0.0.0.0'" $WORKDIR/taginfo/web/taginfo.rb
    # Function to replace the projects repo to get the projects information
    TAGINFO_PROJECT_REPO=${TAGINFO_PROJECT_REPO//\//\\/}
    sed -i -e 's/https:\/\/github.com\/taginfo\/taginfo-projects.git/'$TAGINFO_PROJECT_REPO'/g' $WORKDIR/taginfo/sources/projects/update.sh
}

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
    wget -O $DATADOWNLOAD/current-planet.osm.pbf $URL_PLANET_FILE
    wget -O $DATADOWNLOAD/current-history-planet.osh.pbf $URL_HISTORY_PLANET_FILE
}

process_data() {
    download_planet_files
    cd $WORKDIR/taginfo/sources/
    ./update_all.sh $DATADIR
    db/update.sh $DATADIR
    master/update.sh $DATADIR
    projects/update.sh $DATADIR
    cp $DATADIR/selection.db $DATADIR/../
    # languages/update.sh $DATADIR
    # wiki/update.sh $DATADIR
    # wikidata/update.sh $DATADIR
    chronology/update.sh $DATADIR
    ./update_all.sh $DATADIR
    # Move database files from subdirectories to main data directory
    aws s3 sync $DATADIR/ s3://$AWS_S3_BUCKET/taginfo/$ENVIRONMENT/  --exclude "*" --include "*.db"
}

# Compress files to download
compress_files() {
    mkdir -p download
    for file in data/*; do
        bzip2 -k -9 -c "$file" > "download/$(basename "$file").bz2"
    done
}

download_db_files() {
    local base_url=$1
    
    if [ -z "$base_url" ]; then
        echo "Error: URL base is required for download_db_files"
        return 1
    fi
    
    # Ensure base_url ends with /
    if [[ ! "$base_url" =~ /$ ]]; then
        base_url="${base_url}/"
    fi
    
    # List of SQLite database files to download
    local db_files=(
        "projects-cache.db"
        "selection.db"
        "taginfo-chronology.db"
        "taginfo-db.db"
        "taginfo-history.db"
        "taginfo-languages.db"
        "taginfo-master.db"
        "taginfo-projects.db"
        "taginfo-wiki.db"
        "taginfo-wikidata.db"
    )
    
    echo "Downloading SQLite database files from: $base_url"
    
    for db_file in "${db_files[@]}"; do
        local file_url="${base_url}${db_file}"
        local output_path="${DATADIR}/${db_file}"
        
        echo "Downloading: $db_file"
        if wget -q --show-progress -O "$output_path" --no-check-certificate "$file_url"; then
            echo "Successfully downloaded: $db_file"
        else
            echo "Warning: Failed to download $db_file from $file_url"
            # Continue with other files even if one fails
        fi
    done
    
    echo "Database files download completed"
}

sync_latest_db_version() {
    while true; do
        sleep "$INTERVAL_DOWNLOAD_DATA"
        download_db_files "$TAGINFO_DB_BASE_URL"
    done
}

start_web() {
    echo "Start...Taginfo web service"
    download_db_files "$TAGINFO_DB_BASE_URL"
    cd $WORKDIR/taginfo/web && ./taginfo.rb & sync_latest_db_version
}

ACTION=$1
# Overwrite the config file
[[ ! -z ${OVERWRITE_CONFIG_URL} ]] && wget $OVERWRITE_CONFIG_URL -O /usr/src/app/taginfo-config.json
updates_source_code
if [ "$ACTION" = "web" ]; then
    start_web
    elif [ "$ACTION" = "data" ]; then
    process_data
fi
