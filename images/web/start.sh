#!/usr/bin/env bash
workdir="/var/www"
export RAILS_ENV=production

#### SETTING UP THE PRODUCTION DATABASE
echo " # Production DB
production:
  adapter: postgresql
  host: ${POSTGRES_HOST}
  database: ${POSTGRES_DB}
  username: ${POSTGRES_USER}
  password: ${POSTGRES_PASSWORD}
  encoding: utf8" >$workdir/config/database.yml

#### SETTING UP SERVER_URL AND SERVER_PROTOCOL
sed -i -e 's/server_url: "openstreetmap.example.com"/server_url: "'$SERVER_URL'"/g' $workdir/config/settings.yml
sed -i -e 's/server_protocol: "http"/server_protocol: "'$SERVER_PROTOCOL'"/g' $workdir/config/settings.yml

#### SETTING UP MAIL SENDER
sed -i -e 's/smtp_address: "localhost"/smtp_address: "'$MAILER_ADDRESS'"/g' $workdir/config/settings.yml
sed -i -e 's/smtp_domain: "localhost"/smtp_domain: "'$MAILER_DOMAIN'"/g' $workdir/config/settings.yml
sed -i -e 's/smtp_enable_starttls_auto: false/smtp_enable_starttls_auto: true/g' $workdir/config/settings.yml
sed -i -e 's/smtp_authentication: null/smtp_authentication: "login"/g' $workdir/config/settings.yml
sed -i -e 's/smtp_user_name: null/smtp_user_name: "'$MAILER_USERNAME'"/g' $workdir/config/settings.yml
sed -i -e 's/smtp_password: null/smtp_password: "'$MAILER_PASSWORD'"/g' $workdir/config/settings.yml
sed -i -e 's/openstreetmap@example.com/'$MAILER_FROM'/g' $workdir/config/settings.yml
sed -i -e 's/smtp_port: 25/smtp_port: '$MAILER_PORT'/g' $workdir/config/settings.yml

### SETTING UP UP OAUTH-2 ID KEY FOR iD
sed -i -e 's/id_application: ""/id_application: "'$OPENSTREETMAP_id_key'"/g' $workdir/config/settings.yml

### SETTING UP OAUTH-2 ID KEY WEBSITE
sed -i -e 's/OAUTH_CLIENT_ID/'$OAUTH_CLIENT_ID'/g' $workdir/config/settings.yml
sed -i -e 's/OAUTH_KEY/'$OAUTH_KEY'/g' $workdir/config/settings.yml

#### SETTING UP ENV VARS FOR MEMCACHED SERVER
sed -i -e 's/#memcache_servers: \[\]/memcache_servers: "'$OPENSTREETMAP_memcache_servers'"/g' $workdir/config/settings.yml

### SETTING UP NOMINATIM URL
sed -i -e 's/nominatim.openstreetmap.org/'$NOMINATIM_URL'/g' $workdir/config/settings.yml

#### SETTING UP OVERPASS URL
sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/config/settings.yml
sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/views/site/export.html.erb
sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/assets/javascripts/index/export.js

### SETTING UP ORGANIZATION
sed -i -e 's/OpenStreetMap/'$ORGANIZATION_NAME'/g' $workdir/config/settings.yml
ORGANIZATION_NAME_LOWER=$(echo "$ORGANIZATION_NAME" | tr '[:upper:]' '[:lower:]')
sed -i -e 's/openstreetmap/'"$ORGANIZATION_NAME_LOWER"'/g' "$workdir/config/settings.yml"

# ADDING DOORKEEPER_SIGNING_KEY
openssl genpkey -algorithm RSA -out private.pem -aes256
chmod 400 /var/www/private.pem
export DOORKEEPER_SIGNING_KEY=$(cat /var/www/private.pem | sed -e '1d;$d' | tr -d '\n')
sed -i "s#PRIVATE_KEY#${DOORKEEPER_SIGNING_KEY}#" $workdir/config/settings.yml


#### CHECK IF DB IS ALREADY UP AND START THE APP
flag=true
site_loading=true

while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false

  until $(curl -sf -o /dev/null $SERVER_URL); do
    if [ "$site_loading" = true ]; then
      echo "Waiting to start Rails ports server..."
      site_loading=false
    fi
    sleep 2
  done &
  # time rails i18n:js:export assets:precompile
  bundle exec rails db:migrate
  # /usr/local/bin/openstreetmap-cgimap \
  #   --port=8000 \
  #   --daemon \
  #   --instances=10 \
  #   --dbname=$POSTGRES_DB \
  #   --host=$POSTGRES_HOST \
  #   --username=$POSTGRES_USER \
  #   --password=$POSTGRES_PASSWORD \
    --logfile log/cgimap.log
  bundle exec rake jobs:work &
  apachectl -k start -DFOREGROUND
done
