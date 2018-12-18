### Planet dump Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to create the planet dump in PBF format according to a schedule.


### Configuration

This container needs some environment variables passed into it in order to run:

- `POSTGRES_HOST` - db
- `POSTGRES_DB` - openstreetmap
- `POSTGRES_USER` - postgres
- `POSTGRES_PASSWORD`  - 1234

Depends on what types of data storage are you going to use, the following variables should be established:

#### Amazon S3

- `AWS_ACCESS_KEY_ID` 
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION` e.g `us-east-1`
- `S3_OSM_PATH`  e.g `s3://osm-seed`

#### Google Storage - SG

# Google Store access

- `GS_OSM_PATH` Google storage bucket
- `GCLOUD_SERVICE_KEY` base64 encode key e.g: `base64 osm-seed-04ee080a55c5.json`
- `GCLOUD_PROJECT` name of your project


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
--network osm-seed_default \
-it osmseed-planet-dump:v1
```