# Backup and Restore the osm-seed DB

This container will take a backup of the osm-seed database and will compress according to the current date and then it will upload the backup file to S3.


### Configuration

To run the container needs a bunch of ENV variables:

- `POSTGRES_HOST` - Database host
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database user's password

*Depends on what types of data storage are you going to use, the following variables should be established:*

#### Amazon S3

- `AWS_ACCESS_KEY_ID` 
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION` e.g `us-east-1`
- `S3_OSM_PATH`  e.g `s3://osm-seed`

#### Google Storage - SG

# Google Store access

- `GS_OSM_PATH` Google storage bucket
- `GCLOUD_SERVICE_KEY` base64 encode key e.g: `base64 osm-seed-04ee080a55c5.json`
- `GCLOUD_PROJECT` name of your project

*Database action*

- `DB_ACTION` e.g `backup` or `restore`

Change the `DB_ACTION` variable to restore or backup the database. `DB_ACTION` =  `restore` or `backup`

### Building and running the container

- **Building**

```
docker build -t backup-restore .
```

- **Running**

```
docker run \
--env-file ./../.env \
--network osm_network \
-it backup-restore
```

The output file should save in s3 👇 
![image](https://user-images.githubusercontent.com/1152236/40454691-6408a96a-5eaf-11e8-8de1-508cb13dced3.png)
