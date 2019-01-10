# OSM-processor

This is a container has a set of tools for the processing of OSM files, you need to pass two variables to the container, a url file `URL_FILE_TO_PROCESS` and the action `OSM_FILE_ACTION`, and then the container will process the results and uploading in an S3 or GCP bucket.

# Current actions

### Simplify PBF file

This action simplifies the PBF file by removing the changeset number and users.

`URL_FILE_TO_PROCESS=https://s3.amazonaws.com/osmseed-staging/pbf/dc.pbf`

`OSM_FILE_ACTION=simple_pbf`

The output file would be `dc-output.pbf`

The following env variables are according to which cloud provider you are going to use:

- `CLOUDPROVIDER`, eg. `aws` or `gcp`

In case AWS:

- `AWS_S3_BUCKET` e.g `s3://osm-seed-test`

In case GCP:

- `GCP_STORAGE_BUCKET` e.g `gs://osm-seed-test`

#### Building the container

The container will build automatically by docker-compose, but if you want to run separately you could follow the next command lines: 

```
  cd osm-processor/
  docker network create osm-seed_default
  docker build -t osmseed-osm-processor:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -v $(pwd)/../osm-processor-data:/app/data \
  -i -t osmseed-osm-processor:v1
```