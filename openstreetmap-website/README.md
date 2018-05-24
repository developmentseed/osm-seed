### Docker setup for openstreetmap-website

The docker container installs dependencies required for the website, checks out the latest openstreetmap-website code from github and sets up config files.

Config files can be edited in the `config/` folder.

###  Configuration

- **Configure ActionMailer SMTP**

We need to configure the next lines in the `./config/application.yml` file.

```
  support_email: support_osmseed@gmail.com
  email_from: "OpenStreetMap <osmseed@gmail.com>"
  email_return_path: "osmseed@gmail.com"

```

And we have to prepare the ENV Variables for mailer


- `MAILER_ADDRESS` e.g "smtp.gmail.com"
- `MAILER_DOMAIN` e.g "gmail.com"
- `MAILER_USERNAME` e.g "osmseed@gmail.com"
- `MAILER_PASSWORD` e.g 1234

- **Configure the DB paramters**

We have to configure the `./config/database.yml` file.

e.g:

```
production:
  adapter: postgresql
  database: openstreetmap
  username: postgres
  password: 1234
  host: db
  encoding: utf8
```

Those parameters will pass in the build process

NOTE:
	- This parameter should be fixed, Passing the arguments or variables in the compilation (TODO)


### Building the container by itself in a network

To run this command you should first create the [DB](https://github.com/developmentseed/osm-seed/tree/master/db).


```
docker build --network osm_network -t prod .

```

### Running the container

This container needs some environment variables passed into it in order to run:

```
docker run \
-e MAILER_ADDRESS="smtp.gmail.com" \
-e MAILER_DOMAIN="gmail.com" \
-e MAILER_USERNAME="osmseed@gmail.com" \
-e MAILER_PASSWORD=1234 \
--network osm_network \
-p "80:80" \
-h localhost \
-it prod 
```

If you want to access the container add `/bin/bash` in the last part of the previous command and you could change some configurations or check the log output.


## Build and Run the container using docker-compose

If you wan to run the  all infraestructure at once, check the [../README.md](https://github.com/developmentseed/osm-seed/blob/master/README.md)




