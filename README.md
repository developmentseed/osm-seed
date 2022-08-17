# OSM SEED

osm-seed aims to provide an easily installable package for the OpenStreetMap software stack.

## Why?

OpenStreetMap runs open source software to manage geospatial data for the entire planet. It has given birth to an entire ecosystem of tools to edit, export and process spatial data.

Very often, one wants to manage geospatial datasets that cannot be added to the main OpenStreetMap project, either due to license restrictions, or because the data doesn't fit within the ambit of the OpenStreetMap project. However, it is still convenient and desirable to use the OpenStreetMap software backend, along with tools like JOSM to edit data, and `osmium` to export and process data.

The OpenStreetMap software stack has proven itself on a planetary scale, and has thousands of man hours of work behind it. This project aims to leverage this power, by making it simple to install and manage your own instance of the OpenStreetMap software.

## How?

This project provides docker container definitions for various aspects of the OpenStreetMap software stack, along with configuration scripts to run on a Kubernetes cluster.

### What's included now:

 - [`web`](images/web) A container that runs The OpenStreetMap Rails Port - https://wiki.openstreetmap.org/wiki/Main_Page.
 - [`db`](images/db) A container that runs OSM Api database.
 - [`populate-apidb`](images/populate-apidb) A container that runs `osmium` to import data into the api-db.
 - [`planet-dump`](images/planet-dump) A container that exports a planet replication in pbf format.
 - [`full-history`](images/full-history) A container that exports a full planet replication in pbf format.
 - [`replication-job`](images/replication-job)  A container that exports data from the api-db every minute, hour or day.
 - [`db-backup-restore`](images/backup-restore) A container that runs database backup.

 - [`tiler-db`](images/tiler-db) A container that runs tiler database.
 - [`tiler-imposm`](images/tiler-imposm) A container that runs updates from minute replication job.
 - [`tiler-server`](images/tiler-server) A container that runs vector tile server base on tegola - https://github.com/go-spatial/tegola

 - [`nominatim`](images/nominatim) A container that runs geocoder using data from `planet-dump` and `replication-job`
 - [`overpass-api`](images/overpass-api) A container that runs read-only API for filtering  map data - https://wiki.openstreetmap.org/wiki/Overpass_API
 - [`taginfo`](images/taginfo) A container that runs a service for finding and aggregating information about osm-seed tags - https://wiki.openstreetmap.org/wiki/Taginfo
 - [`tasking-manager-api`](images/tasking-manager-api) A container that runs Task manager rest api - https://github.com/pgmorgan/task-manager-api

 - A `Helm` [chart](https://www.helm.sh/), simplifying the process of deploying the entire system onto a Kubernetes cluster.

### Usage
For more details on installation, see [INSTALL.md](INSTALL.md).

### Using OSM data
If you plan to use data from the main OpenStreetMap project in your OSM Seed instance, then please make sure you're familiar with [the ODbL license](https://wiki.osmfoundation.org/wiki/Licence).

## What's next?

Eventually, the goal is to include more tools from the OSM ecosystem part of this stack, and continue to try and make the process as simple and reproducible as possible. Take a look at our [roadmap](https://github.com/developmentseed/osm-seed/blob/master/ROADMAP.md), and help out if this project helps what you're trying to do! We are always interested in collaborations and contributions! If you are interested in contributing, please see the [Contributor Guidelines](CONTRIBUTING.md).
