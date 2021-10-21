#!/usr/bin/env bash
WORKDIR=/apps
DATA_DIR=$WORKDIR/data
UPDATE_DIR=$DATA_DIR/update
DOWNLOAD_DIR=$DATA_DIR/download

mkdir -p $UPDATE_DIR
mkdir -p $DATA_DIR
mkdir -p $DOWNLOAD_DIR
mkdir -p $UPDATE_DIR/planet/

##################################################################
### Update dir values in taginfo-config.json
##################################################################

grep -v '^ *//' $WORKDIR/taginfo/taginfo-config-example.json |
    jq '.logging.directory                   = "'$UPDATE_DIR'/log"' |
    jq '.paths.download_dir                  = "'$UPDATE_DIR'/download"' |
    jq '.paths.bin_dir                       = "'$WORKDIR'/taginfo-tools/build/src"' |
    jq '.sources.db.planetfile               = "'$UPDATE_DIR'/planet/planet.osm.pbf"' |
    jq '.sources.chronology.osm_history_file = "'$UPDATE_DIR'/planet/history-planet.osh.pbf"' |
    jq '.sources.db.bindir                   = "'$UPDATE_DIR'/build/src"' |
    jq '.paths.data_dir                      = "'$DATA_DIR'"' \
        >$WORKDIR/taginfo-config.json

# ##################################################################
# ### Download OSM planet replication and full-history files
# ##################################################################

[ ! -f $UPDATE_DIR/planet/planet.osm.pbf ] && wget --no-check-certificate -O $UPDATE_DIR/planet/planet.osm.pbf $URL_PLANET_FILE
[ ! -f $UPDATE_DIR/planet/history-planet.osh.pbf ] && wget --no-check-certificate -O $UPDATE_DIR/planet/history-planet.osh.pbf $URL_HISTORY_PLANET_FILE

# ##################################################################
# ### Update local DB
# ##################################################################

# The follow line is requiered to avoid issue: require cannot load such file -- sqlite3 
sed -i -e 's/run_ruby "$SRCDIR/update_characters.rb"/ruby "$SRCDIR/update_characters.rb"/g' $WORKDIR/taginfo/sources/db/update.sh
$WORKDIR/taginfo/sources/update_all.sh $UPDATE_DIR

# ##################################################################
# ### Start taginfo service
# ##################################################################

mv $UPDATE_DIR/*/taginfo-*.db $DATA_DIR/
mv $UPDATE_DIR/taginfo-*.db $DATA_DIR/
mv $UPDATE_DIR/download/* $DOWNLOAD_DIR

cd $WORKDIR/taginfo/web && bundle exec rackup --host 0.0.0.0 -p 4567
