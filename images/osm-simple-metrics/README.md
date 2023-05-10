# OSM Simple Metrics

This is a contianer that allows to extract simple metrics calculations for an OSM database

Repo: https://github.com/developmentseed/osm-simple-metrics


#### Building the container


```sh
docker compose -f compose/osm-simple-metrics.yml build
```

#### Access the container

```sh
docker-compose -f compose/osm-simple-metrics.yml run osm-simple-metrics bash
```
