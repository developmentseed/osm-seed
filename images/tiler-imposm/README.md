# tiler-imposm

Imports a planet PBF into tiler-db with [imposm3](https://github.com/omniscale/imposm3) using the mapping in `config/`, then applies minute diffs and writes expired tiles for the cache. First run also loads OSM land and Natural Earth.

| | |
|---|---|
| Base image | `osgeo/gdal:ubuntu-small-3.2.3` |
| Chart values key | `tilerImposm` |
| Env files | `compose/envs/.env.tiler-db.example`, `compose/envs/.env.tiler-imposm.example` |

- Not in compose today; run it with the chart or `docker run`.
