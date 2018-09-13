# Container to populate APIDB


This container is in charge to import data from PBF file or OSM files into the API database!


### Configuration

This container needs some environment variables passed into it in order to run:

**Files to import**

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

The container will build automatically by docker-compose, but if you want to run separately  you could follow the next command lines: 

```
  cd populate-apidb/
  docker build -t osmseed-populate-apidb:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -i -t osmseed-populate-apidb:v1 bash
```

 
*Note:*

If you want to customize the size of you import check [here](doc.md) to clip your data.