### Delta replications job container

This contain is responsible for creating the delta replication files it may be set up by minute, hour, etc. Those replications files will be uploaded to a repository in AWS or Google Storage, depends on what you are using.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../envs/.env.db.example)
- [.env.db-utils.example](./../../envs/.env.db-utils.example)
- [.env.cloudprovider.example](./../../envs/.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.db-utils` and `.env.cloudprovider`

#### Running replication-job container

```sh
    # Docker compose
    docker-compose run replication-job

    # Docker
    docker run \
    --env-file ./envs/.env.db \
    --env-file ./envs/.env.replication-job \
    --env-file ./envs/.env.cloudprovider \
    -v ${PWD}/data/replication-job-data:/mnt/data \
    --network osm-seed_default \
    -it osmseed-replication-job:v1
```
