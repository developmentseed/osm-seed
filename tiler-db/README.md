# Tiler-DB

PostGIS database container to store the osm-seed or osm data for tiling.

### Configuration

Required environment variables:

- `POSTGRES_HOST` e.g `tiler-db`
- `POSTGRES_DB` e.g `tiler-osm`
- `POSTGRES_PORT` e.g `5432`
- `POSTGRES_USER` e.g `postgres`
- `POSTGRES_PASSWORD` e.g `1234`


#### Building the container

```
  cd tiler-db/
  docker network create osm-seed_default
  docker build -t osmseed-tiler-db:v1 .
```

#### Running the container

```
  docker run \
  --env-file ./../.env-tiler \
  --network osm-seed_default \
  -v $(pwd)/../postgres-gis-data:/var/lib/postgresql/data \
  -p "5432:5432" \
  -t osmseed-tiler-db:v1
```

### Test DB connection

```
psql -h tiler-db -p 5432 -d tiler-osm -U postgres --password
```