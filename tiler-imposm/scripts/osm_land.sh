#!/bin/bash
set -e

CONFIG_FILE=''
while getopts ":c:v" flag; do
  case ${flag} in
    c)
      if [[ ! -r $OPTARG ]]; then echo "Config File $OPTARG Not Found!"; exit 2;
      else echo "Using config file: $OPTARG"; CONFIG_FILE=$OPTARG
      fi  ;;
    v)
      echo "Running in Verbose Mode"
      set -x ;;
    \?)
      printf '\nUnrecognized option: -%s \nUsage: \n[-c file] Path to Config File \n[-v] verbose\n' $OPTARG; exit 2 ;;
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
	"https://osmdata.openstreetmap.de/download/land-polygons-split-3857.zip"
)

psql "dbname='postgres' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" -c "DROP TABLE IF EXISTS land_polygons"

# iterate our dataurls
for i in "${!dataurls[@]}"; do
	url=${dataurls[$i]}

	echo "fetching $url";
	curl $url > $i.zip;
	unzip $i -d $i

	shape_file=$(find $i -type f -name "*.shp")

	echo $shape_file

	# reproject data to webmercator (3857) and insert into our database
	OGR_ENABLE_PARTIAL_REPROJECTION=true ogr2ogr -overwrite -t_srs EPSG:3857 -nlt PROMOTE_TO_MULTI -f PostgreSQL PG:"dbname='$DB_NAME' host='$DB_HOST' port='$DB_PORT' user='$DB_USER' password='$DB_PW'" $shape_file

	# clean up
	rm -rf $i/ $i.zip
done
