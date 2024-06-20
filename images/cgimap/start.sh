#!/usr/bin/env bash
export CGIMAP_HOST=$POSTGRES_HOST
export CGIMAP_DBNAME=$POSTGRES_DB
export CGIMAP_USERNAME=$POSTGRES_USER
export CGIMAP_PASSWORD=$POSTGRES_PASSWORD
export CGIMAP_OAUTH_HOST=$POSTGRES_HOST
export CGIMAP_UPDATE_HOST=$POSTGRES_HOST
export CGIMAP_LOGFILE="/var/www/log/cgimap.log"
export CGIMAP_MEMCACHE=$OPENSTREETMAP_memcache_servers
export CGIMAP_RATELIMIT="204800"
export CGIMAP_MAXDEBT="250"
export CGIMAP_MAP_AREA="0.25"
export CGIMAP_MAP_NODES="100000"
export CGIMAP_MAX_WAY_NODES="2000"
export CGIMAP_MAX_RELATION_MEMBERS="32000"
# export CGIMAP_RATELIMIT_UPLOAD="true"
# export CGIMAP_MODERATOR_RATELIMIT="1048576"
# export CGIMAP_MODERATOR_MAXDEBT="1280"
# export CGIMAP_PIDFILE="/var/www/cgimap.pid"

# Check for web site status
if [[ "$WEBSITE_STATUS" == "database_readonly" || "$WEBSITE_STATUS" == "api_readonly" ]]; then
  export CGIMAP_DISABLE_API_WRITE="true"
fi
if [[ "$WEBSITE_STATUS" == "database_offline" || "$WEBSITE_STATUS" == "api_offline" ]]; then
    echo "Website is $WEBSITE_STATUS. No action required for cgimap service."
else
  /usr/local/bin/openstreetmap-cgimap --port=8000 --daemon --instances=10 && \
    tail --pid=$(cat /tmp/cgimap.pid) -f /dev/null
fi
