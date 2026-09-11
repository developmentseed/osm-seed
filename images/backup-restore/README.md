# backup-restore

Runs `pg_dump` of a database, compresses it with the date in the name and uploads it to S3; or restores a dump from S3. Used for web-db, tm-db and osmcha-db.

| | |
|---|---|
| Base image | `python:3.12-slim-bookworm` |
| Chart values key | `dbBackupRestore` |
| Compose | `compose/db-backup-restore.yaml` service `db-backup-restore` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.db-utils.example`, `compose/envs/.env.cloudprovider.example` |

```sh
cd compose && docker compose -f db-backup-restore.yaml build db-backup-restore && docker compose -f db-backup-restore.yaml up db-backup-restore
```
