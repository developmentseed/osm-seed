# taginfo-web

Runs the taginfo website (puma, port 4567) on the SQLite databases built by `taginfo`, downloaded from `TAGINFO_DB_BASE_URL` at start.

| | |
|---|---|
| Base image | `ruby:3.2-bookworm` |
| Chart values key | `taginfoWeb` |
| Compose | `compose/taginfo.yaml` service `taginfo_web` |
| Env files | `compose/envs/.env.taginfo.example` |

```sh
cd compose && docker compose -f taginfo.yaml build taginfo_web && docker compose -f taginfo.yaml up taginfo_web
```
