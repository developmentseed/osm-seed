# Nominatim  (Nominatim version 3.6)

This version of Nominatim was copy from https://github.com/mediagis/nominatim-docker/tree/master/3.6, with certain updates  to fit in osm-seed enviroment

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.nominatim.example](./../../envs/.env.nominatim.example)

**Note**: Rename the above files as `.env.nominatim`

#### Running nominatim - DB and API container

```sh
    # Docker compose
    docker-compose run nominatim-db
    docker-compose run nominatim-api
```
