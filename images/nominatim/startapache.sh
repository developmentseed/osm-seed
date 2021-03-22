#!/bin/bash
export NOMINATIM_SETTINGS='/app/src/build/settings/local.php'
echo 'Setup the app'
/app/src/build/utils/setup.php --setup-website

flag=true
while "$flag" = true; do
    pg_isready -h $PG_HOST -p $PG_PORT >/dev/null 2>&2 || continue
    flag=false
    /usr/sbin/apache2ctl -D FOREGROUND &&
        tail -f /var/log/apache2/error.log
done
