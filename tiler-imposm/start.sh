#!/bin/bash
set -e
mkdir -p /tmp

FILE='http://download.geofabrik.de/south-america/peru-latest.osm.pbf'
PBF='peru-latest.osm.pbf'
flag=true
function importData () {
    echo "Execute the missing functions"
    psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" -a -f postgis_helpers.sql
    psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" -a -f postgis_index.sql
    echo "Import Natural Earth"
    ./scripts/natural_earth.sh
    echo "Impor OMS Land"
    ./scripts/osm_land.sh
    echo "Import PBF file"
    wget -O $PBF $FILE
    imposm import -connection postgis://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB -mapping imposm3.json -read $PBF -write
    imposm import -connection postgis://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB -mapping imposm3.json -deployproduction
}

while "$flag" = true; do
    pg_isready -h $GIS_POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
        # Change flag to false to stop ping the DB
        flag=false
        hasData=$(psql "postgresql://$GIS_POSTGRES_USER:$GIS_POSTGRES_PASSWORD@$GIS_POSTGRES_HOST/$GIS_POSTGRES_DB" \
        -c "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public'" | sed -n 3p | sed 's/ //g')
        # After import there are more than 70 tables
        if [ $hasData  \> 70 ]; then
            echo "Update the DB with osm data"
        else
            echo "Start importing the data"
            importData
        fi
done
