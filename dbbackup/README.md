# Container to backup the osm-seed DB

This container will take a backup to the database and it will compress  according to the current date and finally, it will upload the file to S3

The container is not working fine with the docker-compose build. (TODO) 


### Building and running the container

- **Building**

```
docker build -t backup .
```

- **Run**

```
docker run \
-e POSTGRES_HOST=db \
-e POSTGRES_DB=openstreetmap \
-e POSTGRES_PASSWORD=1234 \
-e POSTGRES_USER=postgres \
-e AWS_ACCESS_KEY_ID=abcd \
-e AWS_SECRET_ACCESS_KEY=xyzu \
-e AWS_DEFAULT_REGION=us-east-1 \
-e S3_OSM_PATH="s3://osm-seed" \
--network osm_network \
-it backup /bin/bash

```

The output file should save in s3 👇 
![image](https://user-images.githubusercontent.com/1152236/40454691-6408a96a-5eaf-11e8-8de1-508cb13dced3.png)
