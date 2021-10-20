#!/usr/bin/env bash

echo "start....."

WORKDIR=/apps

DATA_DIR=$WORKDIR/data
UPDATE_DIR=$DATA_DIR/update
DOWNLOAD_DIR=$DATA_DIR/download

mkdir -p $UPDATE_DIR
mkdir -p $DATA_DIR
mkdir -p $DOWNLOAD_DIR

##################################################################
### Update dir values in taginfo-config.json
##################################################################

grep -v '^ *//' $WORKDIR/taginfo/taginfo-config-example.json |
    jq '.logging.directory                   = "'$UPDATE_DIR'/log"' |
    jq '.paths.download_dir                  = "'$UPDATE_DIR'/download"' |
    jq '.paths.bin_dir                       = "'$UPDATE_DIR'/build/src"' |
    jq '.sources.db.planetfile               = "'$UPDATE_DIR'/planet/data.osm.pbf"' |
    jq '.sources.chronology.osm_history_file = "'$UPDATE_DIR'/planet/history-planet.osm.pbf"' |
    jq '.sources.db.bindir                   = "'$UPDATE_DIR'/build/src"' |
    jq '.paths.data_dir                      = "'$DATA_DIR'"' \
        >$WORKDIR/taginfo-config.json

cat $WORKDIR/taginfo-config.json

# ##################################################################
# ### Download OSM planet replication and full-history files
# ##################################################################

mkdir -p $UPDATE_DIR/planet/
# URL_PLANET_FILE=https://planet.openhistoricalmap.org.s3.amazonaws.com/planet/planet-200526_0000.osm.pbf
# URL_HISTORY_PLANET_FILE=https://planet.openhistoricalmap.org.s3.amazonaws.com/planet/full-history/history-200526_0000.osm.bz2
URL_PLANET_FILE=http://host.docker.internal:3000/planet-200526_0000.osm.pbf
URL_HISTORY_PLANET_FILE=http://host.docker.internal:3000/history-200526_0000.osm.bz2
wget --no-check-certificate -O $UPDATE_DIR/planet/planet.osm.pbf $URL_PLANET_FILE
wget --no-check-certificate -O $UPDATE_DIR/planet/history-planet.osm.bz2 $URL_HISTORY_PLANET_FILE

# ##################################################################
# ### Update local DB
# ##################################################################

$WORKDIR/taginfo/sources/update_all.sh $UPDATE_DIR

mv $UPDATE_DIR/*/taginfo-*.db $DATA_DIR/
mv $UPDATE_DIR/download/* $DOWNLOAD_DIR

cd $WORKDIR/taginfo/web && bundle exec rackup --host 0.0.0.0 -p 4567
