#!/usr/bin/env bash
set -e
sed -i -e 's/demo.tegola.io/'$TILER_SERVER_HOST:$TILER_SERVER_PORT'/g' /usr/share/nginx/html/config.json
sed -i -e 's/localhost:9090/'$TILER_SERVER_HOST:$TILER_SERVER_PORT'/g' /usr/share/nginx/html/capabilities/osm.json
sed -i -e 's,https://osm.tegola.io,'${http://$TILER_VISOR_HOST:$TILER_VISOR_PORT}',g' /usr/share/nginx/html/config.json
nginx -g 'daemon off;'