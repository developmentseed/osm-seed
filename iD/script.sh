#!/usr/bin/env bash

# We need to set up the env variables
node generate_osm.js > modules/services/osm.js
npm run all
npm run clean
npm run dist
npm start

