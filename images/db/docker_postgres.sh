#!/bin/bash
set -e

# From: https://github.com/openstreetmap/openstreetmap-website/blob/af273f5d6ae160de0001ce1ac0c087d92a2463c6/docker/postgres/openstreetmap-postgres-init.sh
# Create 'openstreetmap' user
# Password and superuser privilege are needed to successfully run test suite
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL
    CREATE USER openstreetmap SUPERUSER PASSWORD 'openstreetmap';
    GRANT ALL PRIVILEGES ON DATABASE openstreetmap TO openstreetmap;
EOSQL

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE ROLE hosm WITH SUPERUSER" openstreetmap
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION btree_gist" openstreetmap
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION postgis" openstreetmap
make -C /db/functions libpgosm.so
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT" openstreetmap
# psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT" openstreetmap
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT" openstreetmap


# Define custom functions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -f "/usr/local/share/osm-db-functions.sql" openstreetmap
