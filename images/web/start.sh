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

#### SET UP ID KEY
sed -i -e 's/#id_key: ""/id_key: "'$OSM_id_key'"/g' $workdir/config/settings.yml

## SET NOMINATIM URL
sed -i -e 's/nominatim.openstreetmap.org/'$NOMINATIM_URL'/g' $workdir/config/settings.yml

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

  # bundle exec rake assets:precompile --trace
  bundle exec rails db:migrate
  # Start the delayed jobs queue worker and  Start the app
  bundle exec rake jobs:work &
  apachectl -k start -DFOREGROUND
done
