### Full history Container

Dockerfile for getting the full planet history of database.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../.env.db.example)
- [.env.full-history.example](./../../.env.full-history.example)
- [.env.cloudprovider.example](./../../.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.full-history` and `.env.cloudprovider`

#### Running full-history container

```sh
    # Docker compose
    docker-compose run full-history

    # Docker
    docker run \
    --env-file ./../.env.db \
    --env-file ./../.env.full-history \
    --env-file ./../.env.cloudprovider \
    -v ${PWD}/data/full-history-data:/mnt/data \
    --network osm-seed_default \
    -it osmseed-full-history:v1
```
