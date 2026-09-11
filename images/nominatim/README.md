# nominatim

[Nominatim](https://nominatim.org) geocoder, from `mediagis/nominatim` with an osm-seed entrypoint that imports a PBF on first start and then applies updates.

| | |
|---|---|
| Base image | `mediagis/nominatim:4.5` |
| Chart values key | `nominatimApi` |
| Compose | `compose/nominatim.yaml` service `nominatim-api` |
| Env files | `compose/envs/.env.nominatim.example` |

- A restart during the import drops the database and starts over; give the first run enough time.

```sh
cd compose && docker compose -f nominatim.yaml build nominatim-api && docker compose -f nominatim.yaml up nominatim-api
```
