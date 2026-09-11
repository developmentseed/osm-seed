# changeset-replication-job

Publishes changeset replication files with [openstreetmap-changeset-replication](https://github.com/zerebubuth/openstreetmap-changeset-replication) and uploads them to `replication/changesets` in S3. State is recovered from S3 on restart.

| | |
|---|---|
| Base image | `ruby:2.4` |
| Chart values key | `changesetReplicationJob` |
| Compose | `compose/planet.yaml` service `changeset-replication-job` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.cloudprovider.example` |

```sh
cd compose && docker compose -f planet.yaml build changeset-replication-job && docker compose -f planet.yaml up changeset-replication-job
```
