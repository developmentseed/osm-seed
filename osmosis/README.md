### Osmosis Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to run various tasks:

 - Import OSM data from a pbf file on s3 into the api database
 - Export data from the api database to osm.bz2 and upload to s3

This container needs some environment variables passed into it in order to run:

- `S3_OSM_PATH` - path  to bucket e.g: `s3://osm-seed`
- `AWS_ACCESS_KEY_ID` - your AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret
- `AWS_DEFAULT_REGION` - AWS region for s3 access
- `POSTGRES_HOST` - db
- `POSTGRES_DB` - openstreetmap
- `POSTGRES_USER` - postgres
- `POSTGRES_PASSWORD`  - 1234


### Building and running the container

- **Building**

```
docker build  -t rep .
```

- **Runing**

```
docker run \
--network osm_network \
-e S3_OSM_PATH=s3://osm-seed \
-e AWS_ACCESS_KEY_ID=abc \
-e AWS_SECRET_ACCESS_KEY=xyz \
-e AWS_DEFAULT_REGION=us-east-1 \
-e POSTGRES_HOST=db \
-e POSTGRES_DB=openstreetmap \
-e POSTGRES_PASSWORD=1234 \
-e POSTGRES_USER=postgres \
-e AWS_ACCESS_KEY_ID=abcd \
-e AWS_SECRET_ACCESS_KEY=xyzu \
-e AWS_DEFAULT_REGION=us-east-1 \
-e S3_OSM_PATH="s3://osm-seed" \
-it rep bash
```

The output file should save in s3 👇 
![image](https://user-images.githubusercontent.com/1152236/40563702-626f15b2-602b-11e8-9621-40b1b1a240c0.png)
