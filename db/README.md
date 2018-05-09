### Docker setup for postgres database instance

The OSM `API server` database - builds off a postgres 9.4 docker image, and installs custom functions needed by `openstreetmap`.

The functions currently are copied over from the `openstreetmap-website` code-base. There should ideally be a better way to do this.

If run via the `docker-compose` file, running this container will expose the database on the host machine on port `5431`.

You can run this container by itself by doing `docker build .` and `docker run <image_id>`