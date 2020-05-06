### Planet dump Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to create the planet dump in PBF format according to a schedule.


### Configuration

This container needs some environment variables passed into it in order to run:

- `POSTGRES_HOST` - db
- `POSTGRES_DB` - openstreetmap
- `POSTGRES_USER` - postgres
- `POSTGRES_PASSWORD`  - 1234

The following env variables are according to which cloud provider you are going to use:

- `CLOUDPROVIDER`, eg. `aws` or `gcp`

In case AWS:

- `AWS_S3_BUCKET` e.g `s3://osm-seed-test`

In case GCP:

- `GCP_STORAGE_BUCKET` e.g `gs://osm-seed-test`


#### Building the container

```
    cd planet-dump
    docker network create osm-seed_default
    docker build -t osmseed-planet-dump:v1 .
```

#### Running the container

```
docker run \
--env-file ./../.env \
-v ${PWD}:/mnt/data \
--network osm-seed_default \
-it osmseed-planet-dump:v1
```