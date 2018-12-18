# Tiler Visor

This container is over `nginx` imagen, the container is in charge to display the vector tiles rendered by `tiler-server`, the container takes the [tegola-web-demo](https://github.com/go-spatial/tegola-web-demo) and fix the configurations to connect to `tiler-server` and it will open the service on the port `8081`.

The stylization of vector tiles are based on: https://github.com/go-spatial/tegola-web-demo/tree/master/styles


### Configuration

Required environment variables:

**Env variables to access to tiler-serve**

- `TILER_SERVER_PORT` e.g `9090`
- `TILER_SERVER_HOST` e.g `localhost`

**Env variables to serve the visor**

- `TILER_VISOR_HOST` e.g `localhost`
- `TILER_VISOR_PROTOCOL` e.g `http`
- `TILER_VISOR_PORT` e.g `8081`


#### Building the container

```
    cd tiler-visor/
    docker network create osm-seed_default
    docker build -t osmseed-tiler-visor:v1 .
```

#### Running the container

```
  docker run \
  --env-file ./../.env-tiler \
  --network osm-seed_default \
  -p "8081:80" \
  -t osmseed-tiler-visor:v1
```