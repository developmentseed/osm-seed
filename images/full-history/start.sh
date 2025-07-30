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

local_planetHistoryPBFFile=$VOLUME_DIR/planet-history-${date}.osm.pbf
cloud_planetHistoryPBFFile=planet/full-history/planet-history-${date}.osm.pbf
stateFile="$VOLUME_DIR/state.txt"
dumpFile="$VOLUME_DIR/input-latest.dump"


# If overwrite flag is enabled, use fixed filenames
if [ "$OVERWRITE_PLANET_FILE" == "true" ]; then
	local_planetHistoryPBFFile=$VOLUME_DIR/planet-history-latest.osm.pbf
	cloud_planetHistoryPBFFile=planet/planet-history-latest.osm.pbf
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

            # Get the first line (S3 URL to the .dump or .dump.gz file)
            first_line=$(head -n 1 "$temp_txt")
            echo "Found dump URL in txt: $first_line"

            # Set dump file name based on extension
            if [[ "$first_line" == *.gz ]]; then
                dumpFile="${dumpFile}.gz"
            fi

            aws s3 cp "$first_line" "$dumpFile"
            if [[ "$dumpFile" == *.gz ]]; then
                echo "Decompressing gzip file..."
                gunzip -f "$dumpFile"
                dumpFile="${dumpFile%.gz}"
            fi
            rm -f "$temp_txt"

        else
            # Set dump file name based on extension
            if [[ "$DUMP_CLOUD_URL" == *.gz ]]; then
                dumpFile="${dumpFile}.gz"
            fi
            aws s3 cp "$DUMP_CLOUD_URL" "$dumpFile"
            if [[ "$dumpFile" == *.gz ]]; then
                echo "Decompressing gzip file..."
                gunzip -f "$dumpFile"
                dumpFile="${dumpFile%.gz}"
            fi
        fi

    elif [ "$CLOUDPROVIDER" == "gcp" ]; then
        gsutil cp "$DUMP_CLOUD_URL" "$dumpFile"
    else
        echo "Unsupported CLOUDPROVIDER: $CLOUDPROVIDER"
        exit 1
    fi

    echo "Dump file ready at: $dumpFile"
}

# ===============================
# Upload planet + state
# ===============================
upload_planet_file() {
	echo "Uploading history planet file and updating state.txt..."

	if [ "$CLOUDPROVIDER" == "aws" ]; then
		AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
		echo "$AWS_URL.s3.amazonaws.com/$cloud_planetHistoryPBFFile" > "$stateFile"
		aws s3 cp "$local_planetHistoryPBFFile" "$AWS_S3_BUCKET/$cloud_planetHistoryPBFFile" --acl public-read
		aws s3 cp "$stateFile" "$AWS_S3_BUCKET/planet/state.txt" --acl public-read

	elif [ "$CLOUDPROVIDER" == "gcp" ]; then
		echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/$cloud_planetHistoryPBFFile" > "$stateFile"
		gsutil cp -a public-read "$local_planetHistoryPBFFile" "$GCP_STORAGE_BUCKET/$cloud_planetHistoryPBFFile"
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

    if [ -n "$PLANET_DUMP_NG_METADATA_URL" ]; then
        echo "Downloading metadata file..."
        curl "$PLANET_DUMP_NG_METADATA_URL" -o metadata.yml
        planet-dump-ng \
            --dump-file "$dumpFile" \
            --history-pbf "$local_planetHistoryPBFFile" \
            -M metadata.yml
    else
        planet-dump-ng \
            --dump-file "$dumpFile" \
            --history-pbf "$local_planetHistoryPBFFile"
    fi
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
		$local_planetHistoryPBFFile
else
	echo "Error: Unknown PLANET_EXPORT_METHOD value. Use 'planet-dump-ng' or 'osmosis'."
	exit 1
fi

# Upload results
upload_planet_file
