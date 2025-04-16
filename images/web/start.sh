#!/usr/bin/env bash
workdir="/var/www"
export RAILS_ENV=production

setup_env_vars() {
  #### Setting up the production database
  cat <<EOF > "$workdir/config/database.yml"
production:
  adapter: postgresql
  host: ${POSTGRES_HOST}
  database: ${POSTGRES_DB}
  username: ${POSTGRES_USER}
  password: ${POSTGRES_PASSWORD}
  encoding: utf8
EOF

  ##### Setting up S3 storage
  if [ "$RAILS_STORAGE_SERVICE" == "s3" ]; then
    [[ -z "$RAILS_STORAGE_REGION" || -z "$RAILS_STORAGE_BUCKET" ]] && {
      echo "Error: RAILS_STORAGE_REGION or RAILS_STORAGE_BUCKET not set."
      exit 1
    }

    cat <<EOF >> "$workdir/config/storage.yml"
s3:
  service: S3
  region: '$RAILS_STORAGE_REGION'
  bucket: '$RAILS_STORAGE_BUCKET'
EOF
    echo "S3 storage configuration set successfully."
  fi

  #### Initializing an empty $workdir/config/settings.local.yml file, typically used for development settings
  echo "" > $workdir/config/settings.local.yml

  #### Setting up server_url and server_protocol
  sed -i -e 's/^server_protocol: ".*"/server_protocol: "'$SERVER_PROTOCOL'"/g' $workdir/config/settings.yml
  sed -i -e 's/^server_url: ".*"/server_url: "'$SERVER_URL'"/g' $workdir/config/settings.yml

  ### Setting up website status
  sed -i -e 's/^status: ".*"/status: "'$WEBSITE_STATUS'"/g' $workdir/config/settings.yml

  #### Setting up mail sender
  sed -i -e 's/smtp_address: ".*"/smtp_address: "'$MAILER_ADDRESS'"/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_port: .*/smtp_port: '$MAILER_PORT'/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_domain: ".*"/smtp_domain: "'$MAILER_DOMAIN'"/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_authentication: .*/smtp_authentication: "login"/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_user_name: .*/smtp_user_name: "'$MAILER_USERNAME'"/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_password: .*/smtp_password: "'$MAILER_PASSWORD'"/g' $workdir/config/settings.yml

  ### Setting up oauth id and key for iD editor
  sed -i -e 's/^oauth_application: ".*"/oauth_application: "'$OAUTH_CLIENT_ID'"/g' $workdir/config/settings.yml
  sed -i -e 's/^oauth_key: ".*"/oauth_key: "'$OAUTH_KEY'"/g' $workdir/config/settings.yml

  #### Setting up id key for the website
  sed -i -e 's/^id_application: ".*"/id_application: "'$OPENSTREETMAP_id_key'"/g' $workdir/config/settings.yml

  #### Setup env vars for memcached server
  sed -i -e 's/memcache_servers: \[\]/memcache_servers: "'$OPENSTREETMAP_memcache_servers'"/g' $workdir/config/settings.yml

  #### Setting up nominatim url
  sed -i -e 's/nominatim-api.openstreetmap.org/'$NOMINATIM_URL'/g' $workdir/config/settings.yml

  ## Setting up overpass url
  sed -i -e 's/overpass-api.openstreetmap.org/'$OVERPASS_URL'/g' $workdir/config/settings.yml
  sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/views/site/export.html.erb
  sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/assets/javascripts/index/export.js

  ## Setting up required credentials 
  echo $RAILS_CREDENTIALS_YML_ENC > config/credentials.yml.enc
  echo $RAILS_MASTER_KEY > config/master.key 
  chmod 600 config/credentials.yml.enc config/master.key

  #### Adding doorkeeper_signing_key
  openssl genpkey -algorithm RSA -out private.pem
  chmod 400 /var/www/private.pem
  export DOORKEEPER_SIGNING_KEY=$(cat /var/www/private.pem | sed -e '1d;$d' | tr -d '\n')
  sed -i "s#PRIVATE_KEY#${DOORKEEPER_SIGNING_KEY}#" $workdir/config/settings.yml
}

restore_db() {
  export PGPASSWORD="$POSTGRES_PASSWORD"
  curl -s -o backup.sql "$BACKUP_FILE_URL" || {
    echo "Error: Failed to download backup file."
    exit 1
  }

  psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f backup.sql && \
    echo "Database restored successfully." || \
    { echo "Database restore failed."; exit 1; }
}

start_background_jobs() {
  while true; do
    pkill -f "rake jobs:work"
    bundle exec rake jobs:work --trace >> "$workdir/log/jobs_work.log" 2>&1 &
    echo "Restarted rake jobs at $(date)"
    sleep 1h
  done
}

setup_production() {
  setup_env_vars

  echo "Waiting for PostgreSQL to be ready..."
  until pg_isready -h "$POSTGRES_HOST" -p 5432; do
    sleep 2
  done

  # echo "Running asset precompilation..."
  # time bundle exec rake i18n:js:export assets:precompile

  echo "Copying static assets..."
  cp "$workdir/public/leaflet-ohm-timeslider-v2/assets/"* "$workdir/public/assets/"

  echo "Running database migrations..."
  time bundle exec rails db:migrate

  if [ "$EXTERNAL_CGIMAP" == "false" ]; then
    echo "Running cgimap..."
    ./cgimap.sh
  fi

  echo "Starting Apache server..."
  apachectl -k start -DFOREGROUND &
  start_background_jobs
}


setup_development() {
  restore_db
  cp "$workdir/config/example.storage.yml" "$workdir/config/storage.yml"
  cp /tmp/settings.yml "$workdir/config/settings.yml"
  setup_env_vars
  bundle exec bin/yarn install
  bundle exec rails db:migrate --trace
  bundle exec rake jobs:work &
  rails server --log-to-stdout
}

####################### Setting up Development or Production mode #######################
if [ "$ENVIRONMENT" = "development" ]; then
  setup_development
else
  setup_production
fi
