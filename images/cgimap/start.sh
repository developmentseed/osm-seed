#!/usr/bin/env bash

export PGPASSWORD=$POSTGRES_PASSWORD
export CGIMAP_HOST=$POSTGRES_HOST
export CGIMAP_DBNAME=$POSTGRES_DB
export CGIMAP_USERNAME=$POSTGRES_USER
export CGIMAP_PASSWORD=$POSTGRES_PASSWORD
export CGIMAP_OAUTH_HOST=$POSTGRES_HOST
export CGIMAP_UPDATE_HOST=$POSTGRES_HOST
# Export CGIMAP configuration
export CGIMAP_LOGFILE="/var/www/log/cgimap.log"
export CGIMAP_MEMCACHE=$MEMCACHE_SERVER
# Average number of bytes/s to allow each client
export CGIMAP_RATELIMIT="204800"
# Maximum debt in MB to allow each client before rate limiting
export CGIMAP_MAXDEBT="2048"  
export CGIMAP_MAP_AREA="0.25"
export CGIMAP_MAP_NODES="100000"
export CGIMAP_MAX_WAY_NODES="2000"
export CGIMAP_MAX_RELATION_MEMBERS="32000"
# export CGIMAP_RATELIMIT_UPLOAD="true"
export CGIMAP_MODERATOR_RATELIMIT="1048576"
export CGIMAP_MODERATOR_MAXDEBT="2048"

if [[ "$WEBSITE_STATUS" == "database_readonly" || "$WEBSITE_STATUS" == "api_readonly" ]]; then
  export CGIMAP_DISABLE_API_WRITE="true"
fi

if [[ "$WEBSITE_STATUS" == "database_offline" || "$WEBSITE_STATUS" == "api_offline" ]]; then
  echo "Website is $WEBSITE_STATUS. No action required for cgimap service."
else
  # PostgreSQL options to disable certain joins
  export PGOPTIONS="-c enable_mergejoin=false -c enable_hashjoin=false"
  # Display current PostgreSQL settings
  psql -h $POSTGRES_HOST -U $POSTGRES_USER -c "SHOW enable_mergejoin;"
  psql -h $POSTGRES_HOST -U $POSTGRES_USER -c "SHOW enable_hashjoin;"
  # Start the cgimap service
  /usr/local/bin/openstreetmap-cgimap --port=8000 --daemon --instances=10
fi
