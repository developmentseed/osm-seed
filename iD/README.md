# iD Editor container

- 

```
docker build -t id .
```



```
docker run \
--env-file ./../.env \
--network osm_network \
-p "8081:8080" \
-h localhost \
-it id 
```