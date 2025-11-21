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
dumpFile="$VOLUME_DIR/input-latest.dump"

# If overwrite flag is enabled, use fixed filenames
if [ "$OVERWRITE_PLANET_FILE" == "true" ]; then
	local_planetPBFFile=$VOLUME_DIR/planet-latest.osm.pbf
	cloud_planetPBFFile=planet/planet-latest.osm.pbf
fi


# ===============================
# Download db .dump file
# ===============================
download_dump_file() {
    echo "Downloading db .dump file from cloud..."

    local temp_dump_file="$dumpFile.tmp"
    local actual_dump_url=""

    if [ "$CLOUDPROVIDER" == "aws" ]; then
        if [[ "$DUMP_CLOUD_URL" == *.txt ]]; then
            temp_txt="$VOLUME_DIR/tmp_dump_url.txt"
            aws s3 cp "$DUMP_CLOUD_URL" "$temp_txt"

            # Get the first line (S3 URL to the .dump file)
            actual_dump_url=$(head -n 1 "$temp_txt")
            echo "Found dump URL in txt: $actual_dump_url"

            aws s3 cp "$actual_dump_url" "$temp_dump_file"
            rm -f "$temp_txt"

        else
            actual_dump_url="$DUMP_CLOUD_URL"
            aws s3 cp "$DUMP_CLOUD_URL" "$temp_dump_file"
        fi

    elif [ "$CLOUDPROVIDER" == "gcp" ]; then
        actual_dump_url="$DUMP_CLOUD_URL"
        gsutil cp "$DUMP_CLOUD_URL" "$temp_dump_file"
    else
        echo "Unsupported CLOUDPROVIDER: $CLOUDPROVIDER"
        exit 1
    fi

    # Check if downloaded file is gzip compressed and decompress if needed
    # Check by file extension, file type, or magic bytes
    local is_gzip=false
    if [[ "$actual_dump_url" == *.gz ]] || [[ "$temp_dump_file" == *.gz ]]; then
        is_gzip=true
    elif command -v file >/dev/null 2>&1 && file "$temp_dump_file" 2>/dev/null | grep -q "gzip compressed"; then
        is_gzip=true
    elif head -c 2 "$temp_dump_file" 2>/dev/null | od -An -tx1 | grep -q "1f 8b"; then
        # Check for gzip magic bytes (1f 8b)
        is_gzip=true
    fi

    if [ "$is_gzip" = true ]; then
        echo "Detected gzip compressed dump file, decompressing..."
        gunzip -c "$temp_dump_file" > "$dumpFile"
        rm -f "$temp_dump_file"
    else
        mv "$temp_dump_file" "$dumpFile"
    fi

    echo "Dump file ready at: $dumpFile (PostgreSQL 17 compatible)"
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

    if [ -n "$PLANET_DUMP_NG_METADATA_URL" ]; then
        curl "$PLANET_DUMP_NG_METADATA_URL" -o metadata.yml
        planet-dump-ng \
            --dump-file "$dumpFile" \
            --pbf "$local_planetPBFFile" \
            -M metadata.yml
    else
        planet-dump-ng \
            --dump-file "$dumpFile" \
            --pbf "$local_planetPBFFile"
    fi
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
