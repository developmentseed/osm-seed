
# Planet server files

This container is based on Nginx and serves data related to planet, replication, and changesets for easy access and download, similar to how it is done in OpenStreetMap.


# Build and bring up the container
```sh
docker compose -f ./compose/planet.yml build
docker compose -f ./compose/planet.yml up planet-files
```