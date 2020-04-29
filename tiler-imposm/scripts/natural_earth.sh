#!/bin/bash

# This script will install natural earth data (http://www.naturalearthdata.com/downloads/) into a PostGIS database named DB_NAME.
# The script assumes the following utilities are installed:
# 	- psql: PostgreSQL client
#	- ogr2ogr: GDAL vector lib
#	- unzip: decompression util
#
# Usage
# 	Set the database connection variables, then run
#
#		./natural_earth.sh
#
# Important
# 	- This script is idempotent and will DROP the natural earth database if it already exists
#	- In order for this script to work the DB_USER must have access to the 'postgres' database to create a new database


set -e



CONFIG_FILE=''
DROP_DB=false

while getopts ":c:dv" flag; do
  case ${flag} in
    c)
      if [[ ! -r $OPTARG ]]; then echo "Config File $OPTARG Not Found!"; exit 2;
      else echo "Using config file: $OPTARG"; CONFIG_FILE=$OPTARG
      fi  ;;
    v)
      echo "Running in Verbose Mode"
      set -x ;;
    d)
      echo "Dropping Existing DB"; DROP_DB=true ;;
    \?)
      printf '\nUnrecognized option: -%s \nUsage: \n[-c file] Path to Config File \n[-d] drop existing database \n[-v] verbose\n' $OPTARG; exit 2 ;;
    :)
      echo "Option -$OPTARG requires an argument"; exit 2 ;;
  esac
done

# database connection variables
DB_NAME=$POSTGRES_DB
DB_HOST=$POSTGRES_HOST
DB_PORT=$POSTGRES_PORT
DB_USER=$POSTGRES_USER
DB_PW=$POSTGRES_PASSWORD

# Check if we're using a config file
if [[ -r $CONFIG_FILE ]]; then source $CONFIG_FILE
elif [ -r dbcredentials.sh ]; then source dbcredentials.sh
fi

# check our connection string before we do any downloading
psql "dbname='postgres' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" -c "\q"

# array of natural earth dataset URLs
 dataurls=(
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_admin_0_boundary_lines_land.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_admin_0_countries.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_admin_1_states_provinces_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_populated_places.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_coastline.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_geography_marine_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_geography_regions_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_rivers_lake_centerlines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_lakes.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_glaciated_areas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_land.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_110m_ocean.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_0_boundary_lines_land.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_0_boundary_lines_disputed_areas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_0_boundary_lines_maritime_indicator.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_0_countries.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_0_map_subunits.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_1_states_provinces_lakes.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_admin_1_states_provinces_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_populated_places.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_geographic_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_coastline.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_antarctic_ice_shelves_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_antarctic_ice_shelves_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_geography_marine_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_geography_regions_elevation_points.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_geography_regions_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_rivers_lake_centerlines_scale_rank.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_rivers_lake_centerlines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_lakes.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_glaciated_areas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_land.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_50m_ocean.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_boundary_lines_land.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_boundary_lines_disputed_areas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_parks_and_protected_lands.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_boundary_lines_map_units.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_boundary_lines_maritime_indicator.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_label_points.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_countries.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_0_map_subunits.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_1_label_points.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_admin_1_states_provinces_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_populated_places.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_roads.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_urban_areas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_geographic_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_coastline.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_antarctic_ice_shelves_lines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_antarctic_ice_shelves_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_geography_marine_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_geography_regions_elevation_points.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_geography_regions_points.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_geography_regions_polys.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_rivers_north_america.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_rivers_europe.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_rivers_lake_centerlines_scale_rank.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_rivers_lake_centerlines.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_playas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_reefs.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_lakes_historic.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_lakes_north_america.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_lakes_europe.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_lakes.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_glaciated_areas.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_land.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_minor_islands.zip"
    "https://osmseed-staging.s3.amazonaws.com/naciscdn/ne_10m_ocean.zip"
)

# remove old database if -d flag is set and create a new one
if [[ "$DROP_DB" = true ]];
then
  psql "dbname='postgres' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" -c "DROP DATABASE IF EXISTS $DB_NAME"
  psql "dbname='postgres' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" -c "CREATE DATABASE $DB_NAME"
fi

# Create postgis extension if it doesn't exist
psql "dbname='$DB_NAME' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" -c "CREATE EXTENSION IF NOT EXISTS postgis"

# iterate our dataurls
for i in "${!dataurls[@]}"; do
	url=${dataurls[$i]}

	echo "fetching $url";
	curl $url > $i.zip;
	unzip $i -d $i

	# support for archives with more than one shapefile
	for f in $i/*.shp; do
		# reproject data to webmercator (3857) and insert into our database
		OGR_ENABLE_PARTIAL_REPROJECTION=true ogr2ogr -unsetFieldWidth -t_srs EPSG:3857 -nlt PROMOTE_TO_MULTI -f PostgreSQL PG:"dbname='$DB_NAME' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" $f
	done

	# clean up
	rm -rf $i/ $i.zip
done
