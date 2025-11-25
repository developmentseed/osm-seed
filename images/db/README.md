# Docker setup for postgres database instance

The OSM `API server` database - builds off a **PostgreSQL 17** docker image, and installs custom functions needed by `openstreetmap`.

The database includes the **osmdbt plugin v0.9** for logical replication support.

The functions currently are copied over from the `openstreetmap-website` code-base. There should ideally be a better way to do this.

If run via the `docker-compose` file, running this container will expose the database on the host machine on port `5432`.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../envs/.env.db.example)

**Note**: Rename the above files as `.env.db`

### Running DB container

```sh
  # Docker compose
  docker-compose run db

  # Docker
  docker run \
  --env-file ./envs/.env.db \
  --network osm-seed_default \
  --name db \
  -v ${PWD}/data/db-data:/var/lib/postgresql/data \
  -p "5432:5432" \
  -t osmseed-db:v1
```

### Test DB connection

```sh
  pg_isready -h 127.0.0.1 -p 5432
```

### Installed Components

- **PostgreSQL**: 17
- **osmdbt plugin**: v0.9 (osm_logical replication plugin)
