# Level0

[Level0](https://github.com/Zverik/Level0) is a text-based in-browser OSM
editor, useful for bulk edits that are hard to do in JOSM or iD. This image
runs it against any OSM-compatible API. The source is pinned to the commit in
`LEVEL0_GITSHA` in the Dockerfile.

Level0 hardcodes openstreetmap.org in a few places, so `start.sh` generates
`www/config.php` and patches the code at container start from these env vars:

| Env var | Default | Description |
|---|---|---|
| `OSM_WEBSITE_URL` | `https://www.openstreetmap.org` | Base URL of the website. OAuth2 endpoints and API derive from it. |
| `OSM_API_URL` | `<OSM_WEBSITE_URL>/api/0.6/` | API base URL, if it lives on another host. |
| `OAUTH2_CLIENT_ID` | — | OAuth2 app client id (register at `<website>/oauth2/applications` with `read_prefs` + `write_api`, redirect `https://<host>/index.php?action=callback`). |
| `OAUTH2_CLIENT_SECRET` | — | OAuth2 app client secret. |
| `OVERPASS_API` | — | Extra Overpass endpoint to whitelist, e.g. `overpass-api.openhistoricalmap.org/api`. |

## Local test

```bash
docker build -t level0 .
docker run -p 8080:80 \
  -e OSM_WEBSITE_URL=https://www.openhistoricalmap.org \
  -e OAUTH2_CLIENT_ID=<id> \
  -e OAUTH2_CLIENT_SECRET=<secret> \
  -e OVERPASS_API=overpass-api.openhistoricalmap.org/api \
  level0
# http://localhost:8080
```

## Notes

- The sqlite database only caches base files for conflict detection; it is
  ephemeral and pruned daily, so no persistent volume is needed.
- The OAuth redirect URI honors `X-Forwarded-Proto`, so login works behind a
  reverse proxy that terminates TLS.
