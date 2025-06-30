#!/usr/bin/env bash
set -e

# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
	echo JAVACMD_OPTIONS=\"-server\" >~/.osmosis
else
	memory="${MEMORY_JAVACMD_OPTIONS//i/}"
	echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" >~/.osmosis
fi

export VOLUME_DIR=/mnt/data
date=$(date '+%y%m%d_%H%M')

local_planetPBFFile=$VOLUME_DIR/planet-${date}.osm.pbf
cloud_planetPBFFile=planet/planet-${date}.osm.pbf
stateFile="$VOLUME_DIR/state.txt"

# If overwrite flag is enabled, use fixed filenames
if [ "$OVERWRITE_PLANET_FILE" == "true" ]; then
	local_planetPBFFile=$VOLUME_DIR/planet-latest.osm.pbf
	cloud_planetPBFFile=planet/planet-latest.osm.pbf
fi

# ===============================
# Download db .dump file 
# ===============================
download_dump_file() {
	local_dumpFile="$VOLUME_DIR/input-latest.dump"
	echo "Downloading db .dump file from cloud..."

	if [ "$CLOUDPROVIDER" == "aws" ]; then
		aws s3 cp "$DUMP_CLOUD_URL" "$local_dumpFile"
	elif [ "$CLOUDPROVIDER" == "gcp" ]; then
		gsutil cp "$DUMP_CLOUD_URL" "$local_dumpFile"
	fi
}

# ===============================
# Upload planet + state
# ===============================
upload_planet_file() {
	echo "Uploading planet file and updating state.txt..."

	if [ "$CLOUDPROVIDER" == "aws" ]; then
		AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
		echo "$AWS_URL.s3.amazonaws.com/$cloud_planetPBFFile" > "$stateFile"
		aws s3 cp "$local_planetPBFFile" "$AWS_S3_BUCKET/$cloud_planetPBFFile" --acl public-read
		aws s3 cp "$stateFile" "$AWS_S3_BUCKET/planet/state.txt" --acl public-read

	elif [ "$CLOUDPROVIDER" == "gcp" ]; then
		echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/$cloud_planetPBFFile" > "$stateFile"
		gsutil cp -a public-read "$local_planetPBFFile" "$GCP_STORAGE_BUCKET/$cloud_planetPBFFile"
		gsutil cp -a public-read "$stateFile" "$GCP_STORAGE_BUCKET/planet/state.txt"
	fi
}

# ===============================
# Generate planet file
# ===============================

if [ "$PLANET_EXPORT_METHOD" == "planet-dump-ng" ]; then
	download_dump_file
	echo "Generating planet file with planet-dump-ng..."
	planet-dump-ng \
		--dump-file "$VOLUME_DIR/input-latest.dump" \
		--pbf "$local_planetPBFFile"
elif [ "$PLANET_EXPORT_METHOD" == "osmosis" ]; then
	echo "Generating planet file with osmosis..."
	if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
		echo JAVACMD_OPTIONS=\"-server\" > ~/.osmosis
	else
		memory="${MEMORY_JAVACMD_OPTIONS//i/}"
		echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" > ~/.osmosis
	fi

	osmosis --read-apidb \
		host=$POSTGRES_HOST \
		database=$POSTGRES_DB \
		user=$POSTGRES_USER \
		password=$POSTGRES_PASSWORD \
		validateSchemaVersion=no \
		--write-pbf \
		file=$local_planetPBFFile
else
	echo "Error: Unknown PLANET_EXPORT_METHOD value. Use 'planet-dump-ng' or 'osmosis'."
	exit 1
fi

# Upload results
upload_planet_file
