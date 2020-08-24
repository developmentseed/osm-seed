#!/usr/bin/env bash

if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
    echo JAVACMD_OPTIONS=\"-server\" > ~/.osmosis
else
    memory="${MEMORY_JAVACMD_OPTIONS//i}"
    echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" > ~/.osmosis
fi

function dropData () {
    echo "starting truncate..."
    osmosis --truncate-apidb \
    host=$POSTGRES_HOST \
    database=$POSTGRES_DB \
    user=$POSTGRES_USER \
    password=$POSTGRES_PASSWORD \
    validateSchemaVersion=no
}

flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 -U $POSTGRES_USER >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    dropData
done
