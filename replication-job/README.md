### Osmosis Replication job container

### Configuration

#### Running the container

```
docker run --env-file ./../.env \
--network osm-seed_default \
-it openseed-replication-job:v1 bash
```
