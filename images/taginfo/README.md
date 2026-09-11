# taginfo

Builds the [taginfo](https://github.com/taginfo/taginfo) SQLite databases from a planet PBF (and the projects and wiki data) and uploads them to S3, on an interval. `taginfo-web` serves them.

| | |
|---|---|
| Base image | `ruby:3.2-slim` |
| Chart values key | `taginfoDataProcessor` |
| Compose | `compose/taginfo.yaml` service `taginfo_data` |
| Env files | `compose/envs/.env.taginfo.example` |

- Key env: `URL_PLANET_FILE` or `URL_PLANET_FILE_STATE`, `CREATE_DB` (`db projects chronology`), `DOWNLOAD_DB` (`languages wiki`), `TAGINFO_DB_BASE_URL`, `INTERVAL_DOWNLOAD_DATA`, `OVERWRITE_CONFIG_URL`.

```sh
cd compose && docker compose -f taginfo.yaml build taginfo_data && docker compose -f taginfo.yaml up taginfo_data
```
