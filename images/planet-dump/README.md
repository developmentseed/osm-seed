# planet-dump

Exports the apidb to a planet PBF and uploads it to S3. Runs as a CronJob.

| | |
|---|---|
| Base image | `osm-processor` |
| Chart values key | `planetDump` |
| Compose | `compose/planet.yaml` service `planet-dump` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.db-utils.example`, `compose/envs/.env.cloudprovider.example` |

```sh
cd compose && docker compose -f planet.yaml build planet-dump && docker compose -f planet.yaml up planet-dump
```
