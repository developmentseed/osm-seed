# cgimap

Builds [CGImap](https://github.com/zerebubuth/openstreetmap-cgimap), the C++ implementation of the read-heavy API 0.6 calls (`map`, node/way/relation reads). The website proxies those calls here.

| | |
|---|---|
| Base image | `debian:bookworm-slim` |
| Chart values key | `cgimap` |
| Compose | `compose/cgimap.yaml` service `cgimap` |
| Env files | `compose/envs/.env.db.example` |

```sh
cd compose && docker compose -f cgimap.yaml build cgimap && docker compose -f cgimap.yaml up cgimap
```
