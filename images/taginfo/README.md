# OSM-Seed taginfo

We build a docker container for taginfo software, the container will start the web service and also process required files to create databases.

## Environment Variables

All environment variables are located at [`.env.taginfo.example`](./../../envs/.env.taginfo.example), make a copy and name it as `.env.tagninfo` to use in osm-seed.

- `URL_PLANET_FILE_STATE`: Url to the state file, that contains the URL for the latest planet PBF file. e.g [`state.txt`](https://planet.openhistoricalmap.org.s3.amazonaws.com/planet/state.txt), This is no required in case you set the `URL_PLANET_FILE` env var

- `URL_HISTORY_PLANET_FILE_STATE`: Url to the full history state file, that contains the URL for the latest full history planet PBF file. e.g [`state.txt`](https://planet.openhistoricalmap.org.s3.amazonaws.com/planet/full-history/state.txt), This is no required in case you set the `URL_HISTORY_PLANET_FILE` env var

- `URL_PLANET_FILE`: URL for the latest planet PBF file.
- `URL_HISTORY_PLANET_FILE`: URL for the latest full history planet PBF file.
- `TIME_UPDATE_INTERVAL` Interval time to update the databases, e.g: `50m` = every 50 minutes, `20h` = every 20 hours , `5d` = every 5 days

The following env vars are required in the instance to update the values at: https://github.com/taginfo/taginfo/blob/master/taginfo-config-example.json

- `OVERWRITE_CONFIG_URL`: config file with the values to update

- `DOWNLOAD_DB`: Taginfo instances need 7 Sqlite databases to start up the web service, all of them can be downloaded from https://taginfo.openstreetmap.org/download. Or if you can download only some of them you can pass herec. e.g DOWNLOAD_DB=`languages wiki`, or DOWNLOAD_DB=`languages wiki projects chronology`.

- `CREATE_DB`: If you want process you of data using the PBF files, you can pass the values. eg. CREATE_DB=`db projects` or CREATE_DB=`db projects chronology`.
  Note: 
  - Value `db` require to pass `URL_PLANET_FILE` or `URL_PLANET_FILE_STATE` 
  - Value `projects` require to pass `TAGINFO_PROJECT_REPO` 
  - Value `chronology` require to pass `URL_PLANET_FILE` or `URL_HISTORY_PLANET_FILE`

#### Running taginfo container

```sh
    # Docker compose
    docker-compose run taginfo

    # Docker
    docker run \
    --env-file ./envs/.env.taginfo \
    -v ${PWD}/data/taginfo-data:/apps/data/ \
    --network osm-seed_default \
    -it osmseed-taginfo:v1
```