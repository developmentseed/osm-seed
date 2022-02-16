# Docker setup for openstreetmap-website

The docker container installs dependencies required for the website, checks out the latest openstreetmap-website code from github and sets up config files.

# Configuration

In order to run this container we need environment variables, these can be found in the following files👇:

- [.env.web.example](./../../.env.web.example)
- [.env.db.example](./../../.env.db.example)

**Note**: 
- Rename the above files as `.env.web` and `.env.db`

### Email configuration

For sending email it is necessary to set the required variables, osm-seed has been tested with gmail and SES-AWS providers - SMTP.
- Gmail
    - Use or create an existing email account.
    - Make sure "IMAP Access" and "Allow less secure apps" are enabled in your account.

- SES AWS 
    - You have to create verified email or domain in you AWs acount.
    - Create an SMTP user, it will give you a user and password.
    - You have to activate SES for production, otherwise you can only send email to verified emails.

Find examples oh how to setup the configuration for each provider at [.env.web.example](./../../.env.web.example)

# Running web container

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