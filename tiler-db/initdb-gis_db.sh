#!/bin/bash
set -e

# export POSTGRES_HOST="$GIS_POSTGRES_HOST"
# export POSTGRES_DB="$GIS_POSTGRES_DB"
# export POSTGRES_USER="$GIS_POSTGRES_USER"
# export POSTGRES_PASSWORD="$GIS_POSTGRES_PASSWORD"

# Create the 'gis' template db

# "${psql[@]}" <<- 'EOSQL'
# CREATE DATABASE "$POSTGRES_DB";
# EOSQL
"${psql[@]}" --dbname="$POSTGRES_DB" <<-'EOSQL'
		CREATE EXTENSION IF NOT EXISTS postgis;
		CREATE EXTENSION IF NOT EXISTS postgis_topology;
		CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
		CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL