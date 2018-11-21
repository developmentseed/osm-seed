# Tiler Visor

This container is over `nginx` imagen, the container is in charge to display the vector tiles rendered by `tiler-server`, the container takes the [tegola-web-demo](https://github.com/go-spatial/tegola-web-demo) and fix the configurations to connect to `tiler-server` and it will open the service on the port `8081`.

The stylization of vector tiles are based on: https://github.com/go-spatial/tegola-web-demo/tree/master/styles


### Configuration

Required environment variables:

- `TILER_SERVER_PORT` e.g `9090`
- `TILER_SERVER_HOST` e.g `localhost`
- `TILER_VISOR_HOST` e.g `localhost`
- `TILER_VISOR_PROTOCOL` e.g `http`
- `TILER_VISOR_PORT` e.g `8081`


#### Building the container

```
  docker build -t osmseed-tiler-visor:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -t osmseed-tiler-visor:v1
```