#!/bin/bash
set -e
if [[ -n "${CLEAN_CACHE_MANUALLY}" && "${CLEAN_CACHE_MANUALLY}" == "true" && "${TILER_CACHE_TYPE}" && "${TILER_CACHE_TYPE}" == "s3" ]]; then
    while true; do
        NUM_PS_TEGOLA=$(ps | grep ${CACHE_PROCESS_NAME} | grep -v grep | wc -l)
        if [[ $NUM_PS_TEGOLA -gt $MAX_PS_TEGOLA ]]; then
            aws s3 rm s3://${TILER_CACHE_BUCKET}/mnt/data/osm/ --recursive
            echo "${CACHE_PROCESS_NAME} processes"
            ps aux | grep ${CACHE_PROCESS_NAME} | grep -v grep
            # After clearing the S3 cache, terminate all 'tegola' processes.
            killall ${CACHE_PROCESS_NAME}
        fi
        sleep 600
    done
fi
