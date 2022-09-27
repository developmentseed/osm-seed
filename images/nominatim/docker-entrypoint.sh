#!/bin/bash -e
CONFIG_FILE=${PROJECT_DIR}/.env

if [[ ! -z "$NOMINATIM_ADDRESS_LEVEL_CONFIG_URL" ]]; then
    curl -o /app/address-levels.json "${NOMINATIM_ADDRESS_LEVEL_CONFIG_URL}"
    echo NOMINATIM_ADDRESS_LEVEL_CONFIG=/app/address-levels.json >> ${CONFIG_FILE}
fi
/app/start.sh