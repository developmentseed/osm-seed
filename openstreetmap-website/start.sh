#!/usr/bin/env bash
workdir="/var/www"
# Because we can not set up many env variable sin build process, we are going to process here!
# Setting up the production database
echo " # Production DB 
production:
  adapter: postgresql
  host: ${POSTGRES_HOST}
  database: ${POSTGRES_DB}
  username: ${POSTGRES_USER}
  password: ${POSTGRES_PASSWORD}
  encoding: utf8" > $workdir/config/database.yml

# Setting up the SERVER_URL and SERVER_PROTOCOL to send the email with the right url host
sed -i -e 's/server_url: "localhost"/server_url: "'$SERVER_URL'"/g' $workdir/config/application.yml
sed -i -e 's/server_protocol: "http"/server_protocol: "'$SERVER_PROTOCOL'"/g' $workdir/config/application.yml

# Setting up the email
sed -i -e 's/osmseed-test@developmentseed.org/'$MAILER_USERNAME'/g' $workdir/config/application.yml

# Precompile again, to catch the env variables
RAILS_ENV=production rake assets:precompile

# db:migrate 
bundle exec rails db:migrate

# Start the app
apachectl -k start -DFOREGROUND