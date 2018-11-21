# Tiler imposm

This container is responsible to import the replication PBF files from OMS-seed or OMS planet dump into the `tiler-db`

If we are running the container for the first time the container will import the [OSM Land](http://data.openstreetmapdata.com/land-polygons-split-3857.zip) and [Natural Earth dataset](http://nacis.org/initiatives/natural-earth) and [osm-land] files into the data bases. [Check more here](https://github.com/go-spatial/tegola-osm#import-the-osm-land-and-natural-earth-dataset-requires-gdal-natural-earth-can-be-skipped-if-youre-only-interested-in-osm).



### Configuration

Required environment variables:

- `GIS_POSTGRES_HOST` e.g `tiler-db`
- `GIS_POSTGRES_DB` e.g `gis_osm`
- `GIS_POSTGRES_USER` e.g `postgres`
- `GIS_POSTGRES_PASSWORD` e.g `1234`

#### Building the container

```
  docker build -t osmseed-tiler-imposm:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -t osmseed-tiler-imposm:v1
```