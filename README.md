_Work in Progress_

Repository to hold Dockerfiles for a containerized OSM.

### Requirements

You will need `docker` and `docker-compose` installed on your system.

  - Installing `docker`: https://docs.docker.com/install/
  - Installing `docker-compose`: https://docs.docker.com/compose/install/

### Run locally

Copy `.env.example` to `.env` and edit as appropriate. 

Run `docker-compose build` to build all Dockerfiles defined in `docker-compose.yml`.

Run `source .env && docker-compose up` to run all containers defined in `docker-compose`

Once `docker-compose` is running, you should be able to access a local instance of the OpenStreetMap website on `http://localhost:3000`

NOTE: The map-tiles on the instance are being served from the main osm.org website currently

### Development

See README notes in individual folders for details about individual components.



### Production

```
docker-compose -f docker-compose build.yml up

```