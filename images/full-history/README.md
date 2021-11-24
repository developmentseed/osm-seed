### Full history Container

Dockerfile for getting the full planet history of database.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../envs/.env.db.example)
- [.env.full-history.example](./../../envs/.env.full-history.example)
- [.env.cloudprovider.example](./../../envs/.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.full-history` and `.env.cloudprovider`

#### Running full-history container

```sh
    # Docker compose
    docker-compose run full-history

    # Docker
    docker run \
    --env-file ./envs/.env.db \
    --env-file ./envs/.env.full-history \
    --env-file ./envs/.env.cloudprovider \
    -v ${PWD}/data/full-history-data:/mnt/data \
    --network osm-seed_default \
    -it osmseed-full-history:v1
```
