#!/usr/bin/env bash
set -euo pipefail

WEBSITE_URL="${OSM_WEBSITE_URL:-https://www.openstreetmap.org}"
WEBSITE_URL="${WEBSITE_URL%/}/"
API_URL="${OSM_API_URL:-${WEBSITE_URL}api/0.6/}"
API_URL="${API_URL%/}/"

OSMAPI=/var/www/level0/www/osmapi.php

# Swap the hardcoded osm.org OAuth provider for the configurable one
if grep -qF 'JBelien\OAuth2\Client\Provider\OpenStreetMap(' "$OSMAPI"; then
  sed -i 's|new \\JBelien\\OAuth2\\Client\\Provider\\OpenStreetMap(|new \\ConfigurableOAuthProvider(|' "$OSMAPI"
fi

# Point the changeset link at the configured website
if grep -qF 'https://www.openstreetmap.org/changeset/' "$OSMAPI"; then
  sed -i "s|https://www.openstreetmap.org/changeset/|'.OSM_WEBSITE_URL.'changeset/|" "$OSMAPI"
fi

# Honor X-Forwarded-Proto so the OAuth redirect_uri is https behind a proxy
if ! grep -qF 'HTTP_X_FORWARDED_PROTO' "$OSMAPI"; then
  sed -i "s|\$_SERVER\['REQUEST_SCHEME'\]|(\$_SERVER['HTTP_X_FORWARDED_PROTO'] ?? \$_SERVER['REQUEST_SCHEME'])|" "$OSMAPI"
fi

# Whitelist an extra Overpass endpoint, if set
if [ -n "${OVERPASS_API:-}" ] && ! grep -qF "${OVERPASS_API}" "$OSMAPI"; then
  sed -i "s|'overpass.private.coffee/api'|'${OVERPASS_API}', 'overpass.private.coffee/api'|" "$OSMAPI"
fi

# Fix upstream typo in read_user(): row[0] -> $row[0]
sed -i 's|\$text = row\[0\];|\$text = \$row[0];|' /var/www/level0/www/core.php

grep -qF 'ConfigurableOAuthProvider(' "$OSMAPI"
grep -qF 'OSM_WEBSITE_URL' "$OSMAPI"

cat > /var/www/level0/www/config.php <<EOF
<?php

require_once __DIR__.'/oauth_provider.php';

const CLIENT_ID     = '${OAUTH2_CLIENT_ID:-}';
const CLIENT_SECRET = '${OAUTH2_CLIENT_SECRET:-}';

const OSM_WEBSITE_URL = '${WEBSITE_URL}';
const OSM_API_URL     = '${API_URL}';

const OSM_OAUTH2_AUTH_URL  = '${WEBSITE_URL}oauth2/authorize';
const OSM_OAUTH2_TOKEN_URL = '${WEBSITE_URL}oauth2/token';
const OSM_USER_DETAILS_URL = '${API_URL}user/details.json';

const BBOX_RADIUS = ${BBOX_RADIUS:-0.0003};
const MAX_REQUEST_OBJECTS = ${MAX_REQUEST_OBJECTS:-500};
const DATA_DIR = 'data';
const TEXT_DOMAIN = 'messages';
const SQLITE_DB = __DIR__.'/../level0.db';
const CONSOLE_DB = 'console.db';

const DEBUG = ${DEBUG:-false};
EOF

chown www-data:www-data /var/www/level0/www/config.php
mkdir -p /var/www/level0/www/data
chown -R www-data:www-data /var/www/level0/www/data

# Prune obsolete base files daily
(
  while true; do
    sleep 86400
    sqlite3 /var/www/level0/level0.db \
      "delete from base where created_at < datetime('now', '-1 day'); vacuum;" 2>/dev/null || true
  done
) &

exec apache2-foreground
