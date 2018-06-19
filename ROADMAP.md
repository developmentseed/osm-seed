# Project Roadmap

The initial release of `v0.1.0` provides the bare minimum needed to run the OpenStreetMap API, connect JOSM to it to edit data, and uses `osmium` to generate regular dumps of the data as `pbf` files.

In the future, this would ideally be a fully customizable version of the OSM website, and include related OSM tools like the HOT Tasking Manager, iD, OSMCha, etc.

### Short term goals

 - Harden stability, automated logging, and monitoring of the Helm chart setup + follow Kubernetes best practices.
 - Add test coverage for the Helm chart.
 - Improve customizability of the OSM website and setup tile-serving infrastructure.

### Long term goals

To be world-class open source, easily installable geospatial data management software, leveraging the OpenStreetMap software stack. This project also explicitly aims to NOT fork OpenStreetMap, but use the OpenStreetMap code-base as-is, and aims to contribute additions and improvements upstream. It shall serve as the "package management" layer, allowing one to easily install and manage OSM and related software, through a single interface.