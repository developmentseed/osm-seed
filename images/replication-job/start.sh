#!/usr/bin/env bash
set -e
# osmosis tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
    echo JAVACMD_OPTIONS=\"-server\" >~/.osmosis
else
    memory="${MEMORY_JAVACMD_OPTIONS//i/}"
    echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" >~/.osmosis
fi

workingDirectory="/mnt/data"
mkdir -p $workingDirectory

# Remove files that are not required
[ -e /mnt/data/replicate.lock ] && rm -f /mnt/data/replicate.lock
# [ -e /mnt/data/processed_files.log ] && rm -f /mnt/data/processediles.log

function get_current_state_file() {
    # Check if state.txt exist in the workingDirectory,
    # in case the file does not exist locally and does not exist in the cloud the replication will start from 0
    if [ ! -f $workingDirectory/state.txt ]; then
        echo "File $workingDirectory/state.txt does not exist in local storage"
        ### AWS
        if [ $CLOUDPROVIDER == "aws" ]; then
            aws s3 ls $AWS_S3_BUCKET/$REPLICATION_FOLDER/state.txt
            if [[ $? -eq 0 ]]; then
                echo "File exist, let's get it from $CLOUDPROVIDER - $AWS_S3_BUCKET"
                aws s3 cp $AWS_S3_BUCKET/$REPLICATION_FOLDER/state.txt $workingDirectory/state.txt
            fi
        fi

        ### GCP
        if [ $CLOUDPROVIDER == "gcp" ]; then
            gsutil ls $GCP_STORAGE_BUCKET/$REPLICATION_FOLDER/state.txt
            if [[ $? -eq 0 ]]; then
                echo "File exist, let's get it from $CLOUDPROVIDER - $GCP_STORAGE_BUCKET"
                gsutil cp $GCP_STORAGE_BUCKET/$REPLICATION_FOLDER/state.txt $workingDirectory/state.txt
            fi
        fi

        ### Azure
        if [ $CLOUDPROVIDER == "azure" ]; then
            state_file_exists=$(az storage blob exists --container-name $AZURE_CONTAINER_NAME --name $REPLICATION_FOLDER/state.txt --query="exists")
            if [[ $state_file_exists=="true" ]]; then
                echo "File exist, let's get it from $CLOUDPROVIDER - $AZURE_CONTAINER_NAME"
                az storage blob download \
                    --container-name $AZURE_CONTAINER_NAME \
                    --name $REPLICATION_FOLDER/state.txt \
                    --file $workingDirectory/state.txt --query="name"
            fi
        fi
    fi
}

function upload_file_cloud() {
    # Upload files to cloud provider
    local local_file="$1"
    local cloud_file="$REPLICATION_FOLDER/${local_file#*"$workingDirectory/"}"
    echo "$(date +%F_%H:%M:%S): Upload file $local_file to ...$CLOUDPROVIDER...$cloud_file"
    if [ "$CLOUDPROVIDER" == "aws" ]; then
        aws s3 cp "$local_file" "$AWS_S3_BUCKET/$cloud_file" --acl public-read
    elif [ "$CLOUDPROVIDER" == "gcp" ]; then
        gsutil cp -a public-read "$local_file" "$GCP_STORAGE_BUCKET/$cloud_file"
    elif [ "$CLOUDPROVIDER" == "azure" ]; then
        az storage blob upload \
            --container-name "$AZURE_CONTAINER_NAME" \
            --file "$local_file" \
            --name "$cloud_file" \
            --output none
    fi
}

function monitor_minute_replication() {
    # Function to handle continuous monitoring, minutminutes replication and upload to cloud provider
    # Directory to store a log of processed files
    processed_files_log="$workingDirectory/processed_files.log"
    max_log_size_mb=1

    while true; do
        upload_file_cloud /mnt/data/state.txt
        sleep 60s
    done &

    while true; do
        if [ -e "$processed_files_log" ]; then
            log_size=$(du -m "$processed_files_log" | cut -f1)
            if [ "$log_size" -gt "$max_log_size_mb" ]; then
                echo $(date +%F_%H:%M:%S)": Cleaning processed_files_log..." >"$processed_files_log"
            fi
            for local_minute_file in $(find $workingDirectory/ -cmin -1); do
                if [ -f "$local_minute_file" ]; then
                    if grep -q "$local_minute_file" "$processed_files_log"; then
                        continue
                    fi
                    upload_file_cloud $local_minute_file
                    echo "$local_minute_file" >>"$processed_files_log"
                fi
            done
        else
            echo "File $processed_files_log not found."
            echo $processed_files_log >$processed_files_log
        fi
        sleep 10s
    done
}

function generate_replication() {
    # Replicate the API database using Osmosis
    osmosis -q \
        --replicate-apidb \
        iterations=0 \
        minInterval=60000 \
        maxInterval=120000 \
        host=$POSTGRES_HOST \
        database=$POSTGRES_DB \
        user=$POSTGRES_USER \
        password=$POSTGRES_PASSWORD \
        validateSchemaVersion=no \
        --write-replication \
        workingDirectory=$workingDirectory
}

# function start_nginx() {
#     if [ "$STAR_NGINX_SERVER" = "true" ]; then
#         echo 'server {
#             listen 8080;
#             server_name localhost;

#             location / {
#                 root /mnt/data;
#                 index index.html;
#             }
#         }' >/etc/nginx/nginx.conf
#         service nginx restart
#     else
#         echo "STAR_NGINX_SERVER is either not set or not set to true."
#     fi
# }

######################## Start minutes replication process ########################
get_current_state_file
flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
    flag=false
    generate_replication &
    monitor_minute_replication
done
