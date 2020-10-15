### Setting up and installing osm-seed

There are two ways of running `osm-seed` - either using `docker-compose` on a single machine to run all the docker container definitions, or using the included `Helm` chart to deploy onto a Kubernetes cluster.

This document describes working with `docker-compose` locally, most useful when working on adding or developing individual docker containers. For instructions on using the `Helm` chart to deploy to Kubernetes, refer to the [README](osm-seed/README.md) inside the `osm-seed/` subfolder.

### Requirements

You will need `docker` and `docker-compose` installed on your system.

  - Installing `docker`: https://docs.docker.com/install/
  - Installing `docker-compose`: https://docs.docker.com/compose/install/

### Run locally

Copy `.env.example` to `.env` and edit as appropriate. 

Run `docker-compose build` to build all Dockerfiles defined in `docker-compose.yml`.

Run `source .env && docker-compose up` to run all containers defined in `docker-compose`

Once `docker-compose` is running, you should be able to access a local instance of the OpenStreetMap website on `http://localhost:80`

NOTE: 
 
 - The map-tiles on the instance are being served from the main osm.org website currently. 
 - Make sure the port 5432 and 80 are not busy.

### Building and Running individual containers

Sometime you may require building and running a container by itself, so to do that and to put the container on the same network as other containers it maybe dependent on, first you should create a network.

e.g

```
docker network create osm_network

```

And then follow the README file in folders specific for each container definition, to configure, edit and test individual containers. 