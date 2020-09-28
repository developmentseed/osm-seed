# Docker setup for Tasking Manager 4 Frontend

### Configuration
1. Copy `.env-tasking-manager.example` to `.env-tasking-manager`
2. Tasking Manager front-end needs envvars during buildtime, these have to specified using `ARG` in the Dockerfile


### Build and run
* `cd tasking-manager-frontend`
* `docker build -t osmseed-tasking-manager-frontend:v1 .`
* `docker run --env-file ../.env-tasking-manager -p "8000:80" -t osmseed-tasking-manager-frontend:v1`
* Go to http://localhost:8000