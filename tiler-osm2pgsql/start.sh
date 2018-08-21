#!/bin/bash
set -e
PG_PORT=5432
FILE='http://download.geofabrik.de/south-america/peru-latest.osm.pbf'
PBF='peru-latest.osm.pbf'
# wget -O $PBF $FILE

# This will download the natural earth and insert it into PostGIS 
# ./scripts/natural_earth.sh

# PGPASSWORD=$GIS_POSTGRES_PASSWORD \
# osm2pgsql --create --slim --cache 2000 \
#     --host $GIS_POSTGRES_HOST \
#     --database $GIS_POSTGRES_DB \
#     --username $GIS_POSTGRES_USER \
#     --port $PG_PORT \
#     $PBF
# while : ; do
#     importosm
#     [ $LOOP -eq 0 ] && exit $?
#     sleep $LOOP || exit
# done