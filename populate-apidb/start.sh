#!/usr/bin/env bash

# Get the data
wget $URL_FILE_TO_IMPORT
file=$(basename $URL_FILE_TO_IMPORT)

function importData () {
    # In case the import file is a PBF
    if [ ${file: -4} == ".pbf" ]; then
        pbfFile=$file
        echo "Importing $pbfFile ..."
        osmosis --read-pbf \
        file=$pbfFile\
        --write-apidb \
        host=$POSTGRES_HOST \
        database=$POSTGRES_DB \
        user=$POSTGRES_USER \
        password=$POSTGRES_PASSWORD \
        validateSchemaVersion=no
    else
        # In case the file is .osm
        # Extract the osm file
        bzip2 -d $file
        osmFile=${file%.*}
        echo "Importing $osmFile ..."
        osmosis --read-xml \
        file=$osmFile  \
        --write-apidb \
        host=$POSTGRES_HOST \
        database=$POSTGRES_DB \
        user=$POSTGRES_USER \
        password=$POSTGRES_PASSWORD \
        validateSchemaVersion=no
    fi
}

flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    importData
done
