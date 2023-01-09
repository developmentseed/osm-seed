#!/bin/bash -e
CONFIG_FILE=${PROJECT_DIR}/.env

if [[ ! -z "$NOMINATIM_ADDRESS_LEVEL_CONFIG_URL" ]]; then
    curl -o /app/address-levels.json "${NOMINATIM_ADDRESS_LEVEL_CONFIG_URL}"
    echo NOMINATIM_ADDRESS_LEVEL_CONFIG=/app/address-levels.json >> ${CONFIG_FILE}
fi

if [[ ! -z "$OSMSEED_WEB_API_DOMAIN" ]]; then
    find /usr/local/lib/nominatim/lib-python/nominatim/ -type f | xargs perl -pi -e "s/www.openstreetmap.org/${OSMSEED_WEB_API_DOMAIN}/g"
fi

/app/start.sh

# Because of crashing updates, we are going to run updates every 10 minutes with catch-up action
watch -n 600 sudo -u nominatim nominatim replication --project-dir ${PROJECT_DIR} --catch-up >> /var/log/replication.log
