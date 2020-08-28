# Container to populate APIDB


This container is in charge to import data from PBF file or OSM files into the API database.


### Configuration

This container needs some environment variables passed into it in order to run:


- `URL_FILE_TO_IMPORT` it could be a PBF file or OSM file.

Get the files form :

- http://download.geofabrik.de/
- https://wiki.openstreetmap.org/wiki/Planet.osm

**APIDB configuration**

  - `POSTGRES_HOST`e.g localhost
  - `POSTGRES_DB` e.g openstreetmap
  - `POSTGRES_USER` e.g postgres
  - `POSTGRES_PASSWORD` e.g 1234

#### Building the container


```
    cd populate-apidb/
    docker network create osm-seed_default
    docker build -t osmseed-populate-apidb:v1 .
```

#### Running the container

```
  docker run \
  --env-file ./../.env \
  --network osm-seed_default \
  -t osmseed-populate-apidb:v1
```