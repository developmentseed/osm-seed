#!/bin/bash
# Replace API URLs on files
sed -i -e "s/www.openstreetmap.org/$OSMSEED_WEB_API_DOMAIN/g" /app/src/lib/lib.php
sed -i -e "s/www.openstreetmap.org/$OSMSEED_WEB_API_DOMAIN/g" /app/src/utils/update.php
sed -i -e "s/overpass-api.de/$OSMSEED_OVERPASS_API_DOMAIN/g" /app/src/utils/update.php
