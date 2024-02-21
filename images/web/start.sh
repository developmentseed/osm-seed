#!/usr/bin/env bash
workdir="/var/www"
export RAILS_ENV=production
#### Because we can not set up many env variable in build process, we are going to process here!

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
sed -i -e 's/server_url: "openhistoricalmap.example.com"/server_url: "'$SERVER_URL'"/g' $workdir/config/settings.yml
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

#### SET UP ID KEY
sed -i -e 's/id_application: ""/id_application: "'$OPENSTREETMAP_id_key'"/g' $workdir/config/settings.yml

### SET UP OAUTH ID AND KEY
sed -i -e 's/OAUTH_CLIENT_ID/'$OAUTH_CLIENT_ID'/g' $workdir/config/settings.yml
sed -i -e 's/OAUTH_KEY/'$OAUTH_KEY'/g' $workdir/config/settings.yml

#### Setup env vars for memcached server
sed -i -e 's/#memcache_servers: \[\]/memcache_servers: "'$OPENSTREETMAP_memcache_servers'"/g' $workdir/config/settings.yml

## SET NOMINATIM URL
sed -i -e 's/nominatim.openhistoricalmap.org/'$NOMINATIM_URL'/g' $workdir/config/settings.yml

## SET OVERPASS URL
sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/config/settings.yml
sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/views/site/export.html.erb
sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/assets/javascripts/index/export.js

#### CHECK IF DB IS ALREADY UP AND START THE APP
flag=true
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  # Print the log while compiling the assets
  until $(curl -sf -o /dev/null $SERVER_URL); do
    echo "Waiting to start rails ports server..."
    sleep 2
  done &

  # Enable assets:precompile, to take lates changes for assets in $workdir/config/settings.yml.
  time bundle exec rake i18n:js:export assets:precompile

  bundle exec rails db:migrate

  # Start lighttpd and cgimap
  /usr/local/bin/openstreetmap-cgimap \
    --port=8000 \
    --daemon \
    --instances=10 \
    --dbname=$POSTGRES_DB \
    --host=$POSTGRES_HOST \
    --username=$POSTGRES_USER \
    --password=$POSTGRES_PASSWORD \
    --logfile log/cgimap.log
  # Start the delayed jobs queue worker and  Start the app
  bundle exec rake jobs:work &
  apachectl -k start -DFOREGROUND
done
