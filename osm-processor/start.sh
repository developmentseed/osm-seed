#!/usr/bin/env bash
echo $OSM_FILE_ACTION

IMPUT_FILE=$(basename $URL_FILE_TO_PROCESS)
IMPUT_FILE_EXTENCION="${IMPUT_FILE##*.}"
OUTPUT_FILE="${IMPUT_FILE%.*}-output.$IMPUT_FILE_EXTENCION"
wget -O data/$IMPUT_FILE $URL_FILE_TO_PROCESS

# Simplify pbf, remove users and changeset from the file.
if [ "$OSM_FILE_ACTION" == "simple_pbf" ]; then
	echo "Processing $IMPUT_FILE -> $OUTPUT_FILE ..."
	osmium cat -o data/$OUTPUT_FILE \
		--output-format pbf,pbf_dense_nodes=false,pbf_compression=true,add_metadata=version,timestamp \
		data/$IMPUT_FILE

	if [ "$STORAGE" == "S3" ]; then
		# Upload to S3
		aws s3 cp data/$OUTPUT_FILE $S3_OSM_PATH/osm-processor/$OUTPUT_FILE
	fi
	if [ "$STORAGE" == "GS" ]; then
		# Upload to GS
		gsutil cp data/$OUTPUT_FILE $GS_OSM_PATH/osm-processor/$OUTPUT_FILE
	fi
fi
