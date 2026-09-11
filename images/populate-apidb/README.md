# populate-apidb

One-off job that imports a PBF or OSM file (`URL_FILE_TO_IMPORT`) into the apidb with osmosis.

| | |
|---|---|
| Base image | `debian:bookworm-slim` |
| Chart values key | `populateApidb` |
| Compose | `compose/populate-apidb.yaml` service `populate-apidb` |
| Env files | `compose/envs/.env.db.example`, `compose/envs/.env.db-utils.example` |

```sh
cd compose && docker compose -f populate-apidb.yaml build populate-apidb && docker compose -f populate-apidb.yaml up populate-apidb
```
