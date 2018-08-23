# Tiler server

This container is responsible for rendering the vector tiles base [Tegola](https://github.com/go-spatial/tegola) technology, the server connects to the database tiler-db and serves the service through the port `9090`.


### Configuration

This container needs some environment variables passed into it in order to run:

- `TILER_SERVER_PORT` e.g `9090`
- `CACHE_TYPE` e.g `file`, for now, we are using the local file as the cache storage
- `GIS_POSTGRES_HOST` e.g `tiler-db`
- `GIS_POSTGRES_DB` e.g `gis_osm`
- `GIS_POSTGRES_USER` e.g `postgres`
- `GIS_POSTGRES_PASSWORD` e.g `1234`