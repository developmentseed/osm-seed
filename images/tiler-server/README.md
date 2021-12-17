# Tiler server

This container is for rendering the vector tiles base on [Tegola](https://github.com/go-spatial/tegola), the container connects to the database `tiler-db` and serves the tiles through the port `9090`.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.tiler-db.example](./../../envs/.env.tiler-db.example)
- [.env.tiler-server.example](./../../envs/.env.tiler-server.example)

**Note**: Rename the above files as `.env.tiler-db` and `.env.tiler-server`

#### Running tiler-server container

```sh
    # Docker compose
    docker-compose run tiler-server

    # Docker
    docker run \
      --env-file ./envs/.env.tiler-db \
      --env-file ./envs/.env.tiler-server \
      -v ${PWD}/data/tiler-server-data:/mnt/data \
      --network osm-seed_default \
      -p "9090:9090" \
      -it osmseed-tiler-server:v1
```
