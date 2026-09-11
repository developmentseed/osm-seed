# osmcha-web

Builds the [osmcha-frontend](https://github.com/OSMCha/osmcha-frontend) at a pinned commit and serves it with nginx, proxying `/api` to the OSMCha Django API.

| | |
|---|---|
| Base image | `nginx:alpine` |
| Chart values key | `osmchaWeb` |
| Compose | `compose/osmcha.yaml` service `frontend` |
| Env files | `compose/envs/.env.osmcha.example` |

```sh
cd compose && docker compose -f osmcha.yaml build frontend && docker compose -f osmcha.yaml up frontend
```
