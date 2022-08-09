#!/usr/bin/env bash

WORKDIR=/apps
DATA_DIR=$WORKDIR/data
UPDATE_DIR=$DATA_DIR/update
DOWNLOAD_DIR=$DATA_DIR/download

set_taginfo_config() {
    echo "Setting up...$WORKDIR/taginfo-config.json"
    # Update dir values in taginfo-config.json
    grep -v '^ *//' $WORKDIR/taginfo/taginfo-config-example.json |
        jq '.logging.directory                   = "'$UPDATE_DIR'/log"' |
        jq '.paths.download_dir                  = "'$UPDATE_DIR'/download"' |
        jq '.paths.bin_dir                       = "'$WORKDIR'/taginfo-tools/build/src"' |
        jq '.sources.db.planetfile               = "'$UPDATE_DIR'/planet/planet.osm.pbf"' |
        jq '.sources.chronology.osm_history_file = "'$UPDATE_DIR'/planet/history-planet.osh.pbf"' |
        jq '.sources.db.bindir                   = "'$UPDATE_DIR'/build/src"' |
        jq '.paths.data_dir                      = "'$DATA_DIR'"' \
            >$WORKDIR/taginfo-config.json
    
    # languages wiki databases will be downloaded from OSM
    [[ ! -z $DOWNLOAD_DB+z} ]] && jq --arg a "${DOWNLOAD_DB}" '.sources.download = $a' $WORKDIR/taginfo-config.json >tmp.json && mv tmp.json $WORKDIR/taginfo-config.json

    # Update instance values in taginfo-config.json
    python3 overwrite_config.py -u $OVERWRITE_CONFIG_URL -f $WORKDIR/taginfo-config.json

}

updates_create_db() {
    local CREATE_DB="$1"
    [[ ! -z $CREATE_DB+z} ]] && jq --arg a "${CREATE_DB}" '.sources.create = $a' $WORKDIR/taginfo-config.json >tmp.json && mv tmp.json $WORKDIR/taginfo-config.json
}

updates_source_code() {
    echo "Update...Procesor source code"
    # Function to replace the projects repo to get the projects information
    TAGINFO_PROJECT_REPO=${TAGINFO_PROJECT_REPO//\//\\/}
    sed -i -e 's/https:\/\/github.com\/taginfo\/taginfo-projects.git/'$TAGINFO_PROJECT_REPO'/g' $WORKDIR/taginfo/sources/projects/update.sh
    # The follow line is requiered to avoid sqlite3 issues
    sed -i -e 's/run_ruby "$SRCDIR\/update_characters.rb"/ruby "$SRCDIR\/update_characters.rb"/g' $WORKDIR/taginfo/sources/db/update.sh
    sed -i -e 's/run_ruby "$SRCDIR\/import.rb"/ruby "$SRCDIR\/import.rb"/g' $WORKDIR/taginfo/sources/projects/update.sh
    sed -i -e 's/run_ruby "$SRCDIR\/parse.rb"/ruby "$SRCDIR\/parse.rb"/g' $WORKDIR/taginfo/sources/projects/update.sh
    sed -i -e 's/run_ruby "$SRCDIR\/get_icons.rb"/ruby "$SRCDIR\/get_icons.rb"/g' $WORKDIR/taginfo/sources/projects/update.sh
}

download_planet_files() {
    mkdir -p $UPDATE_DIR/planet/
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
    echo "Downloading...$URL_PLANET_FILE"
    wget -q -O $UPDATE_DIR/planet/planet.osm.pbf --no-check-certificate - $URL_PLANET_FILE
    echo "Downloading...$URL_HISTORY_PLANET_FILE"
    wget -q -O $UPDATE_DIR/planet/history-planet.osh.pbf --no-check-certificate - $URL_HISTORY_PLANET_FILE
    rm state.planet.txt
    rm state.history.txt
}

update() {
    echo "Update...sqlite databases at $(date +%Y-%m-%d:%H-%M)"
    # Download OSM planet replication and full-history files
    download_planet_files
    # In order to make it work we need to pass first one by one the creation and then all of them "db projects chronology"
    for db in $CREATE_DB; do
        echo "Update...taginfo-$db.db"
        updates_create_db $db
        $WORKDIR/taginfo/sources/update_all.sh $UPDATE_DIR
    done
    echo "Update...$CREATE_DB"
    updates_create_db $CREATE_DB
    $WORKDIR/taginfo/sources/update_all.sh $UPDATE_DIR
    # Copy db files into data folder
    cp $UPDATE_DIR/*/taginfo-*.db $DATA_DIR/
    cp $UPDATE_DIR/taginfo-*.db $DATA_DIR/
    # Link to download db zip files
    chmod a=r $UPDATE_DIR/download
    ln -sf $UPDATE_DIR/download $WORKDIR/taginfo/web/public/download
}

start_web() {
    echo "Start...Taginfo web service"
    cd $WORKDIR/taginfo/web && bundle exec rackup --host 0.0.0.0 -p 80
}

continuous_update() {
    while true; do
        update
        sleep $TIME_UPDATE_INTERVAL
    done
}

main() {
    set_taginfo_config
    updates_source_code
    # Check if db files are store in the $DATA_DIR in order to start the service or start procesing the file
    NUM_DB_FILES=$(ls $DATA_DIR/*.db | wc -l)
    if [ $NUM_DB_FILES -lt 7 ]; then
        update
    fi
    start_web
    # continuous_update
}
main
