#!/bin/bash

OSMFILE=osmfile.osm.bz2
PGDATA=/var/lib/postgresql/12/main

# Check if $PGDATA is empty
if [ "$(ls -A $PGDATA)" ]; then
    echo "$PGDATA is not empty, Import won't happen, if you want start an empty dataset remove the directory $PGDIR"
    exit 0
else
    # Import data to DB
    echo "$PGDATA is Empty"
    echo "Starting Postgres db..."
    chown postgres:postgres $PGDATA
    export PGDATA=$PGDATA &&
        sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D $PGDATA &&
        sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D $PGDATA start

    echo "Download OSM file"
    curl $OSM_URL_FILE --output $OSMFILE

    echo "Starting imports data to DB"
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PG_USER'" | grep -q 1 || sudo -u postgres createuser -s $PG_USER &&
        sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data &&
        sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS $PG_DATABASE" &&
        useradd -m -p $PG_PASSWORD $PG_USER &&
        chown -R $PG_USER:$PG_USER ./src &&
        sudo -u $PG_USER ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS &&
        sudo -u $PG_USER ./src/build/utils/check_import_finished.php &&
        sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D $PGDATA stop &&
        sudo chown -R postgres:postgres $PGDATA
fi
