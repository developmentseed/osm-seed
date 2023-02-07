# Container to populate APIDB

This container is in charge to import data from PBF file or OSM files into the API database.

### Configuration

This container needs some environment variables passed into it in order to run:

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../envs/.env.db.example)
- [.env.db-utils.example](./../../envs/.env.db-utils.example)

**Note**: Rename the above files as `.env.db` and `.env.db-utils`

- `URL_FILE_TO_IMPORT` it could be a PBF file or OSM file.

Get those files form 👇

- http://download.geofabrik.de/
- https://wiki.openstreetmap.org/wiki/Planet.osm

#### Running planet-dump container

```sh
    # Docker compose
    docker-compose run populate-apidb

    # Docker
    docker run \
    --env-file ./envs/.env.db \
    --env-file ./envs/.env.db-utils \
    -v ${PWD}/data/populate-apidb-data:/mnt/data \
    --network osm-seed_default \
    -it osmseed-populate-apidb:v1
```
