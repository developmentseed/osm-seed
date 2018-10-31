#!/usr/bin/env bash

# OSMOSIS tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
    echo JAVACMD_OPTIONS=\"-server\" > ~/.osmosis
else
    memory="${MEMORY_JAVACMD_OPTIONS//i}"
    echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" > ~/.osmosis
fi

for i in $(seq 210 240 ); do 
    wget https://planet.openstreetmap.org/replication/day/000/002/${i}.osc.gz
    gzip -d ${i}.osc.gz
    python remove_user_changeset.py ${i}.osc ${i}-new.osc
    mv ${i}-new.osc ${i}.osc
    gzip -f ${i}.osc
    osmosis --read-xml-change file=$i.osc.gz \
    --write-apidb-change \
    host=$POSTGRES_HOST \
    database=$POSTGRES_DB \
    user=$POSTGRES_USER \
    password=$POSTGRES_PASSWORD \
    validateSchemaVersion=no \
    populateCurrentTables=yes
done