### Osmosis Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to run various tasks:

 - Export data from the Database to osm file `history-latest-${date}`
 - Comporess the osm filfile to `history-latest-${date}.osm.bz2` and upload to s3
 - Convert the osm file to PBF `history-latest-${date}.pbf` and upload to s3

### Configuration

This container needs some environment variables passed into it in order to run:

- `POSTGRES_HOST` - db
- `POSTGRES_DB` - openstreetmap
- `POSTGRES_USER` - postgres
- `POSTGRES_PASSWORD`  - 1234

Depends on what types of data storage are you going to use, the following variables should be established:

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


#### Building the container

```
docker build  -t osmosis .
```

#### Running the container

```
docker run \
--env-file ./../.env \
--network osm_network \
-it osmosis 
```

The output files should save in s3 👇 
![image](https://user-images.githubusercontent.com/1152236/40563702-626f15b2-602b-11e8-9621-40b1b1a240c0.png)
