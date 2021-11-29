#!/bin/bash
export NOMINATIM_SETTINGS='/app/src/build/settings/local_api.php'

# Replace API URLs on files
sed -i -e "s/www.openstreetmap.org/$OSMSEED_WEB_API_DOMAIN/g" /app/src/lib/lib.php
sed -i -e "s/www.openstreetmap.org/$OSMSEED_WEB_API_DOMAIN/g" /app/src/utils/update.php
sed -i -e "s/overpass-api.de/$OSMSEED_OVERPASS_API_DOMAIN/g" /app/src/utils/update.php

# echo 'Setup the app'
# /app/src/build/utils/setup.php --setup-website

flag=true
while "$flag" = true; do
    pg_isready -h $PG_HOST -p $PG_PORT >/dev/null 2>&2 || continue
    flag=false
    /usr/sbin/apache2ctl -D FOREGROUND &&
        tail -f /var/log/apache2/error.log
done
