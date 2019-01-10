# Backup and Restore the osm-seed DB

This container will create a backup of the osm-seed-db and compress according to the current date and then it will upload the backup file to s3 or Google store.


### Configuration

To run the container needs a bunch of ENV variables:

- `POSTGRES_HOST` - Database host
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database user's password

The following env variables are according to which cloud provider you are going to use:

- `CLOUDPROVIDER`, eg. `aws` or `gcp`

In case AWS:

- `AWS_S3_BUCKET` e.g `s3://osm-seed-test`

In case GCP:

- `GCP_STORAGE_BUCKET` e.g `gs://osm-seed-test`

*Database action*

- `DB_ACTION` e.g `backup` or `restore`

Change the `DB_ACTION` variable to restore or backup the database. `DB_ACTION` =  `restore` or `backup`

### Building the container

```
  cd db-backup-restore/
  docker network create osm-seed_default 
  docker build -t osmseed-db-backup-restore:v1 .
```

### Running the container


```
docker run \
--env-file ./../.env \
--network osm-seed_default \
-it osmseed-db-backup-restore:v1 
```