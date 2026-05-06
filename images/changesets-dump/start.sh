#!/usr/bin/env bash
set -e

export VOLUME_DIR=/mnt/data
date=$(date '+%y%m%d_%H%M')

local_changesetsFile=$VOLUME_DIR/changesets-${date}.osm.bz2
folder_changesetsFile=planet/changesets
cloud_changesetsFile=${folder_changesetsFile}/changesets-${date}.osm.bz2
stateFile="$VOLUME_DIR/state.txt"
dumpFile="$VOLUME_DIR/input-latest.dump"

# If overwrite flag is enabled, use fixed filenames
if [ "$OVERWRITE_CHANGESETS_FILE" == "true" ]; then
	local_changesetsFile=$VOLUME_DIR/changesets-latest.osm.bz2
	cloud_changesetsFile=planet/changesets-latest.osm.bz2
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

    local is_gzip=false
    if [[ "$actual_dump_url" == *.gz ]] || [[ "$temp_dump_file" == *.gz ]]; then
        is_gzip=true
    elif command -v file >/dev/null 2>&1 && file "$temp_dump_file" 2>/dev/null | grep -q "gzip compressed"; then
        is_gzip=true
    elif head -c 2 "$temp_dump_file" 2>/dev/null | od -An -tx1 | grep -q "1f 8b"; then
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
# Upload changesets dump + state
# ===============================
upload_changesets_file() {
	echo "Uploading changesets file and updating state.txt..."

	if [ "$CLOUDPROVIDER" == "aws" ]; then
		AWS_URL=${AWS_S3_BUCKET/s3:\/\//http:\/\/}
		echo "$AWS_URL.s3.amazonaws.com/$cloud_changesetsFile" > "$stateFile"
		aws s3 cp "$local_changesetsFile" "$AWS_S3_BUCKET/$cloud_changesetsFile" --acl public-read
		aws s3 cp "$stateFile" "$AWS_S3_BUCKET/${folder_changesetsFile}/state.txt" --acl public-read

	elif [ "$CLOUDPROVIDER" == "gcp" ]; then
		echo "https://storage.cloud.google.com/$GCP_STORAGE_BUCKET/$cloud_changesetsFile" > "$stateFile"
		gsutil cp -a public-read "$local_changesetsFile" "$GCP_STORAGE_BUCKET/$cloud_changesetsFile"
		gsutil cp -a public-read "$stateFile" "$GCP_STORAGE_BUCKET/${folder_changesetsFile}/state.txt"
	fi
}

# ===============================
# Generate changesets dump
# ===============================
download_dump_file
echo "Generating changesets dump with planet-dump-ng..."
planet-dump-ng \
	--dump-file "$dumpFile" \
	--changesets "$local_changesetsFile"

upload_changesets_file
