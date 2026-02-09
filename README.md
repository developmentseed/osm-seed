# OSM SEED

> An easily installable package for the OpenStreetMap software stack

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**osm-seed** provides a complete, production-ready deployment solution for running your own instance of the OpenStreetMap software stack. Whether you need to manage geospatial datasets that can't be added to the main OpenStreetMap project, or want to leverage the proven OSM infrastructure for your own use case, osm-seed makes it simple to install and manage.

## Table of Contents

- [Why osm-seed?](#why-osm-seed)
- [Features](#features)
- [Components](#components)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [License & Attribution](#license--attribution)
- [Contributing](#contributing)
- [Roadmap](#roadmap)

## Why osm-seed?

OpenStreetMap runs open source software to manage geospatial data for the entire planet. It has given birth to an entire ecosystem of tools to edit, export, and process spatial data.

Very often, one wants to manage geospatial datasets that cannot be added to the main OpenStreetMap project, either due to license restrictions, or because the data doesn't fit within the scope of the OpenStreetMap project. However, it is still convenient and desirable to use the OpenStreetMap software backend, along with tools like [JOSM](https://josm.openstreetmap.de/) to edit data, and [`osmium`](https://osmcode.org/osmium-tool/) to export and process data.

The OpenStreetMap software stack has proven itself on a planetary scale, with thousands of hours of development work behind it. This project aims to leverage this power by making it simple to install and manage your own instance of the OpenStreetMap software.

## Features

- 🐳 **Docker-based**: All components are containerized for easy deployment
- ☸️ **Kubernetes-ready**: Includes Helm charts for production deployments
- 🔄 **Complete stack**: From database to web interface, tiles to geocoding
- 📦 **Modular**: Run individual components or the full stack
- 🔧 **Configurable**: Extensive environment variable configuration
- 📊 **Production-tested**: Based on the same infrastructure that powers OpenStreetMap

## Components

This project provides Docker container definitions for various aspects of the OpenStreetMap software stack, along with configuration scripts to run on a Kubernetes cluster.

### Core OSM Components

| Component | Description | Link |
|-----------|-------------|------|
| [`web`](images/web) | OpenStreetMap Rails Port web interface | [OSM Wiki](https://wiki.openstreetmap.org/wiki/Main_Page) |
| [`db`](images/db) | PostgreSQL database for OSM API | - |
| [`populate-apidb`](images/populate-apidb) | Data import using `osmium` | - |
| [`planet-dump`](images/planet-dump) | Export planet replication in PBF format | - |
| [`full-history`](images/full-history) | Export full planet replication in PBF format | - |
| [`replication-job`](images/replication-job) | Export data from api-db (minute/hour/day) | - |
| [`db-backup-restore`](images/backup-restore) | Database backup and restore utilities | - |

### Tiling Infrastructure

| Component | Description | Link |
|-----------|-------------|------|
| [`tiler-db`](images/tiler-db) | PostgreSQL database for tile generation | - |
| [`tiler-imposm`](images/tiler-imposm) | Updates from minute replication job | - |
| [`tiler-server`](images/tiler-server) | Vector tile server based on Tegola | [Tegola](https://github.com/go-spatial/tegola) |

### Additional Services

| Component | Description | Link |
|-----------|-------------|------|
| [`nominatim`](images/nominatim) | Geocoding service using planet-dump and replication-job | [Nominatim](https://nominatim.org/) |
| [`overpass-api`](images/overpass-api) | Read-only API for filtering map data | [Overpass API](https://wiki.openstreetmap.org/wiki/Overpass_API) |
| [`taginfo`](images/taginfo) | Service for finding and aggregating OSM tag information | [Taginfo](https://wiki.openstreetmap.org/wiki/Taginfo) |
| [`tasking-manager-api`](images/tasking-manager-api) | Task manager REST API | [Task Manager](https://github.com/pgmorgan/task-manager-api) |

### Deployment

- **Helm Chart**: A complete [Helm chart](https://www.helm.sh/) simplifying the process of deploying the entire system onto a Kubernetes cluster. See the [chart documentation](osm-seed/README.md) for details.

## Quick Start

### Using Docker Compose (Local Development)

```bash
# Run just the website
docker compose -f compose/web.yml up

# Run website with data import
docker compose -f compose/web.yml -f compose/populate-apidb.yml up
```

### Using Helm (Kubernetes)

The recommended way to install osm-seed is to use the published Helm chart. See [INSTALL.md](INSTALL.md) for detailed instructions.

## Installation

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

### Requirements

- Docker and Docker Compose (for local development)
- Kubernetes cluster (for production deployment)
- Helm 3.x (for Kubernetes deployment)

### Using OSM Data

If you plan to use data from the main OpenStreetMap project in your OSM Seed instance, please make sure you're familiar with [the ODbL license](https://wiki.osmfoundation.org/wiki/Licence).

## License & Attribution

This project is licensed under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.

### Credits

**osm-seed** was originally created by [Development Seed](https://developmentseed.org/), a technology company that builds open source tools for mapping and geospatial data.

- **Original Repository**: [developmentseed/osm-seed](https://github.com/developmentseed/osm-seed)
- **Copyright**: Copyright (c) 2018 Development Seed

This project builds upon and extends the outstanding work done by the Development Seed team. We sincerely appreciate their lasting contributions to the open-source geospatial community.

### Current Maintainers

In January 2026, osm-seed transitioned to its own organization to provide greater flexibility and independence. The project is now maintained by:

- [@Rub21](https://github.com/Rub21)
- [@batpad](https://github.com/batpad)
- [@geohacker](https://github.com/geohacker)


We continue to build upon the foundation laid by Development Seed while steering the project toward new directions and improvements.

## Contributing

We welcome contributions! If you're interested in contributing, please see our [Contributor Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

We are always interested in collaborations and contributions. If this project helps what you're trying to do, we'd love to hear from you!

## Roadmap

Eventually, the goal is to include more tools from the OSM ecosystem as part of this stack, and continue to make the process as simple and reproducible as possible. Take a look at our [roadmap](ROADMAP.md) to see what's planned.

---

**Note**: This project explicitly aims to NOT fork OpenStreetMap, but to use the OpenStreetMap codebase as-is, and aims to contribute additions and improvements upstream. It serves as the "package management" layer, allowing one to easily install and manage OSM and related software through a single interface.
