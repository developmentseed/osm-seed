# OSM SEED

Repository to hold Dockerfiles for a containerized OSM.

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


# Building and Running the containers by themself in a network

Sometime you may require building the container by itself, so to do that and to put the container on the same network, first you should create a network.

e.g

```
docker network create osm_network

```

And then follow the README file in each container folder. 