# level0

[Level0](https://github.com/Zverik/Level0), a text-based in-browser OSM editor for bulk edits, patched at start to work against any OSM-compatible API and OAuth2 provider.

| | |
|---|---|
| Base image | `php:8.3-apache` |
| Chart values key | `level0` |

- Env: `OSM_WEBSITE_URL`, `OSM_API_URL` (default `<website>/api/0.6/`), `OAUTH2_CLIENT_ID`, `OAUTH2_CLIENT_SECRET` (app with `read_prefs` + `write_api`, redirect `https://<host>/index.php?action=callback`), `OVERPASS_API`.
- Its sqlite cache is ephemeral; no volume needed. Login works behind a TLS-terminating proxy (`X-Forwarded-Proto`).
