#!/usr/bin/env bash
# set -euo pipefail
WORKDIR=/usr/src/app
DATADIR=/usr/src/app/data
DATADOWNLOAD=/osm/planet/var
mkdir -p "$DATADIR/update/log" "$DATADOWNLOAD"

updates_source_code() {
    sed -i 's/"env -/"/g' $WORKDIR/taginfo/sources/util.sh
    sed -i '/configure do/a \ \ \ \ set :port, 80' $WORKDIR/taginfo/web/taginfo.rb
    sed -i "/configure do/a \ \ \ \ set :bind, '0.0.0.0'" $WORKDIR/taginfo/web/taginfo.rb
    [ ! -z "$TAGINFO_PROJECT_REPO" ] && \
        sed -i "s|https://github.com/taginfo/taginfo-projects.git|$TAGINFO_PROJECT_REPO|g" $WORKDIR/taginfo/sources/projects/update.sh
}

download_db_files() {
    [ -z "$TAGINFO_DB_BASE_URL" ] && return 1
    base_url="${TAGINFO_DB_BASE_URL%/}/"
    db_files=("projects-cache.db" "selection.db" "taginfo-chronology.db" "taginfo-db.db" 
              "taginfo-history.db" "taginfo-languages.db" "taginfo-master.db" 
              "taginfo-projects.db" "taginfo-wiki.db" "taginfo-wikidata.db")
    for db_file in "${db_files[@]}"; do
        [ -f "$DATADIR/$db_file" ] && continue
        echo "Downloading $db_file from $base_url/$db_file"
        wget -q -O "$DATADIR/$db_file" --no-check-certificate "${base_url}${db_file}" || rm -f "$DATADIR/$db_file"
    done
    [ ! -f "$DATADIR/taginfo-db.db" ] && { echo "Error: taginfo-db.db not found after download"; return 1; }
    return 0
}

start_web() {
    [ ! -f "$DATADIR/taginfo-db.db" ] && [ ! -z "$TAGINFO_DB_BASE_URL" ] && download_db_files
    [ ! -f "$DATADIR/taginfo-db.db" ] && { echo "Error: taginfo-db.db not found"; exit 1; }
    cd $WORKDIR/taginfo
    bundle check || bundle install
    exec bundle exec ruby -r webrick web/taginfo.rb
}

ACTION=$1
[ ! -z "${OVERWRITE_CONFIG_URL}" ] && wget -q "$OVERWRITE_CONFIG_URL" -O /usr/src/app/taginfo-config.json
updates_source_code

if [ "$ACTION" = "web" ]; then
    [ "${FETCH_DB_FILES:-true}" = "true" ] && [ ! -z "$TAGINFO_DB_BASE_URL" ] && \
        (while true; do download_db_files; sleep "${INTERVAL_DOWNLOAD_DATA:-3600}"; done) &
    start_web
elif [ "$ACTION" = "data" ]; then
    download_planet_files() {
        if [ ! -z "$URL_PLANET_FILE_STATE" ] && [ ! -f "state.planet.txt" ]; then
            wget -q -O state.planet.txt --no-check-certificate "$URL_PLANET_FILE_STATE" && \
            URL_PLANET_FILE=$(cat state.planet.txt)
        elif [ -f "state.planet.txt" ]; then
            URL_PLANET_FILE=$(cat state.planet.txt)
        fi
        if [ ! -z "$URL_HISTORY_PLANET_FILE_STATE" ] && [ ! -f "state.history.txt" ]; then
            wget -q -O state.history.txt --no-check-certificate "$URL_HISTORY_PLANET_FILE_STATE" && \
            URL_HISTORY_PLANET_FILE=$(cat state.history.txt)
        elif [ -f "state.history.txt" ]; then
            URL_HISTORY_PLANET_FILE=$(cat state.history.txt)
        fi
        if [ ! -z "$URL_PLANET_FILE" ]; then
            if [ -f "$DATADOWNLOAD/current-planet.osm.pbf" ]; then
                echo "Planet file already exists, skipping download"
            else
                echo "Downloading planet file from $URL_PLANET_FILE"
                wget -O "$DATADOWNLOAD/current-planet.osm.pbf" "$URL_PLANET_FILE"
            fi
        fi
        if [ ! -z "$URL_HISTORY_PLANET_FILE" ]; then
            if [ -f "$DATADOWNLOAD/current-history-planet.osh.pbf" ]; then
                echo "History planet file already exists, skipping download"
            else
                echo "Downloading history planet file from $URL_HISTORY_PLANET_FILE"
                wget -O "$DATADOWNLOAD/current-history-planet.osh.pbf" "$URL_HISTORY_PLANET_FILE"
            fi
        fi
    }
    set -x
    download_planet_files
    cd $WORKDIR/taginfo
    bundle check || bundle install
    cd sources/
    ./update_all.sh $DATADIR
    db/update.sh $DATADIR
    master/update.sh $DATADIR
    projects/update.sh $DATADIR
    chronology/update.sh $DATADIR
    ./update_all.sh $DATADIR
    find "$DATADIR" -name "*.db" -type f -exec mv {} "$DATADIR/" \; 2>/dev/null || true
    [ ! -z "$AWS_S3_BUCKET" ] && ! aws s3 ls "s3://$AWS_S3_BUCKET/taginfo" 2>&1 | grep -q 'An error occurred' && \
        aws s3 sync "$DATADIR/" "s3://$AWS_S3_BUCKET/taginfo/" --exclude "*" --include "*.db"
fi
