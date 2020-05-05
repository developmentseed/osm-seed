### Full history Container

Dockerfile for getting the full planet history of database.


### Configuration

Required environment variables;

- `POSTGRES_HOST`
- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`

The following env variables are according to which cloud provider you are going to use:

- `CLOUDPROVIDER`, eg. `aws` or `gcp`

In case AWS:

- `AWS_S3_BUCKET` e.g `s3://osm-seed-test`

In case GCP:

- `GCP_STORAGE_BUCKET` e.g `gs://osm-seed-test`

#### Building the container

```sh
    cd full-history
    docker build -t full-history:v1 .
```

#### Running the container

```sh
docker run \
--env-file ./../.env \
-v ${PWD}:/app \
--network osm-seed_default \
-it full-history:v1
```