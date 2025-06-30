#!/usr/bin/env bash
set -e

# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
	echo JAVACMD_OPTIONS="-server" >~/.osmosis
else
	memory="${MEMORY_JAVACMD_OPTIONS//i/}"
	echo JAVACMD_OPTIONS="-server -Xmx$memory" >~/.osmosis
fi

export VOLUME_DIR=/mnt/data
export PLANET_EPOCH_DATE="${PLANET_EPOCH_DATE:-2004-01-01}"
date=$(date '+%y%m%d_%H%M')

local_planetPBFFile=$VOLUME_DIR/planet-history-${date}.osm.pbf
cloud_planetPBFFile=planet/planet-history-${date}.osm.pbf
stateFile="$VOLUME_DIR/state.txt"
dumpFile="$VOLUME_DIR/input-latest.dump"


# If overwrite flag is enabled, use fixed filenames
if [ "$OVERWRITE_PLANET_FILE" == "true" ]; then
	local_planetPBFFile=$VOLUME_DIR/planet-history-latest.osm.pbf
	cloud_planetPBFFile=planet/planet-history-latest.osm.pbf
fi

# ===============================
# Download db .dump file 
# ===============================
download_dump_file() {
	echo "Downloading db .dump file from cloud..."
	if [ "$CLOUDPROVIDER" == "aws" ]; then
		if [[ "$DUMP_CLOUD_URL" == *.txt ]]; then
			temp_txt="$VOLUME_DIR/tmp_dump_url.txt"
			aws s3 cp "$DUMP_CLOUD_URL" "$temp_txt"
			first_line=$(head -n 1 "$temp_txt")
			aws s3 cp "$first_line" "$dumpFile"
		else
			aws s3 cp "$DUMP_CLOUD_URL" "$dumpFile"
		fi
	elif [ "$CLOUDPROVIDER" == "gcp" ]; then
		gsutil cp "$DUMP_CLOUD_URL" "$dumpFile"
	fi
}

# ===============================
# Upload planet + state
# ===============================
upload_planet_file() {
	echo "Uploading history planet file and updating state.txt..."

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
	echo "Generating history planet file with planet-dump-ng..."
	export PLANET_EPOCH_DATE="$PLANET_EPOCH_DATE"
	planet-dump-ng \
		--dump-file "$dumpFile" \
		--history-pbf "$local_planetPBFFile"

elif [ "$PLANET_EXPORT_METHOD" == "osmosis" ]; then
	echo "Generating history planet file with osmosis..."
	# Creating full history
	osmosis --read-apidb-change \
		host=$POSTGRES_HOST \
		database=$POSTGRES_DB \
		user=$POSTGRES_USER \
		password=$POSTGRES_PASSWORD \
		validateSchemaVersion=no \
		readFullHistory=yes \
		--write-xml-change \
		compressionMethod=auto \
		$local_planetPBFFile
else
	echo "Error: Unknown PLANET_EXPORT_METHOD value. Use 'planet-dump-ng' or 'osmosis'."
	exit 1
fi

# Upload results
upload_planet_file
