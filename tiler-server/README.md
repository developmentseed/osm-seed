# Tiler server

This container is for rendering the vector tiles base on [Tegola](https://github.com/go-spatial/tegola), the container connects to the database `tiler-db` and serves the tiles through the port `9090`.


### Configuration

Required environment variables:

 **Env variables to connect to the db-tiler**

- `POSTGRES_HOST` e.g `tiler-db`
- `POSTGRES_DB` e.g `tiler-osm`
- `POSTGRES_PORT` e.g `5432`
- `POSTGRES_USER` e.g `postgres`
- `POSTGRES_PASSWORD` e.g `1234`

**Env variables  to serve the tiles**

- `TILER_SERVER_PORT` e.g `9090`

**Env variables for caching the tiles**

TILER_CACHE_* , by default osmseed-tiler is using aws-s3 for caching the tiles, if you want to change it, take a look in: https://github.com/go-spatial/tegola/tree/master/cache

- `TILER_SERVER_PORT` e.g `9090`
- `TILER_CACHE_TYPE` e.g `s3`
- `TILER_CACHE_BUCKET` e.g `s3://osmseed-tiler`
- `TILER_CACHE_BASEPATH` e.g `local`
- `TILER_CACHE_REGION` e.g `us-east-1`
- `TILER_CACHE_AWS_ACCESS_KEY_ID` e.g `xyz`
- `TILER_CACHE_AWS_SECRET_ACCESS_KEY` e.g `xyz`
- `TILER_CACHE_MAX_ZOOM` e.g `22`

#### Building the container

```
    cd tiler-server/
    docker network create osm-seed_default
    docker build -t osmseed-tiler-server:v1 .
```

#### Running the container

```
  docker run \
  --env-file ./../.env-tiler \
  --network osm-seed_default \
  -v $(pwd)/:/mnt/data \
  -p "9090:9090" \
  -t osmseed-tiler-server:v1
```