#!/bin/bash
set -ex

# From: https://github.com/openstreetmap/openstreetmap-website/blob/af273f5d6ae160de0001ce1ac0c087d92a2463c6/docker/postgres/openstreetmap-postgres-init.sh
# Create 'openstreetmap' user
# Password and superuser privilege are needed to successfully run test suite
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL
    CREATE USER openstreetmap SUPERUSER PASSWORD 'openstreetmap';
    GRANT ALL PRIVILEGES ON DATABASE openstreetmap TO openstreetmap;
EOSQL

# Create btree_gist extensions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "CREATE EXTENSION btree_gist" openstreetmap

# Define custom functions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -f "/usr/local/share/osm-db-functions.sql" openstreetmap
