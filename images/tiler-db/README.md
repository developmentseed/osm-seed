# Tiler-DB

PostGIS database container to store the osm-seed or osm data for tiling.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.tiler-db.example](./../../envs/.env.tiler-db.example)

**Note**: Rename the above files as `.env.tiler-db`


#### Running tiler-DB container

```sh
  # Docker compose
  docker-compose tiler-db

  #Dcoker 
  docker run \
    --env-file ./envs/.env.db-tiler \
    --network osm-seed_default \
    -v ${PWD}/data/tiler-db-data:/mnt/data \
    -p "5433:5432" \
    -t osmseed-tiler-db:v1
```

### Test tiler-DB connection

```sh
  pg_isready -h 0.0.0.0 -p 5433
```