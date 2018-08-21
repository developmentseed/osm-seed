#!/bin/bash
set -e
# Run the missing functions

FILE='http://download.geofabrik.de/south-america/peru-latest.osm.pbf'
PBF='peru-latest.osm.pbf'
wget -O $PBF $FILE
imposm import -connection postgis://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB -mapping imposm3.json -read $PBF -write
imposm import -connection postgis://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB -mapping imposm3.json -deployproduction

psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" -a -f postgis_helpers.sql
psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" -a -f postgis_index.sql
mkdir -p /tmp