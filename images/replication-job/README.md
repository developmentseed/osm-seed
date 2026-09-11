# replication-job

Publishes minute diffs from the apidb with [osmdbt](https://github.com/openstreetmap/osmdbt): every minute it reads the `osm_repl` logical replication slot, writes `NNN.osc.gz` + `state.txt`, checks them and uploads them to S3. State is recovered from S3 on restart, corrupt or orphan files are cleaned up and errors go to Slack.

| | |
|---|---|
| Base image | `debian:bookworm` |
| Chart values key | `replicationJob` |
| Compose | `compose/planet.yaml` service `replication-job` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.db-utils.example`, `compose/envs/.env.cloudprovider.example` |

- The DB user needs `REPLICATION` and `SELECT` on `changesets`.
- Extra env: `REPLICATION_SLOT` (`osm_repl`), `REPLICATION_FOLDER` (`replication`), `ENABLE_SEND_SLACK_MESSAGE`, `SLACK_WEBHOOK_URL`, `ENVIRONMENT`.

```sh
cd compose && docker compose -f planet.yaml build replication-job && docker compose -f planet.yaml up replication-job
```
