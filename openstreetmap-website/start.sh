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

# Setting up the SERVER_URL and SERVER_PROTOCOL
sed -i -e 's/server_url: "localhost"/server_url: "'$SERVER_URL'"/g' $workdir/config/application.yml
sed -i -e 's/server_protocol: "http"/server_protocol: "'$SERVER_PROTOCOL'"/g' $workdir/config/application.yml

# Setting up the email
sed -i -e 's/osmseed-test@developmentseed.org/'$MAILER_FROM'/g' $workdir/config/application.yml

# Set up iD key
sed -i -e 's/id-key-to-be-replaced/'$OSM_id_key'/g' $workdir/config/application.yml



# Check if DB is already up

flag=true
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  # Print the log while compiling the assets
  until $(curl -sf -o /dev/null $SERVER_URL); do
      echo "Waiting to start rails ports server..."
      sleep 2
  done &

  # Precompile again, to catch the env variables
  # RAILS_ENV=production rake assets:precompile --trace

  # db:migrate
  bundle exec rails db:migrate

  # Start the delayed jobs queue worker
  # bundle exec rake jobs:work
  # Start the app
  apachectl -k start -DFOREGROUND
done


