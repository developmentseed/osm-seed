# Overpass api

This continaer is base on: https://github.com/wiktorn/Overpass-API

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [..env.overpass.example](./../../compose/envs/.env.overpass.example)

**Note**: Rename the above files as `.env.overpass`

#### Running nominatim - DB and API container

```sh
    # Docker compose
    docker-compose run overpass-api
```
