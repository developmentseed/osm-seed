#!/bin/bash
mv /app/src/build/settings/local_db.php /app/src/build/settings/local.php
export NOMINATIM_SETTINGS='/app/src/build/settings/local.php'

/usr/sbin/apache2ctl -D FOREGROUND
tail -f /var/log/apache2/error.log

