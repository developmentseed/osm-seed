### Setting up and installing osm-seed

There are two ways of running `osm-seed` - either using `docker-compose` on a single machine to run all the docker container definitions, or using the included `Helm` chart to deploy onto a Kubernetes cluster.

This document describes working with `docker-compose` locally, most useful when working on adding or developing individual docker containers. For instructions on using the `Helm` chart to deploy to Kubernetes, refer to the [README](osm-seed/README.md) inside the `osm-seed/` subfolder.

### Requirements

You will need `docker` and `docker-compose` installed on your system.

  - Installing `docker`: https://docs.docker.com/install/
  - Installing `docker-compose`: https://docs.docker.com/compose/install/

### Run locally

OSM Seed contains different containers, these are split into multiple docker compose files in `compose/`. The `web.yml` is the default with a API database and openstreetmap-website container. Make sure the required environment files are created. Example envs are in `envs/`. To create an env copy `envs/.env.db.example` to `.env.db` and edit as appropriate.


You can use any container required by extending the `docker compose up` command like this:
* To run just the website `docker compose -f compose/web.yml up`
* To run website and import some data to the DB `docker compose  -f compose/web.yml -f compose/populate-apidb.yml up`

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