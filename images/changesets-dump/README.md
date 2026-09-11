# changesets-dump

Exports all changesets (`changesets-latest.osm.bz2`, like planet.openstreetmap.org) from the apidb and uploads it to S3. Runs as a CronJob.

| | |
|---|---|
| Base image | `osm-processor` |
| Chart values key | `changesetsDump` |
| Compose | `compose/planet.yaml` service `changesets-dump` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.db-utils.example`, `compose/envs/.env.cloudprovider.example` |

```sh
cd compose && docker compose -f planet.yaml build changesets-dump && docker compose -f planet.yaml up changesets-dump
```
