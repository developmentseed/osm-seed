# Docker setup for postgres database instance

The OSM `API server` database - builds off a postgres 10 docker image, and installs custom functions needed by `openstreetmap`.

The functions currently are copied over from the `openstreetmap-website` code-base. There should ideally be a better way to do this.

If run via the `docker-compose` file, running this container will expose the database on the host machine on port `5432`.

### Configuration

We are using the official postgres image we need to pass the following environment variable:

  - `POSTGRES_HOST` - Database host
  - `POSTGRES_DB` - Database name
  - `POSTGRES_USER` - Database user
  - `POSTGRES_PASSWORD` - Database user's password 

When we set up the above variables the container will create automatically the user, password and database in the on the container

### Building the container by itself in a network

```
docker build --network osm_network -t osmdb .
```

### Running the container

```
docker run \
--env-file ./../.env \
-p "5432:5432" \
--name db \
--network osm_network \
osmdb
```

### Test the DB connection

```
psql -h 0.0.0.0 -p 5432 -d openstreetmap -U postgres --password
```