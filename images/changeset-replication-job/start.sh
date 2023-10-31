#!/usr/bin/env bash
set -e

workingDirectory="/mnt/changesets"
mkdir -p "$workingDirectory"
CHANGESETS_REPLICATION_FOLDER="replication/changesets"

# Creating config file
echo "state_file: $workingDirectory/state.yaml
db: host=$POSTGRES_HOST dbname=$POSTGRES_DB user=$POSTGRES_USER password=$POSTGRES_PASSWORD
data_dir: $workingDirectory/" >/config.yaml

# Verify the existence of the state.yaml file across all cloud providers. If it's not found, create a new one.
if [ ! -f "$workingDirectory/state.yaml" ]; then
    echo "File $workingDirectory/state.yaml does not exist in local storage"

    if [ "$CLOUDPROVIDER" == "aws" ]; then
        if aws s3 ls "$AWS_S3_BUCKET/$CHANGESETS_REPLICATION_FOLDER/state.yaml" >/dev/null 2>&1; then
            echo "File exists, downloading from AWS - $AWS_S3_BUCKET"
            aws s3 cp "$AWS_S3_BUCKET/$CHANGESETS_REPLICATION_FOLDER/state.yaml" "$workingDirectory/state.yaml"
        fi
    elif [ "$CLOUDPROVIDER" == "gcp" ]; then
        if gsutil -q stat "$GCP_STORAGE_BUCKET/$CHANGESETS_REPLICATION_FOLDER/state.yaml"; then
            echo "File exists, downloading from GCP - $GCP_STORAGE_BUCKET"
            gsutil cp "$GCP_STORAGE_BUCKET/$CHANGESETS_REPLICATION_FOLDER/state.yaml" "$workingDirectory/state.yaml"
        fi
    elif [ "$CLOUDPROVIDER" == "azure" ]; then
        state_file_exists=$(az storage blob exists --container-name "$AZURE_CONTAINER_NAME" --name "$CHANGESETS_REPLICATION_FOLDER/state.yaml" --query "exists" --output tsv)
        if [ "$state_file_exists" == "true" ]; then
            echo "File exists, downloading from Azure - $AZURE_CONTAINER_NAME"
            az storage blob download --container-name "$AZURE_CONTAINER_NAME" --name "$CHANGESETS_REPLICATION_FOLDER/state.yaml" --file "$workingDirectory/state.yaml"
        fi
    fi
    if [ ! -f "$workingDirectory/state.yaml" ]; then
        echo "sequence: 0" >"$workingDirectory/state.yaml"
    fi
fi

# Creating the replication files
generateReplication() {
    while true; do
        # Run replication script
        ruby replicate_changesets.rb /config.yaml

        # Loop through newly created files
        for local_file in $(find "$workingDirectory/" -cmin -1); do
            if [ -f "$local_file" ]; then
                # Construct the cloud path for the file
                cloud_file="$CHANGESETS_REPLICATION_FOLDER/${local_file#*$workingDirectory/}"

                # Log file transfer
                echo "$(date +%F_%H:%M:%S): Copying file $local_file to $cloud_file"

                # Handle different cloud providers
                case "$CLOUDPROVIDER" in
                "aws")
                    aws s3 cp "$local_file" "$AWS_S3_BUCKET/$cloud_file" --acl public-read
                    ;;
                "gcp")
                    gsutil cp -a public-read "$local_file" "$GCP_STORAGE_BUCKET/$cloud_file"
                    ;;
                "azure")
                    az storage blob upload \
                        --container-name "$AZURE_CONTAINER_NAME" \
                        --file "$local_file" \
                        --name "$cloud_file" \
                        --output none
                    ;;
                *)
                    echo "Unknown cloud provider: $CLOUDPROVIDER"
                    ;;
                esac
            fi
        done

        # Sleep for 60 seconds before next iteration
        sleep 60s
    done
}

# Call the function to start the replication process
generateReplication
