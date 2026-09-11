# web

Builds [openstreetmap-website](https://github.com/openstreetmap/openstreetmap-website) (website + API 0.6) at a pinned commit, applies the patches in `patches/` and writes its config from env vars at start.

| | |
|---|---|
| Base image | `ruby:3.3-slim` |
| Chart values key | `webApi` |
| Compose | `compose/web.yaml` service `web` |
| Env files | `compose/envs/.env.web.example`, `compose/envs/.env.db.example` |

- Needs `db` (apidb) and, in production, `cgimap` and `memcached`.
- Email (SMTP) settings are in `.env.web.example`.

```sh
cd compose && docker compose -f web.yaml build web && docker compose -f web.yaml up web
```
