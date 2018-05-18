### Docker setup for postgres database instance

The OSM `API server` database - builds off a postgres 10 docker image, and installs custom functions needed by `openstreetmap`.

The functions currently are copied over from the `openstreetmap-website` code-base. There should ideally be a better way to do this.

If run via the `docker-compose` file, running this container will expose the database on the host machine on port `5431`.


### Running container by itself in a network


- Create a network for the DB and openstreetmap-website


```
docker network create osm_network

```

- Build the container

```
docker build --network osm_network -t osmdb .

```


- Run the container

We are using the official postgres image we can pass in a username and password as an environment variable when you docker run it. Like so:


```
docker run -d \
-e POSTGRES_DB=openstreetmap \
-e POSTGRES_PASSWORD=1234 \
-e POSTGRES_USER=postgres \
-p "5432:5432" \
--name osmdatabase  \
--network osm_network \
osmdb
```

- The above line will create automatically the user, password and database in the on the container

### Test the DB connection

```
psql -h 0.0.0.0 -p 5432 -d openstreetmap -U postgres --password

```