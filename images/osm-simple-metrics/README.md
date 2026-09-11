# OSM Simple Metrics

This is a container that allows to extract simple metrics calculations for an OSM database.

Repo: https://github.com/developmentseed/osm-simple-metrics

#### Building the container


```sh
docker compose -f compose/osm-simple-metrics.yaml build
```

#### Access the container

```sh
docker-compose -f compose/osm-simple-metrics.yaml run osm-simple-metrics bash
```
