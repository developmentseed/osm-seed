# Base container for processing and extrating  OSM format files

Base container for other containers in osmseed ecosystem, it contains:

-  [osmosis](https://wiki.openstreetmap.org/wiki/Osmosis/Detailed_Usage_0.47)
-  [osmium-tool](https://osmcode.org/osmium-tool/)

#### Building the container


```
  cd osm-processor/
  docker build -t osmseed-osm-processor:v1 .
```

#### Access the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -v $(pwd)/../osm-processor-data:/mnt/data \
  -i -t osmseed-osm-processor:v1 bash
```