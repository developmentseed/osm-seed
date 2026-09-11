# tiler-db

PostGIS database for vector tiles. imposm writes here and tiler-server reads from it. `config/` holds the PostgreSQL tuning.

| | |
|---|---|
| Base image | `postgis/postgis:14-3.4` |
| Chart values key | `tilerDb` |
| Compose | `compose/tiler.yaml` service `tiler-db` |
| Env files | `compose/envs/.env.tiler-db.example` |

```sh
cd compose && docker compose -f tiler.yaml build tiler-db && docker compose -f tiler.yaml up tiler-db
```
