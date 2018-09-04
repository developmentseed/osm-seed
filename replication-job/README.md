### Osmosis Replication job container

This contain is responsible for creating the replication files, and then upload to a repository in AWs of Gooble Storage, depends on what you are using.

This container must be configured through a cron job to be executed.

### Configuration

In order to run this container, we should pass some environment variables

**Postgres envs**

- `POSTGRES_HOST` e.g db
- `POSTGRES_DB` e.g openstreetmap
- `POSTGRES_USER` e.g postgres
- `POSTGRES_PASSWORD`  e.g 1234

**Replication interval, in minutes**

- `REPLICATION_INTERVAL` e.g 3 minutes.

**Storage envs**

- `STORAGE`, eg. `S3` or `GS`

In case AWS:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `S3_OSM_PATH` e.g `s3://osm-seed-test`

In case Google storage:

- `GS_OSM_PATH` e.g `gs://osm-seed-test`
- `GCLOUD_SERVICE_KEY`
- `GCLOUD_PROJECT`

#### Building the container

```
  docker build -t openseed-replication-job:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -v $(pwd)/../replication-files:/app/data \
  -t openseed-replication-job:v1
```
