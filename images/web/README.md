# Docker setup for openstreetmap-website

The docker container installs dependencies required for the website, checks out the latest openstreetmap-website code from github and sets up config files.

### Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.web.example](./../../.env.web.example)
- [.env.db.example](./../../.env.db.example)

**Note**: Rename the above files as `.env.web` and `.env.db`

### Running web container

```sh
    # Docker compose
    docker-compose run web

    # Docker
    docker run \
    --env-file ./../../.env.web \
    --env-file ./../../.env.db \
    --network osm-seed_default \
    -p "80:80" \
    -h localhost \
    -t osmseed-web:v1
```
