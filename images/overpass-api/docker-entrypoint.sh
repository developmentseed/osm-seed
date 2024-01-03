#!/bin/bash

set -eo pipefail
shopt -s nullglob
OVERPASS_META=${OVERPASS_META:-no}
OVERPASS_MODE=${OVERPASS_MODE:-clone}
OVERPASS_COMPRESSION=${OVERPASS_COMPRESSION:-gz}
OVERPASS_FLUSH_SIZE=${OVERPASS_FLUSH_SIZE:-16}
OVERPASS_CLONE_SOURCE=${OVERPASS_CLONE_SOURCE:-http://dev.overpass-api.de/api_drolbr/}

# this is used by other processes, so needs to be exported
export OVERPASS_MAX_TIMEOUT=${OVERPASS_MAX_TIMEOUT:-1000s}

if [[ "$OVERPASS_META" == "attic" ]] ; then
    META="--keep-attic"
elif [[ "${OVERPASS_META}" == "yes" ]] ; then
    META="--meta"
else
    META=""
fi

for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sh)
            if [[ -x "$f" ]]; then
                echo "$0: running $f"
                "$f"
            else
                echo "$0: sourcing $f"
                . "$f"
            fi
            ;;
        *)        echo "$0: ignoring $f" ;;
    esac
    echo
done

function startAPIServer(){
  envsubst '${OVERPASS_MAX_TIMEOUT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
  echo "Starting supervisord process"
  /app/bin/dispatcher --osm-base --db-dir=/db/db/ --${OVERPASS_META} &
  exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
}

if [[ ! -f /db/init_done ]] ; then
    echo "No database directory. Initializing"
    if [[ "${USE_OAUTH_COOKIE_CLIENT}" = "yes" ]]; then
      /app/venv/bin/python /app/bin/oauth_cookie_client.py -o /db/cookie.jar -s /secrets/oauth-settings.json --format netscape
      # necessary to add newline at the end as oauth_cookie_client doesn't do that
      echo >> /db/cookie.jar
    else
      echo "# Netscape HTTP Cookie File" > /db/cookie.jar
      echo "${OVERPASS_COOKIE_JAR_CONTENTS}" >> /db/cookie.jar
    fi
    chown overpass /db/cookie.jar

    if [[ "$OVERPASS_MODE" = "clone" ]]; then
        mkdir -p /db/db \
        && /app/bin/download_clone.sh --db-dir=/db/db --source="${OVERPASS_CLONE_SOURCE}" --meta="${OVERPASS_META}" \
        && cp /db/db/replicate_id /db/replicate_id \
        && cp -r /app/etc/rules /db/db \
        && chown -R overpass:overpass /db \
        && touch /db/init_done \
        && echo "Overpass ready, you can start your container with docker start"
        exit
    fi

    if [[ "$OVERPASS_MODE" = "init" ]]; then
        while true ; do
          CURL_STATUS_CODE=$(curl -L -b /db/cookie.jar -o /db/planet.osm.bz2 -w "%{http_code}" "${OVERPASS_PLANET_URL}")
          case "${CURL_STATUS_CODE}" in
            429)
              echo "Server responded with 429 Too many requests. Trying again in 5 minutes..."
              sleep 300
              continue
              ;;
            # for `file:///` scheme curl returns `000` HTTP status code
            200 | 000)
              (
                if [[ ! -z "${OVERPASS_PLANET_PREPROCESS+x}" ]]; then
                    echo "Running preprocessing command: ${OVERPASS_PLANET_PREPROCESS}"
                    eval "${OVERPASS_PLANET_PREPROCESS}"
                fi \
                && /app/bin/init_osm3s.sh /db/planet.osm.bz2 /db/db /app "${META}" "--version=$(osmium fileinfo -e -g data.timestamp.last /db/planet.osm.bz2) --compression-method=${OVERPASS_COMPRESSION} --map-compression-method=${OVERPASS_COMPRESSION} --flush-size=${OVERPASS_FLUSH_SIZE}" \
                && echo "Database created. Now updating it." \
                && cp -r /app/etc/rules /db/db \
                && chown -R overpass:overpass /db \
                && echo "Updating" \
                && /app/bin/update_overpass.sh "-O /db/planet.osm.bz2" \
                && /app/bin/osm3s_query --progress --rules --db-dir=/db/db < /db/db/rules/areas.osm3s \
                && touch /db/init_done \
                && rm /db/planet.osm.bz2 \
                && chown -R overpass:overpass /db \
                && echo $OVERPASS_REPLICATION_SEQUENCE_NUMBER > /db/replicate_id \
                && chmod 777 /db/replicate_id \
                && echo "Overpass ready, you can start your container with docker start" \
                && startAPIServer
              ) || (
                echo "Failed to process planet file"
                exit
              )
              ;;
            403)
              echo "Access denied when downloading planet file. Check your OVERPASS_PLANET_URL and OVERPASS_COOKIE_JAR_CONTENTS or USE_OAUTH_COOKIE_CLIENT"
              cat /db/cookie.jar
              exit
              ;;
            *)
              echo "Failed to download planet file. HTTP status code: ${CURL_STATUS_CODE}"
              cat /db/planet.osm.bz2
              exit
              ;;
          esac
          exit
        done
    fi
fi

# Start api server
startAPIServer