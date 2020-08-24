# Tegola-Tiler-DB

PostGIS database container to store the tiles tegola (`tiler-server` container) serves.
Data is inserted using the `tiler-imposm` container.
This database is part of an independent pipeline separated from the main osm-seed tiler pipeline. The data is stored in a scheme adjusted for Tegola needs and thus the tiles needs to be stored in their own PostGIS.

### Configuration

Required environment variables:

- `TEGOLA_POSTGRES_HOST` e.g `tegola-tiler-db`
- `TEGOLA_POSTGRES_DB` e.g `tegola-tiler-osm`
- `TEGOLA_POSTGRES_PORT` e.g `5432`
- `TEGOLA_POSTGRES_USER` e.g `postgres`
- `TEGOLA_POSTGRES_PASSWORD` e.g `1234`


### Test DB connection

```
psql -h tegola-tiler-db -p 5432 -d tegola-tiler-osm -U postgres --password
```