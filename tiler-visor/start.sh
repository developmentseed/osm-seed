#!/usr/bin/env bash
set -e
tiler_visor_url=$TILER_VISOR_PROTOCOL://$TILER_VISOR_HOST:$TILER_VISOR_PORT

sed -i -e 's/localhost:9090/'$TILER_SERVER_HOST:$TILER_SERVER_PORT'/g' /usr/share/nginx/html/capabilities/osm.json
sed -i -e 's/demo.tegola.io/'$TILER_SERVER_HOST:$TILER_VISOR_PORT'/g' /usr/share/nginx/html/neConfig.json
sed -i -e 's,http://osm.tegola.io,'${tiler_visor_url}',g' /usr/share/nginx/html/config.json
sed -i -e 's,https://osm-lambda.tegola.io/v1,'${tiler_visor_url}',g' /usr/share/nginx/html/config.json
nginx -g 'daemon off;'