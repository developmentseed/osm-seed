# tiler-server

Serves vector tiles from tiler-db with [Tegola](https://github.com/go-spatial/tegola) on port 9090. Side processes purge expired tiles from the cache (file or S3) and restart stuck tegola processes.

| | |
|---|---|
| Base image | `gospatial/tegola:v0.20.0` |
| Chart values key | `tilerServer` |
| Compose | `compose/tiler.yaml` service `tiler-server` |
| Env files | `compose/envs/.env.tiler-db.example`, `compose/envs/.env.tiler-server.example` |

```sh
cd compose && docker compose -f tiler.yaml build tiler-server && docker compose -f tiler.yaml up tiler-server
```
