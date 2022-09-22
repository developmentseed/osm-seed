#!/bin/bash -e
if [[ ! -z "$NOMINATIM_ADDRESS_LEVEL_CONFIG_URL" ]]; then
    curl -o /app/address-levels.json "${NOMINATIM_ADDRESS_LEVEL_CONFIG_URL}"
    export NOMINATIM_ADDRESS_LEVEL_CONFIG=/app/address-levels.json
fi
/app/start.sh