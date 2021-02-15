#!/bin/bash

mv /app/src/build/settings/local_db.php /app/src/build/settings/local.php

echo "Connecting... to postgresql://$PG_USER:$PG_PASSWORD@$PG_HOST/$PG_DATABASE"
flag=true
while "$flag" = true; do
    pg_isready -h $PG_HOST -p $PG_PORT >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    /usr/sbin/apache2ctl -D FOREGROUND &&
        tail -f /var/log/apache2/error.log
done
