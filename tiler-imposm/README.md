# Tiler imposm

This container is responsible to import the replication PBF files from osm-seed or OSM planet dump into the `tiler-db`

If we are running the container for the first time the container will import the [OSM Land](http://data.openstreetmapdata.com/land-polygons-split-3857.zip) and [Natural Earth dataset](http://nacis.org/initiatives/natural-earth) and [osm-land] files into the data bases. [Check more here](https://github.com/go-spatial/tegola-osm#import-the-osm-land-and-natural-earth-dataset-requires-gdal-natural-earth-can-be-skipped-if-youre-only-interested-in-osm).



### Configuration

Required environment variables:

 **Env variables to connect to the db-tiler**

- `POSTGRES_HOST` e.g `tiler-db`
- `POSTGRES_DB` e.g `tiler-osm`
- `POSTGRES_PORT` e.g `5432`
- `POSTGRES_USER` e.g `postgres`
- `POSTGRES_PASSWORD` e.g `1234`

 **Env variables to  import the files**

- `TILER_IMPORT_FROM` e.g `osm` or `osmseed`
- `TILER_IMPORT_PBF_URL` eg `http://download.geofabrik.de/south-america/peru-latest.osm.pbf`



If you are setting up the variable TILER_IMPORT_PROM=`osmseed` you should fill following env variables according to which cloud provider you are going to use

- `CLOUDPROVIDER`, eg. `aws` or `gcp`

In case AWS:

- `AWS_S3_BUCKET` e.g `s3://osm-seed-test`

In case GCP:

- `GCP_STORAGE_BUCKET` e.g `gs://osm-seed-test`

Note: In case you use the `TILER_IMPORT_PROM`=`osmseed` you need to make public the minute replication files to update the DB with the recent changes.


#### Building the container

```
    cd tiler-imposm/
    docker network create osm-seed_default
    docker build -t osmseed-tiler-imposm:v1 .
```

#### Running the container

```
    docker run \
    --env-file ./../.env-tiler \
    --network osm-seed_default \
    -v ${PWD}:/mnt/data \
    -t osmseed-tiler-imposm:v1 
```

#### Access the container

```
    docker run \
    --env-file ./../.env-tiler \
    --network osm-seed_default \
    -v ${PWD}:/mnt/data \
    -it osmseed-tiler-imposm:v1 bash
```
