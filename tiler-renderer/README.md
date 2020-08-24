# Tiler Renderer

This container contains the osm rendering components and includes the following: Mapnik, mod_tile, renderd, openstreetmap-carto and Apache.
Based on the official tutorial of [manually building a tile server on ubuntu 18.04.](https://switch2osm.org/serving-tiles/manually-building-a-tile-server-18-04-lts/)

**mod_tile** is an **Apache** module that enhances the regular Apache file serving mechanisms to provide smart functionality for serving, rendering and expiring tiles efficiently. Source code can be found [here.](https://github.com/openstreetmap/mod_tile)

The rendering is implemented in a process called **renderd** which listens for requests from mod_tile to render tiles and renders them to the file system. It is also responsible for managing queueing requests.

renderd uses a software library who does the actual rendering called **Mapnik** to render tiles using the rendering rules defined in the configuration file.

After rendering a tile, it gets cached on disk for fast serving using mod_tile. As OSM data is constantly updated, improved and changed, a mechanism is needed to correctly expire the cache to ensure updated tiles get re-rendered.
Tiles will cached on the `/var/lib/mod_tile` directory by default.
Apache serves the files as if they were present under `/[MOD_TILE_HOST]:[MOD_TILE_PORT]/[MOD_TILE_PATH]/Z/X/Y.png`
mod_tile is able to hold multiple mapnik style sheets. At the moment only the **openstreetmap-carto** stylesheet configuration is being used. with every import or update of tiles using the `osm2pgsql` tool style and database tag scheme needs to be specified.

For tiles to reflect the last update they need to be deleted or tagged as expired to force their being rerendered.
Expired tiles are being re-rendered in a loop every configured interval (`RENDER_EXPIRED_TILES_INTERVAL`).
Every replication (osmChange file) created by the `replication-job` container will be processed by `osm2pgsql` which in turn will send the expired tiles list to `/mnt/expired/` directory. The expired tiles will be rendered by mod_tile.
The sequence number of last rendered replication will be stated in `/mnt/expired/state.txt` as `lastRendered` key.

### Configuration

**Env Variables**

- `RENDER_EXPIRED_TILES_INTERVAL` the interval in seconds for mod_tile to expire tiles and rerender them.
- `MOD_TILE_HOST` e.g `localhost`
- `MOD_TILE_PORT` e.g `1337`
- `MOD_TILE_PATH` e.g `hot`
- `REPLICATION_DIR` the inner directory path for mounted replications
- `EXPIRED_DIR` the inner directory path for the expired lists

**Files**

- mod_tile.conf: specifying the loading of mod_tile module to apache. placed in /etc/apache2/conf-available/mod_tile.conf
- renderd.conf: indicates the mapnik style sheets, each sheet has its own settings including the uri to access it. placed in /usr/local/etc/renderd.conf
- apache2.conf: loading the renderd.conf onto the apache and setting additional behavior of apache. placed in /etc/apache2/sites-available/000-default.conf.
