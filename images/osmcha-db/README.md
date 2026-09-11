# osmcha-db

PostgreSQL 14 + PostGIS for OSMCha (`init-postgis.sql` enables the extension).

| | |
|---|---|
| Base image | `postgres:14` |
| Chart values key | `osmchaDb` |
| Compose | `compose/osmcha.yaml` |
| Env files | `compose/envs/.env.osmcha.example` |

- osmcha.yaml uses a stock postgis image for the DB; this image is what the chart deploys.
