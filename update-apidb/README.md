# Container to update APIDB


#### Building the container

The container will build automatically by docker-compose, but if you want to run separately  you could follow the next command lines: 

```
  cd populate-apidb/
  docker build -t osmseed-populate-apidb:v1 .
```

#### Running the container

```
  docker run --env-file ./../.env \
  --network osm-seed_default \
  -i -t osmseed-update-apidb:v1 bash
```