# planet-files

nginx + a small node server that lists and serves the planet, replication and changeset files, like planet.openstreetmap.org.

| | |
|---|---|
| Base image | `nginx` |
| Chart values key | `planetFiles` |
| Compose | `compose/planet.yaml` service `planet-files` |

- Not deployed by the chart yet: `planetFiles` has no template.

```sh
cd compose && docker compose -f planet.yaml build planet-files && docker compose -f planet.yaml up planet-files
```
