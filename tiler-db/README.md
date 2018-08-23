# Tiler-DB

This container contains the PostGIS database, to populate the database we are using `Tiler-imposm` as an importer of data from natural and osm-seed db.

### Configuration

This container needs some environment variables passed into it in order to run:

- `GIS_POSTGRES_HOST` e.g `tiler-db`
- `GIS_POSTGRES_DB` e.g `gis_osm`
- `GIS_POSTGRES_USER` e.g `postgres`
- `GIS_POSTGRES_PASSWORD` e.g `1234`
- `POSTGIS_VERSION` e.g `2.4.4`