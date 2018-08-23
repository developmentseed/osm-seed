# Tiler imposm

This container is responsible for importing the replication PBF files from OMS-seed planed dump into the GIS database.

If we are running the container for the first time the container will import the [OSM Land](http://data.openstreetmapdata.com/land-polygons-split-3857.zip) and [Natural Earth dataset](http://nacis.org/initiatives/natural-earth) and [osm-land] files into the data bases. [Check more here](https://github.com/go-spatial/tegola-osm#import-the-osm-land-and-natural-earth-dataset-requires-gdal-natural-earth-can-be-skipped-if-youre-only-interested-in-osm).

The container should execute according to cron job schedule, according to how often we want to update the PostGIS database. If the container is running for second or x times, it will check if the tables exist database, and it will need only to update the database with the new pbf files.


### Configuration

This container needs some environment variables passed into it in order to run:

- `GIS_POSTGRES_HOST` e.g `tiler-db`
- `GIS_POSTGRES_DB` e.g `gis_osm`
- `GIS_POSTGRES_USER` e.g `postgres`
- `GIS_POSTGRES_PASSWORD` e.g `1234`