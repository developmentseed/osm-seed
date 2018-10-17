# OSM-processor

This is a container that has a set of tools for the processing of OSM files, for processing you just to need to set the URL file `URL_FILE_TO_PROCESS` and the action `OMS_FILE_ACTION`, and then the container will return the results and uploading in an S3 or GCP bucket.

#### Building the container

The container will build automatically by docker-compose, but if you want to run separately you could follow the next command lines: 

```
  cd osm-processor/
  docker build -t osmseed-osm-processor:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -v ~/data:/app/data \
  -i -t osmseed-osm-processor:v1
```