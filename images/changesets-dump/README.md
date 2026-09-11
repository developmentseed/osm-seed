### Changesets dump container

Dockerfile for generating a full-history changesets dump
(`changesets-latest.osm.bz2`) from the OpenHistoricalMap API DB, equivalent
to the file OSM publishes at `planet.openstreetmap.org/planet/changesets-latest.osm.bz2`.
Used downstream for changeset analysis (e.g. extracting `imagery_used` /
`source` tags to identify tile servers and imagery layers).

The dump is produced by `planet-dump-ng --changesets` from a PostgreSQL
`.dump` file of the API DB.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../compose/envs/.env.db.example)
- [.env.db-utils.example](./../../compose/envs/.env.db-utils.example)
- [.env.cloudprovider.example](./../../compose/envs/.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.db-utils` and `.env.cloudprovider`

### Build and bring up the container
```sh
docker compose -f ./compose/planet.yaml build
docker compose -f ./compose/planet.yaml up changesets-dump
```
