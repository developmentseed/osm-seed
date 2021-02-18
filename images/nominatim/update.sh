#!/bin/bash
# Replace var in settings.php
sed -i -e  "s#https://planet.openstreetmap.org/replication/minute#${REPLICATION_URL}#g" /app/src/build/settings/settings.php
sed -i -e "s/30/${REPLICATION_MAXINTERVAL}/g" /app/src/build/settings/settings.php
sed -i -e "s/75/${REPLICATION_UPDATE_INTERVAL}/g" /app/src/build/settings/settings.php
sed -i -e "s/60/${REPLICATION_RECHECK_INTERVAL}/g" /app/src/build/settings/settings.php

echo "Starting update process..."
flag=true
while "$flag" = true; do
    pg_isready -h localhost -p 5432 >/dev/null 2>&2 || continue
    flag=false
    sudo -u postgres /app/src/build/utils/update.php --init-updates &&
        sudo -u postgres /app/src/build/utils/update.php --import-osmosis-all
done
