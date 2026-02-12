#!/usr/bin/env bash
# set -euo pipefail
WORKDIR=/usr/src/app
DATADIR=/usr/src/app/data
DATA_OHM_DOWNLOAD=/osm/planet/var
mkdir -p "$DATADIR/update/log" "$DATA_OHM_DOWNLOAD"

updates_source_code() {
    [ ! -z "$TAGINFO_PROJECT_REPO" ] && \
        sed -i "s|https://github.com/taginfo/taginfo-projects.git|$TAGINFO_PROJECT_REPO|g" $WORKDIR/taginfo/sources/projects/update.sh
}

download_planet_files() {
    wget -q -O state.planet.txt --no-check-certificate "$URL_PLANET_FILE_STATE" && URL_PLANET_FILE=$(cat state.planet.txt)
    wget -q -O state.history.txt --no-check-certificate "$URL_HISTORY_PLANET_FILE_STATE" && URL_HISTORY_PLANET_FILE=$(cat state.history.txt)

    local remote_md5_planet remote_md5_history
    remote_md5_planet=$(echo -n "$URL_PLANET_FILE" | md5sum | awk '{print $1}')
    remote_md5_history=$(echo -n "$URL_HISTORY_PLANET_FILE" | md5sum | awk '{print $1}')

    # Download planet file if it doesn't exist or the URL (md5) changed
    local planet_file="$DATA_OHM_DOWNLOAD/current-planet.osm.pbf"
    local planet_md5_file="$DATA_OHM_DOWNLOAD/current-planet.osm.pbf.md5"
    if [ ! -f "$planet_file" ] || [ ! -f "$planet_md5_file" ] || [ "$(cat "$planet_md5_file")" != "$remote_md5_planet" ]; then
        echo "Downloading planet file from $URL_PLANET_FILE ..."
        wget -O "$planet_file" "$URL_PLANET_FILE" && echo "$remote_md5_planet" > "$planet_md5_file"
    else
        echo "Planet file is up to date, skipping download."
    fi

    # Download history planet file if it doesn't exist or the URL (md5) changed
    local history_file="$DATA_OHM_DOWNLOAD/current-history-planet.osh.pbf"
    local history_md5_file="$DATA_OHM_DOWNLOAD/current-history-planet.osh.pbf.md5"
    if [ ! -f "$history_file" ] || [ ! -f "$history_md5_file" ] || [ "$(cat "$history_md5_file")" != "$remote_md5_history" ]; then
        echo "Downloading history planet file from $URL_HISTORY_PLANET_FILE ..."
        wget -O "$history_file" "$URL_HISTORY_PLANET_FILE" && echo "$remote_md5_history" > "$history_md5_file"
    else
        echo "History planet file is up to date, skipping download."
    fi
}


if [ ! -z "${OVERWRITE_CONFIG_URL}" ]; then
    echo "Downloading config from ${OVERWRITE_CONFIG_URL}"
    wget -q "$OVERWRITE_CONFIG_URL" -O /usr/src/app/taginfo-config.json || echo "Warning: Failed to download config from ${OVERWRITE_CONFIG_URL}"
fi

updates_source_code

export BUNDLE_GEMFILE=$WORKDIR/taginfo/Gemfile
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
if [ -n "$AWS_S3_BUCKET" ]; then
    if aws s3 ls "s3://$AWS_S3_BUCKET/taginfo" >/dev/null 2>&1; then
        aws s3 sync "$DATADIR/" "s3://$AWS_S3_BUCKET/taginfo/" --exclude "*" --include "*.db" || echo "Warning: S3 sync failed (revisa credenciales si usas AWS)"
    else
        echo "Warning: No se pudo acceder a s3://$AWS_S3_BUCKET/taginfo (credenciales o bucket inexistente)"
    fi
fi
