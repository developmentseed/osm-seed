#!/usr/bin/env bash
set -e
export VOLUME_DIR=/mnt/data
export PGPASSWORD=$POSTGRES_PASSWORD

# OSMOSIS tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
    echo JAVACMD_OPTIONS=\"-server\" > ~/.osmosis
else
    memory="${MEMORY_JAVACMD_OPTIONS//i}"
    echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" > ~/.osmosis
fi

# Get the data
file=$(basename $URL_FILE_TO_IMPORT)
osmFile=$VOLUME_DIR/$file
[ ! -f $osmFile ] && wget $URL_FILE_TO_IMPORT

function importData () {
    # This is using a osmosis 0.47. TODO: test with osmosis 0.48, and remove the following line
    psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB -c "ALTER TABLE users ADD COLUMN nearby VARCHAR;"
    # In case the import file is a PBF
    if [ ${osmFile: -4} == ".pbf" ]; then
        pbfFile=$osmFile
        echo "Importing $pbfFile ..."
        osmosis --read-pbf \
        file=$pbfFile\
        --write-apidb \
        host=$POSTGRES_HOST \
        database=$POSTGRES_DB \
        user=$POSTGRES_USER \
        password=$POSTGRES_PASSWORD \
        allowIncorrectSchemaVersion=yes \
        validateSchemaVersion=no
    else
        # In case the file is .osm
        # Extract the osm file
        bzip2 -d $osmFile
        osmFile=${osmFile%.*}
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
    # Run required fixes in DB
    psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB -c "select setval('current_nodes_id_seq', (select max(node_id) from nodes));"
    psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB -c "select setval('current_ways_id_seq', (select max(way_id) from ways));"
    psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB -c "select setval('current_relations_id_seq', (select max(relation_id) from relations));"
    # psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB -c "select setval('users_id_seq', (select max(id) from users));"
    # psql -U $POSTGRES_USER -h $POSTGRES_HOST -d $POSTGRES_DB -c "select setval('changesets_id_seq', (select max(id) from changesets));"

}

flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    importData
done
