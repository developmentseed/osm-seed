# full-history

Exports the full history of the apidb (`history-latest.osm.pbf`) and uploads it to S3. Runs as a CronJob.

| | |
|---|---|
| Base image | `osm-processor` |
| Chart values key | `fullHistory` |
| Compose | `compose/planet.yaml` service `full-history` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.db-utils.example`, `compose/envs/.env.cloudprovider.example` |

```sh
cd compose && docker compose -f planet.yaml build full-history && docker compose -f planet.yaml up full-history
```
