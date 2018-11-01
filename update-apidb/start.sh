#!/usr/bin/env bash

# OSMOSIS tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
    echo JAVACMD_OPTIONS=\"-server\" > ~/.osmosis
else
    memory="${MEMORY_JAVACMD_OPTIONS//i}"
    echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" > ~/.osmosis
fi


for i in $(seq 33 720 ); do 
    numFile=$(printf "%03d\n" ${i})
    # TODO: those parameters should be pass by ENV Variable.
    wget https://planet.openstreetmap.org/replication/hour/000/053/${numFile}.osc.gz
    gzip -d ${numFile}.osc.gz
    python remove_user_changeset.py ${numFile}.osc ${numFile}-new.osc
    mv ${numFile}-new.osc ${numFile}.osc
    gzip -f ${numFile}.osc
    osmosis --read-xml-change file=$numFile.osc.gz \
    --write-apidb-change \
    host=$POSTGRES_HOST \
    database=$POSTGRES_DB \
    user=$POSTGRES_USER \
    password=$POSTGRES_PASSWORD \
    validateSchemaVersion=no \
    populateCurrentTables=yes
done