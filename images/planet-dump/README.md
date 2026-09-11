### Planet dump Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to create the planet dump in PBF format according to a schedule.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../compose/envs/.env.db.example)
- [.env.db-utils.example](./../../compose/envs/.env.db-utils.example)
- [.env.cloudprovider.example](./../../compose/envs/.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.db-utils` and `.env.cloudprovider`

### Build and bring up the container
```sh
docker compose -f ./compose/planet.yaml build
docker compose -f ./compose/planet.yaml up planet-dump
```
