### Planet dump Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to create the planet dump in PBF format according to a schedule.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../envs/.env.db.example)
- [.env.db-utils.example](./../../envs/.env.db-utils.example)
- [.env.cloudprovider.example](./../../envs/.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.db-utils` and `.env.cloudprovider`

#### Running planet-dump container

```sh
    # Docker compose
    docker-compose run planet-dump

    # Docker
    docker run \
    --env-file ./envs/.env.db \
    --env-file ./envs/.env.planet-dump \
    --env-file ./envs/.env.cloudprovider \
    -v ${PWD}/data/planet-dump-data:/mnt/data \
    --network osm-seed_default \
    -it osmseed-planet-dump:v1
```
