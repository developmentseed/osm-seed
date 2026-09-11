# tasking-manager-api

[HOT Tasking Manager](https://github.com/hotosm/tasking-manager) backend (gunicorn, port 5000), built from a pinned commit. The same image runs the DB migrations.

| | |
|---|---|
| Base image | `ubuntu:20.04` |
| Chart values key | `tmApi` |
| Compose | `compose/tasking-manager.yaml` service `tmapi` |
| Env files | `compose/envs/.env.tasking-manager.example` |

```sh
cd compose && docker compose -f tasking-manager.yaml build tmapi && docker compose -f tasking-manager.yaml up tmapi
```
