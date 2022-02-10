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
    --env-file ./envs/.env.web \
    --env-file ./envs/.env.db \
    --network osm-seed_default \
    -p "80:80" \
    -p "3000:3000" \
    -h localhost \
    -it osmseed-web:v1 bash
```