# overpass-api

[Overpass API](https://github.com/wiktorn/Overpass-API) with an entrypoint that imports a planet file on first start and then applies minute diffs.

| | |
|---|---|
| Base image | `wiktorn/overpass-api:0.7.62` |
| Chart values key | `overpassApi` |
| Compose | `compose/overpass.yaml` service `overpass-api` |
| Env files | `compose/envs/.env.overpass.example` |

```sh
cd compose && docker compose -f overpass.yaml build overpass-api && docker compose -f overpass.yaml up overpass-api
```
