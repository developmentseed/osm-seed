# openstreetmap-cgimap

This container is built using the configuration from Zerebubuth's OpenStreetMap CGImap GitHub repository, with minor modifications.


# Build and up 

```sh
docker compose -f compose/cgmap.yml build
docker compose -f compose/cgmap.yml up
```

Note: Ensure that you are running PostgreSQL on your local machine. For example:


```sh
kubectl port-forward staging-db-0 5432:5432
```

Check results:

http://localhost/api/0.6/map?bbox=-77.09529161453248,-12.071898885565846,-77.077374458313,-12.066474684936727
