# osm-processor

Base image with osmium, osmosis and the AWS CLI. `planet-dump`, `full-history` and `changesets-dump` build on it; it has no entrypoint of its own.

| | |
|---|---|
| Base image | `debian:bookworm-slim` |
| Chart values key | `osmProcessor` |
| Compose | `compose/planet.yaml` service `osm-processor` |

- Pinned by tag in the other three Dockerfiles; bump the tag there after changing this image.

```sh
cd compose && docker compose -f planet.yaml build osm-processor && docker compose -f planet.yaml up osm-processor
```
