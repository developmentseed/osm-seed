#!/bin/bash
export NOMINATIM_SETTINGS='/app/src/build/settings/local_update.php'

echo "Starting update process..."
flag=true
while "$flag" = true; do
    pg_isready -h localhost -p 5432 >/dev/null 2>&2 || continue
    flag=false
    sudo -u postgres /app/src/build/utils/update.php --init-updates &&
        sudo -u postgres /app/src/build/utils/update.php --import-osmosis-all
done
