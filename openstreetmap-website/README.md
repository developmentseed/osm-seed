# Docker setup for openstreetmap-website

The docker container installs dependencies required for the website, checks out the latest openstreetmap-website code from github and sets up config files.

### Configuration

To run the container needs a bunch of ENV variables which are:

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


### Building the container by itself in a network

To run this command you should first create the [DB](https://github.com/developmentseed/osm-seed/tree/master/db).


```
docker build --network osm_network -t prod .
```

### Running the container

```
docker run \
--env-file ./../.env \
--network osm_network \
-p "80:80" \
-h localhost \
-it prod 
```

## Build and Run the container using docker-compose

If you wan to run the infraestructure at once, check the [../README.md](https://github.com/developmentseed/osm-seed/blob/master/README.md)




