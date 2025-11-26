# OSM-Seed taginfo

Docker container for taginfo that runs the web service and processes PBF files to create databases.

## Environment Variables

Copy [`.env.taginfo.example`](./../../envs/.env.taginfo.example) to `.env.taginfo` and configure:

### Planet Files
- `URL_PLANET_FILE_STATE`: URL to state file with latest planet PBF URL (optional if `URL_PLANET_FILE` is set)
- `URL_HISTORY_PLANET_FILE_STATE`: URL to state file with latest history PBF URL (optional if `URL_HISTORY_PLANET_FILE` is set)
- `URL_PLANET_FILE`: Direct URL to planet PBF file
- `URL_HISTORY_PLANET_FILE`: Direct URL to history PBF file

### Database Configuration
- `TAGINFO_DB_BASE_URL`: Base URL to download SQLite database files. Downloads: projects-cache.db, selection.db, taginfo-chronology.db, taginfo-db.db, taginfo-history.db, taginfo-languages.db, taginfo-master.db, taginfo-projects.db, taginfo-wiki.db, taginfo-wikidata.db
  - Example: `https://planet.openhistoricalmap.org.s3.amazonaws.com/taginfo`

- `DOWNLOAD_DB`: Which databases to download (e.g., `languages wiki` or `languages wiki projects chronology`)

- `CREATE_DB`: Which databases to create from PBF files (e.g., `db projects` or `db projects chronology`)
  - `db` requires `URL_PLANET_FILE` or `URL_PLANET_FILE_STATE`
  - `projects` requires `TAGINFO_PROJECT_REPO`
  - `chronology` requires `URL_PLANET_FILE` or `URL_HISTORY_PLANET_FILE`

### Other
- `TAGINFO_PROJECT_REPO`: Repository URL for taginfo projects (default: https://github.com/taginfo/taginfo-projects.git)
- `OVERWRITE_CONFIG_URL`: URL to custom taginfo config JSON file
- `INTERVAL_DOWNLOAD_DATA`: Interval to sync databases (e.g., `3600` for 1 hour, `7d` for 7 days)

## Running

```sh
# Docker compose
docker-compose run taginfo

# Docker
docker run \
  --env-file ./envs/.env.taginfo \
  -v ${PWD}/data/taginfo-data:/usr/src/app/data \
  --network osm-seed_default \
  -it osmseed-taginfo:v1
```
