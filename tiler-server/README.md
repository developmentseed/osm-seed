# Tiler server

Container for rendering the vector tiles base on [Tegola](https://github.com/go-spatial/tegola), the container connects to the database `tiler-db` and serves the tiles through the port `9090`.


### Configuration

Required environment variables:

- `TILER_SERVER_PORT` e.g `9090`
- `CACHE_TYPE` e.g `file`, for now, we are using the local file as the cache storage
- `GIS_POSTGRES_HOST` e.g `tiler-db`
- `GIS_POSTGRES_DB` e.g `gis_osm`
- `GIS_POSTGRES_USER` e.g `postgres`
- `GIS_POSTGRES_PASSWORD` e.g `1234`

#### Building the container

```
  docker build -t osmseed-tiler-server:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -t osmseed-tiler-server:v1
```