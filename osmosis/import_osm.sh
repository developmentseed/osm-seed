#!/usr/bin/env bash

aws s3 cp $S3_OSM_PATH tmp_import_file.pbf
osmosis --read-pbf file=tmp_import_file.pbf --write-apidb host="db" database="openstreetmap" user="postgres" validateSchemaVersion=no
