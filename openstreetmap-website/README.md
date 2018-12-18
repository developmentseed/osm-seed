# Docker setup for openstreetmap-website

The docker container installs dependencies required for the website, checks out the latest openstreetmap-website code from github and sets up config files.

### Configuration

To run the container needs a bunch of ENV variables which are:

- **Configure the HOST and the PROTOCOL**

  - `SERVER_URL` We need to setup the url to the server to send the email
  - `SERVER_PROTOCOL`  protocolo, e.g `http`

- **Configure ActionMailer SMTP**

  - `MAILER_ADDRESS` e.g smtp.gmail.com
  - `MAILER_DOMAIN` e.g gmail.com
  - `MAILER_USERNAME` e.g osmseed@gmail.com
  - `MAILER_PASSWORD` e.g 1234

- **Configure Postgres Database**

  - `POSTGRES_HOST` - Database host
  - `POSTGRES_DB` - Database name
  - `POSTGRES_USER` - Database user
  - `POSTGRES_PASSWORD` - Database user's password 

Those parameters must be set up for the run the container, not required to build the container


### Building the container

Before to start the api, you should first create the [api-db](https://github.com/developmentseed/osm-seed/tree/master/db).


```
    cd openstreetmap-website/
    docker network create osm-seed_default
    docker build -t osmseed-openstreetmap-website:v1 .
```


### Running the container

```
    docker run \
    --env-file ./../.env \
    --network osm_network \
    -p "80:80" \
    -h localhost \
    -t osmseed-openstreetmap-website:v1
```