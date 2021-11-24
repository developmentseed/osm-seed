# Backup and Restore the osm-seed DB

This container will create a backup of the osm-seed-db and compress according to the current date and then it will upload the backup file to s3 or Google store.


### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.db.example](./../../.env.db.example)
- [.env.backup-restore.example](./../../.env.backup-restore.example)
- [.env.cloudprovider.example](./../../.env.cloudprovider.example)

**Note**: Rename the above files as `.env.db`, `.env.backup-restore` and `.env.cloudprovider`

### Running the container

```sh
  # Docker compose
  docker-compose run db-backup-restore

  # Docker compose
  docker run \
    --env-file ./../.env.db \
    --env-file ./../.env.backup-restore \
    --env-file ./../.env.cloudprovider \
    --network osm-seed_default \
    -it osmseed-db-backup-restore:v1 
```

