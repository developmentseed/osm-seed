# Base container for dumping the OHM API DB to PBF / OSM XML

Slim base image used by jobs that read the OpenHistoricalMap API DB into
planet files (`planet-dump`, `full-history`, `changesets-dump`).

Contents:

- [planet-dump-ng](https://github.com/OpenHistoricalMap/planet-dump-ng) (built from the OHM `planet_epoch_date` branch)
- Cloud CLIs: `awscli`, `gsutil`, `azure-cli`
- `bzip2`, `curl`

This image intentionally does **not** ship `osmosis`, `osmium-tool`,
`pyosmium` or `postgresql-client`. Jobs that need to write to the API DB
(e.g. `populate-apidb`) install their own toolchain.

#### Building the container

```
cd osm-processor/
docker build -t osmseed-osm-processor:v3 .
```

#### Access the container

```
docker run --env-file ./../.env \
  --network osm-seed_default \
  -v $(pwd)/../osm-processor-data:/mnt/data \
  -i -t osmseed-osm-processor:v3 bash
```
