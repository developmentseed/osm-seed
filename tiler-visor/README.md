# Tiler Visor

This container is over `nginx` imagen, the container is in charge to display the vector tiles rendered by tiler-server, the container takes the [tegola-web-demo](https://github.com/go-spatial/tegola-web-demo) and fix the configurations to connect to tiler-server and it will open the service on the port `8081`.

The stylization of vector tiles are based on: https://github.com/go-spatial/tegola-web-demo/tree/master/styles


### Configuration

This container needs some environment variables passed into it in order to run:

- `TILER_SERVER_PORT` e.g : 9090
- `TILER_SERVER_HOST` e.g: localhost
- `TILER_VISOR_HOST` e.g localhost
- `TILER_VISOR_PORT` e.g 8081