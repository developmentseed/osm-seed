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
    mkdir -p $workingDirectory
fi

# Creating the replication files
function generateReplication() {
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
        workingDirectory=$workingDirectory &
    while true; do
        for local_file in $(find $workingDirectory/ -cmin -1); do
            if [ -f "$local_file" ]; then
                
                cloud_file=$REPLICATION_FOLDER/${local_file#*"$workingDirectory/"}
                echo $(date +%F_%H:%M:%S)": Copy file...$local_file to $cloud_file"
                
                ### AWS
                if [ $CLOUDPROVIDER == "aws" ]; then
                    aws s3 cp $local_file $AWS_S3_BUCKET/$cloud_file --acl public-read
                fi
                
                ### GCP
                if [ $CLOUDPROVIDER == "gcp" ]; then
                    #TODO, emable public acces
                    gsutil cp -a public-read $local_file $GCP_STORAGE_BUCKET/$cloud_file
                fi
                
                ### Azure
                if [ $CLOUDPROVIDER == "azure" ]; then
                    #TODO, emable public acces
                    az storage blob upload \
                        --container-name $AZURE_CONTAINER_NAME \
                        --file $local_file \
                        --name $cloud_file \
                        --output none
                fi
            fi
        done
        sleep 15s
    done
}

# Check if Postgres is ready
flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    generateReplication
done
