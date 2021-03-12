#!/bin/bash
OSMFILE=osmfile.osm.bz2
PGDIR=$PGDATA
sudo rm -rf $PGDATA/*
mkdir -p $PGDIR

if [ -f "$PGDIR/postgresql.conf" ]; then
    echo "$PGDIR/postgresql.conf exist, Import won't happen, if you want start an empty dataset remove the directory $PGDIR"
    exit 0
else
    chown postgres:postgres $PGDIR && \
    export PGDATA=$PGDIR && \
    sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D $PGDIR && \
    sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D $PGDIR start && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PG_USER'" | grep -q 1 || sudo -u postgres createuser -s $PG_USER && \
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
    sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
    useradd -m -p $PG_PASSWORD $PG_USER && \
    echo "Download OSM file ... $OSM_URL_FILE"  && \
    chown -R $PG_USER:$PG_USER ./src && \
    sudo wget $OSM_URL_FILE -O $OSMFILE && \
    sudo -u $PG_USER ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS && \
    sudo -u $PG_USER ./src/build/utils/check_import_finished.php && \
    sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D $PGDIR stop && \
    sudo chown -R postgres:postgres $PGDIR && \
    sudo chmod 0700 -R $PGDATA
    echo "host all all 0.0.0.0/0 trust" >> $PGDATA/pg_hba.conf
    echo "listen_addresses='*'" >> $PGDATA/postgresql.conf
fi
