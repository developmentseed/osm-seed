#!/usr/bin/env bash
conString=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:5432/${POSTGRES_DB}

CLIS=(cumulative_elements current_elements changeset_counts)

for cli in "${CLIS[@]}"; do
  echo "Star running... $cli"
  osm-simple-metrics $cli \
    $conString \
    -csv \
    -s3 $AWS_S3_BUCKET
done
