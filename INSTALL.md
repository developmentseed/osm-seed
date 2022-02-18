### Setting up and installing osm-seed

There are two ways of running `osm-seed` - either using `docker-compose` on a single machine to run all the docker container definitions, or using the included `Helm` chart to deploy onto a Kubernetes cluster.

This document describes working with `docker-compose` locally, most useful when working on adding or developing individual docker containers. For instructions on using the `Helm` chart to deploy to Kubernetes, refer to the [README](osm-seed/README.md) inside the `osm-seed/` subfolder.

### Requirements

You will need `docker` and `docker-compose` installed on your system.

  - Installing `docker`: https://docs.docker.com/install/
  - Installing `docker-compose`: https://docs.docker.com/compose/install/

### Run locally

OSM Seed contains different containers, you may need to comment out some of them at docker-compose.yml according to your use case.
Copy the required environment files  from `envs/` folder, e.g `envs/.env.db.example` to `.env.db` and edit as appropriate.

Run `docker-compose build` to build all Dockerfiles defined in `docker-compose.yml`.

Run `docker-compose up` to run all containers defined in `docker-compose.yml`

Once `docker-compose` is running, you should be able to access a local instance of services:

   - OpenStreetMap website on `http://localhost:80`
   - Api DB on port 5432
   - Tiler DB on port 5433
   - Vector tile server on `http://localhost:9090`
   - Nominatim DB on port 5434
   - Nominatim API on  `http://localhost:7070`
   - Overpass API on `http://localhost:8081`
   - Tasking Manager API on `http://localhost:5050`
   - Taginfo API website on `http://localhost:4567`

NOTE: 
 
 - The map-tiles on the instance are being served from the main osm.org website currently. 
 - Make sure the port 5432 and 80 are not busy.
 - Data outputs from osm-seed is going to be store i the `data/` folder.


### Building and Running individual containers

Sometime you may require building and running a container by itself, so to do that and to put the container on the same network as other containers, take a looks on the folder [`images`](images/) of each contianer.

### Run in Kubernetes Cluster

For running in kubernetes use helm templates, https://devseed.com/osm-seed-chart/