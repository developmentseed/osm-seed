### Full history Container

Dockerfile for getting the full planet history of database.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../envs/.env.db.example)
- [.env.db-utils.example](./../../envs/.env.db-utils.example)
- [.env.cloudprovider.example](./../../envs/.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.db-utils` and `.env.cloudprovider`

### Build and bring up the container
```sh
docker compose -f ./compose/planet.yml build
docker compose -f ./compose/planet.yml up full-history
```
