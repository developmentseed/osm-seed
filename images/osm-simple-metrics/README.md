# osm-simple-metrics

Runs [osm-simple-metrics](https://github.com/developmentseed/osm-simple-metrics) against the apidb and uploads the CSV results to S3. Runs as a CronJob.

| | |
|---|---|
| Base image | `node:18` |
| Chart values key | `osmSimpleMetrics` |
| Compose | `compose/osm-simple-metrics.yaml` service `osm-simple-metrics` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.cloudprovider.example` |

```sh
cd compose && docker compose -f osm-simple-metrics.yaml build osm-simple-metrics && docker compose -f osm-simple-metrics.yaml up osm-simple-metrics
```
