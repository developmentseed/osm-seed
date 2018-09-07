## Clipping a PBF file

Sometimes you just want to import a portion of data in the database, here is a guide on how you can clip the data.

Examples: 

### Getting the data PBF data

Let's get data from http://download.geofabrik.de, in this case: [peru-latest.osm.pbf](http://download.geofabrik.de/south-america/peru-latest.osm.pbf)

### Converting the boundary geojson file into a poly file.

Install: `https://www.npmjs.com/package/geojson2poly`

```
npm istall -g geojson2poly
```

We will use: [`lima.geojson`](https://gist.githubusercontent.com/Rub21/cd45c71accb77cced411ba55a9d01a41/raw/0107de9b4461de2150c8779f2898edb2a5339980/lima.geojson) file.

```
geojson2poly lima.geojson lima.poly
```

### Clipping the PBF file

We will use [osmconvert](https://wiki.openstreetmap.org/wiki/Osmconvert#Keeping_Cross-Border_Boundaries_Complete) for this purpose, through a docker container.


```
docker run --rm -v ${PWD}:/app rub21/dosm osmconvert peru-latest.osm.pbf -B=lima.poly  -o=lima.pbf
```
Upload this file anywhere where has public access, so that it can be imported  by the populate-apidb container into the apidb.
