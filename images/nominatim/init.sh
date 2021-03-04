#!/bin/bash

OSMFILE=osmfile.osm.bz2
PGDIR=/var/lib/postgresql/12/main
mkdir -p $PGDIR

echo $PWD
echo "reading.... $PWD"
ls $PWD
echo "reading.... $PGDIR"
ls $PGDIR
# # Check if $PGDATA is empty
# if [ -f "$PGDIR/postgresql.conf" ]; then
#     echo "$PGDIR is not empty, Import won't happen, if you want start an empty dataset remove the directory $PGDIR"
#     ls $PGDIR 
#     exit 0
# else
echo "Download OSM file ... $OSM_URL_FILE"
curl $OSM_URL_FILE --output $OSMFILE
chown postgres:postgres $PGDIR && \
export PGDATA=$PGDIR && \
sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D $PGDIR && \
sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D $PGDIR start && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PG_USER'" | grep -q 1 || sudo -u postgres createuser -s $PG_USER && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
useradd -m -p $PG_PASSWORD $PG_USER && \
chown -R $PG_USER:$PG_USER ./src && \
sudo -u $PG_USER ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS && \
sudo -u $PG_USER ./src/build/utils/check_import_finished.php && \
sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D $PGDIR stop && \
sudo chown -R postgres:postgres $PGDIR
# fi