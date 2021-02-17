#!/bin/bash
cp /data/conf/local.php /app/src/build/settings/local.php
export NOMINATIM_SETTINGS='/app/src/build/settings/local.php'

/usr/sbin/apache2ctl -D FOREGROUND
tail -f /var/log/apache2/error.log

