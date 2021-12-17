# Docker setup for Tasking Manager 4 API

### Configuration
1. Copy `./envs/.env.tasking-manager.example` to `./envs/.env.tasking-manager`
2. This setup doesn't come with a database container, so you'd have to standup your own. For now.
3. Supply appropirate environment variables, particularly OAuth keys and database credentials


### Build and run
* `cd tasking-manager-api`
* `docker build -t osmseed-tasking-manager-api:v1 .`
* `docker run --env-file ../.env-tasking-manager -p "5000:5000" -t osmseed-tasking-manager-api:v1`

