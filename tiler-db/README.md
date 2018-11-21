# Tiler-DB

PostGIS database container, to store the osm-seed or osm data.

### Configuration

Required environment variables:

- `GIS_POSTGRES_HOST` e.g `tiler-db`
- `GIS_POSTGRES_DB` e.g `gis_osm`
- `GIS_POSTGRES_USER` e.g `postgres`
- `GIS_POSTGRES_PASSWORD` e.g `1234`
- `POSTGIS_VERSION` e.g `2.4.4`

#### Building the container

```
  docker build -t osmseed-tiler-db:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -v $(pwd)/../postgres-data-gis:/var/lib/postgresql/data \
  -t osmseed-tiler-db:v1
```