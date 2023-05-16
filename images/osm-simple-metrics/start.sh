#!/usr/bin/env bash
conString=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}
bucket_name="${AWS_S3_BUCKET#s3://}"

CLIS=(cumulative_elements current_elements changeset_counts)
for cli in "${CLIS[@]}"; do
  echo "Star running... $cli"
  if [ $CLOUDPROVIDER == "aws" ]; then
    osm-simple-metrics $cli \
      $conString \
      -csv \
      -s3 $bucket_name
  fi
done
