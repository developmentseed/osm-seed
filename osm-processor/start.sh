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

	if [ "$CLOUDPROVIDER" == "aws" ]; then
		# Upload to S3
		aws s3 cp data/$OUTPUT_FILE $AWS_S3_BUCKET/osm-processor/$OUTPUT_FILE
	fi
	if [ "$CLOUDPROVIDER" == "gcp" ]; then
		# Upload to GS
		gsutil cp data/$OUTPUT_FILE $GCP_STORAGE_BUCKET/osm-processor/$OUTPUT_FILE
	fi
fi
