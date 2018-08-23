#!/usr/bin/env bash
set -e
sed -i -e 's/demo.tegola.io/'$TILER_SERVER_HOST:$TILER_SERVER_PORT'/g' /usr/share/nginx/html/config.json
visor_server=http://$TILER_VISOR_HOST:$TILER_VISOR_PORT
sed -i -e 's,https://osm.tegola.io,'${visor_server}',g' /usr/share/nginx/html/config.json
nginx -g 'daemon off;'