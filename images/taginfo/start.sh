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

    # Download planet file
    if [ ! -f "$DATA_OHM_DOWNLOAD/current-planet.osm.pbf" ]; then
        wget -O "$DATA_OHM_DOWNLOAD/current-planet.osm.pbf" "$URL_PLANET_FILE"
    fi
    # Download history planet file
    if [ ! -f "$DATA_OHM_DOWNLOAD/current-history-planet.osh.pbf" ]; then
        wget -O "$DATA_OHM_DOWNLOAD/current-history-planet.osh.pbf" "$URL_HISTORY_PLANET_FILE"
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
