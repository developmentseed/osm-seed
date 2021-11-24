### Planet dump Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to create the planet dump in PBF format according to a schedule.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../.env.db.example)
- [.env.planet-dump.example](./../../.env.planet-dump.example)
- [.env.cloudprovider.example](./../../.env.cloudprovider.example)

**Note**: Make a copy and rename the files as `.env.db`, `.env.planet-dump` and `.env.cloudprovider`

#### Running planet-dump container

```sh
    # Docker compose
    docker-compose run planet-dump

    # Docker
    docker run \
    --env-file ./../.env.db \
    --env-file ./../.env.planet-dump \
    --env-file ./../.env.cloudprovider \
    -v ${PWD}/data/planet-dump-data:/mnt/data \
    --network osm-seed_default \
    -it osmseed-planet-dump:v1
```
