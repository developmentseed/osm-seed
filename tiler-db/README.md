# Tiler-DB

PostGIS database container, to store the osm-seed or osm data.

### Configuration

Required environment variables:

- `POSTGRES_HOST` e.g `tiler-db`
- `POSTGRES_DB` e.g `tiler-osm`
- `POSTGRES_PORT` e.g `5432`
- `POSTGRES_USER` e.g `postgres`
- `POSTGRES_PASSWORD` e.g `1234`


#### Building the container

```
  docker build -t osmseed-tiler-db:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env-tiler \
  --network osm-seed_default \
  -v $(pwd)/../postgres-data-gis:/var/lib/postgresql/data \
  -p "5433:5432" \
  -t osmseed-tiler-db:v1
```