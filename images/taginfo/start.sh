#!/usr/bin/env bash
# set -euo pipefail
WORKDIR=/usr/src/app
DATADIR=/usr/src/app/data
DATA_OHM_DOWNLOAD=/osm/planet/var
mkdir -p "$DATADIR/update/log" "$DATA_OHM_DOWNLOAD"

updates_source_code() {
    sed -i 's/"env -/"/g' $WORKDIR/taginfo/sources/util.sh
    sed -i '/configure do/a \ \ \ \ set :port, 80' $WORKDIR/taginfo/web/taginfo.rb
    sed -i "/configure do/a \ \ \ \ set :bind, '0.0.0.0'" $WORKDIR/taginfo/web/taginfo.rb
    [ ! -z "$TAGINFO_PROJECT_REPO" ] && \
        sed -i "s|https://github.com/taginfo/taginfo-projects.git|$TAGINFO_PROJECT_REPO|g" $WORKDIR/taginfo/sources/projects/update.sh
    # Fix nil data_until_raw error when database is empty - handle nil case
    sed -i '/data_until_raw = @db.select.*get_first_value/a\        data_until_raw = Time.now.strftime("%Y-%m-%d %H:%M:%S") if data_until_raw.nil?' $WORKDIR/taginfo/web/taginfo.rb
}

download_db_files() {
    [ -z "$TAGINFO_DB_BASE_URL" ] && { echo "Error: TAGINFO_DB_BASE_URL is not set"; return 1; }
    base_url="${TAGINFO_DB_BASE_URL%/}/"
    db_files=("projects-cache.db" "selection.db" "taginfo-chronology.db" "taginfo-db.db" 
              "taginfo-history.db" "taginfo-languages.db" "taginfo-master.db" 
              "taginfo-projects.db" "taginfo-wiki.db" "taginfo-wikidata.db")
    
    echo "Starting download of database files from $base_url"
    downloaded_count=0
    skipped_count=0
    failed_count=0
    
    for db_file in "${db_files[@]}"; do
        if [ -f "$DATADIR/$db_file" ]; then
            echo "Skipping $db_file (already exists)"
            skipped_count=$((skipped_count + 1))
            continue
        fi
        echo "Downloading $db_file from ${base_url}${db_file}"
        if wget -q -O "$DATADIR/$db_file" --no-check-certificate "${base_url}${db_file}" 2>&1; then
            if [ -f "$DATADIR/$db_file" ] && [ -s "$DATADIR/$db_file" ]; then
                echo "Successfully downloaded $db_file"
                downloaded_count=$((downloaded_count + 1))
            else
                echo "Warning: $db_file download failed or file is empty"
                rm -f "$DATADIR/$db_file"
                failed_count=$((failed_count + 1))
            fi
        else
            echo "Error: Failed to download $db_file"
            rm -f "$DATADIR/$db_file"
            failed_count=$((failed_count + 1))
        fi
    done
    
    echo "Download summary: $downloaded_count downloaded, $skipped_count skipped, $failed_count failed"
    
    if [ ! -f "$DATADIR/taginfo-db.db" ]; then
        echo "Error: taginfo-db.db not found after download attempt"
        return 1
    fi
    return 0
}

start_web() {
    # Try to download database files if TAGINFO_DB_BASE_URL is set
    if [ ! -z "$TAGINFO_DB_BASE_URL" ]; then
        echo "TAGINFO_DB_BASE_URL is set, attempting to download database files..."
        download_db_files || echo "Warning: Failed to download some database files, continuing anyway"
    else
        echo "TAGINFO_DB_BASE_URL is not set, skipping database download"
    fi
    
    # Check if main database exists (warn but don't exit - let taginfo handle it)
    if [ ! -f "$DATADIR/taginfo-db.db" ]; then
        echo "Warning: taginfo-db.db not found in $DATADIR"
        echo "Available files in $DATADIR:"
        ls -lh "$DATADIR" 2>/dev/null || echo "Directory is empty or does not exist"
        echo "Taginfo will start but may show errors if database is empty"
    else
        echo "Found taginfo-db.db in $DATADIR"
    fi
    
    # Ensure config file exists
    if [ ! -f "$WORKDIR/taginfo-config.json" ]; then
        echo "Warning: taginfo-config.json not found at $WORKDIR/taginfo-config.json"
    else
        echo "Using config file: $WORKDIR/taginfo-config.json"
    fi
    
    cd $WORKDIR/taginfo
    bundle check || bundle install
    exec bundle exec ruby -r webrick web/taginfo.rb
}

download_planet_files() {
    wget -q -O state.planet.txt --no-check-certificate "$URL_PLANET_FILE_STATE" && URL_PLANET_FILE=$(cat state.planet.txt)
    wget -q -O state.history.txt --no-check-certificate "$URL_HISTORY_PLANET_FILE_STATE" && URL_HISTORY_PLANET_FILE=$(cat state.history.txt)

    # Download planet file
    if [ ! -f "$DATA_OHM_DOWNLOAD/current-planet.osm.pbf" ]; then
        wget -O "$DATA_OHM_DOWNLOAD/current-planet.osm.pbf" "$URL_PLANET_FILE"
    fi
    # Download history planet file
    if [ ! -f "$DATA_OHM_DOWNLOAD/current-history-planet.osh.pbf" ]; then
        wget -O "$DATA_OHM_DOWNLOAD/current-history-planet.osh.pbf" "$URL_HISTORY_PLANET_FILE"
    fi
}

ACTION=$1
# Download config file if OVERWRITE_CONFIG_URL is set
if [ ! -z "${OVERWRITE_CONFIG_URL}" ]; then
    echo "Downloading config from ${OVERWRITE_CONFIG_URL}"
    wget -q "$OVERWRITE_CONFIG_URL" -O /usr/src/app/taginfo-config.json || echo "Warning: Failed to download config from ${OVERWRITE_CONFIG_URL}"
fi
# Ensure config file exists (use default if not downloaded)
if [ ! -f "/usr/src/app/taginfo-config.json" ]; then
    echo "Warning: taginfo-config.json not found, using default from Dockerfile"
fi
updates_source_code

if [ "$ACTION" = "web" ]; then
    [ "${FETCH_DB_FILES:-true}" = "true" ] && [ ! -z "$TAGINFO_DB_BASE_URL" ] && \
        (while true; do download_db_files; sleep "${INTERVAL_DOWNLOAD_DATA:-3600}"; done) &
    start_web
elif [ "$ACTION" = "data" ]; then

    set -x
    download_planet_files
    cd $WORKDIR/taginfo
    bundle check || bundle install
    cd sources/
    ./update_all.sh $DATADIR
    db/update.sh $DATADIR
    master/update.sh $DATADIR
    projects/update.sh $DATADIR
    cp $DATADIR/selection.db $DATADIR/../selection.db
    chronology/update.sh $DATADIR
    wikidata/update.sh $DATADIR
    # wiki/update.sh $DATADIR
    sw/update.sh $DATADIR
    languages/update.sh $DATADIR
    ./update_all.sh $DATADIR
    find "$DATADIR" -name "*.db" -type f -exec mv {} "$DATADIR/" \; 2>/dev/null || true
    [ ! -z "$AWS_S3_BUCKET" ] && ! aws s3 ls "s3://$AWS_S3_BUCKET/taginfo" 2>&1 | grep -q 'An error occurred' && \
        aws s3 sync "$DATADIR/" "s3://$AWS_S3_BUCKET/taginfo/" --exclude "*" --include "*.db"
fi
