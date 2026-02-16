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

  #### Fix translation files: replace {مجتمع} with {community} to prevent KeyError
  # This fixes the KeyError when template has Arabic placeholder but hash only has :community
  find "$workdir/node_modules/osm-community-index/i18n" -name "*.yaml" -type f -exec sed -i 's/{مجتمع}/{community}/g' {} \;


  #### Initializing an empty $workdir/config/settings.local.yml file, typically used for development settings
  echo "" > $workdir/config/settings.local.yml

  #### Setting up server_url and server_protocol
  SERVER_URL_CLEAN=$(echo "$SERVER_URL" | sed 's|/$||')
  sed -i -e 's/^server_protocol: ".*"/server_protocol: "'$SERVER_PROTOCOL'"/g' $workdir/config/settings.yml
  sed -i -e 's/^server_url: ".*"/server_url: "'$SERVER_URL_CLEAN'"/g' $workdir/config/settings.yml
  if [ "$SERVER_PROTOCOL" == "http" ]; then
    sed -i -e 's/config.force_ssl = true/config.force_ssl = false/' $workdir/config/environments/production.rb
    sed -i -e 's/config.assume_ssl = true/config.assume_ssl = false/' $workdir/config/environments/production.rb
  fi

  #### Extract domain from SERVER_URL and replace in production.conf
  SERVER_DOMAIN=$(echo "$SERVER_URL_CLEAN" | sed -e 's|^[^/]*//||' -e 's|^www\.||' -e 's|/.*$||')
  sed -i -e "s/SERVER_DOMAIN_PLACEHOLDER/$SERVER_DOMAIN/g" /etc/apache2/sites-available/production.conf

  ### Setting up website status
  sed -i -e 's/^status: ".*"/status: "'$WEBSITE_STATUS'"/g' $workdir/config/settings.yml

  #### Setting up mail sender
  sed -i -e 's/smtp_address: ".*"/smtp_address: "'$MAILER_ADDRESS'"/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_port: .*/smtp_port: '$MAILER_PORT'/g' $workdir/config/settings.yml
  sed -i -e 's/smtp_domain: ".*"/smtp_domain: "'$MAILER_DOMAIN'"/g' $workdir/config/settings.yml

  if [ "$MAILER_AUTHENTICATION" == "" ]; then
    sed -i -e 's/smtp_authentication: .*/smtp_authentication: null/g' $workdir/config/settings.yml
    sed -i -e 's/smtp_user_name: .*/smtp_user_name: null/g' $workdir/config/settings.yml
    sed -i -e 's/smtp_password: .*/smtp_password: null/g' $workdir/config/settings.yml
  else
    sed -i -e 's/smtp_authentication: .*/smtp_authentication: "'$MAILER_AUTHENTICATION'"/g' $workdir/config/settings.yml
    sed -i -e 's/smtp_user_name: .*/smtp_user_name: "'$MAILER_USERNAME'"/g' $workdir/config/settings.yml
    sed -i -e 's/smtp_password: .*/smtp_password: "'$MAILER_PASSWORD'"/g' $workdir/config/settings.yml
  fi

  ### Setting up oauth id and key for iD editor
  sed -i -e 's/^oauth_application: ".*"/oauth_application: "'$OAUTH_CLIENT_ID'"/g' $workdir/config/settings.yml
  sed -i -e 's/^oauth_key: ".*"/oauth_key: "'$OAUTH_KEY'"/g' $workdir/config/settings.yml

  #### Setting up id key for the website
  sed -i -e 's/^id_application: ".*"/id_application: "'$OPENSTREETMAP_id_key'"/g' $workdir/config/settings.yml

  #### Setup env vars for memcached server
  sed -i -e 's/memcache_servers: \[\]/memcache_servers: "'$OPENSTREETMAP_memcache_servers'"/g' $workdir/config/settings.yml

  ## Setting up storage
  sed -i -e 's/avatar_storage: ".*"/avatar_storage: "'$OPENSTREETMAP_avatar_storage'"/g' $workdir/config/settings.yml
  sed -i -e 's/trace_file_storage: ".*"/trace_file_storage: "'$OPENSTREETMAP_trace_file_storage'"/g' $workdir/config/settings.yml
  sed -i -e 's/trace_image_storage: ".*"/trace_image_storage: "'$OPENSTREETMAP_trace_image_storage'"/g' $workdir/config/settings.yml
  sed -i -e 's/trace_icon_storage: ".*"/trace_icon_storage: "'$OPENSTREETMAP_trace_icon_storage'"/g' $workdir/config/settings.yml

  #### Setting up nominatim url
  sed -i -e 's/nominatim-api.openstreetmap.org/'$NOMINATIM_URL'/g' $workdir/config/settings.yml

  ## Setting up overpass url
  sed -i -e 's/overpass-api.openstreetmap.org/'$OVERPASS_URL'/g' $workdir/config/settings.yml
  sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/views/site/export.html.erb
  sed -i -e 's/overpass-api.de/'$OVERPASS_URL'/g' $workdir/app/assets/javascripts/index/export.js

  ## Setting up required credentials 
  if [ "$RAILS_MASTER_KEY" != "" ]; then
    echo $RAILS_CREDENTIALS_YML_ENC > config/credentials.yml.enc
    echo $RAILS_MASTER_KEY > config/master.key
  fi
  chmod 600 config/credentials.yml.enc config/master.key

  #### Adding doorkeeper_signing_key
  openssl genpkey -algorithm RSA -out private.pem
  chmod 400 /var/www/private.pem
  export DOORKEEPER_SIGNING_KEY=$(cat /var/www/private.pem | sed -e '1d;$d' | tr -d '\n')
  sed -i "s#PRIVATE_KEY#${DOORKEEPER_SIGNING_KEY}#" $workdir/config/settings.yml
}

setup_admin() {
  ### Create default admin and register default oauth apps
  if [ $ADMIN_MAIL != "" ] && [ ! -f $workdir/.admin_created ]; then
    echo "Creating user 'admin' ..."
    touch $workdir/.admin_created

    bundle exec rails runner "u = User.find_by(:display_name => 'admin'); \
        if (nil != u) then puts('User already exists'); exit(2) end;
        u = User.new(email:'$ADMIN_MAIL', display_name: 'admin'); \
        u.pass_crypt='$ADMIN_PASSWORD'; \
        u.pass_crypt_confirmation='$ADMIN_PASSWORD'; \
        u.save"'!'"; \
        u.activate"'!'"; \
        u.roles.create(:role => \"moderator\", :granter_id => u.id); \
        u.roles.create(:role => \"administrator\", :granter_id => u.id); \
        exit(0);"

    if [ $? -eq 0 ]; then # Success: 0
      echo "Creating user 'admin': Success!"
    else # Error: 1
      echo "Creating user 'admin': Failure!"
    fi

    bundle exec rails runner 'exit(nil == Oauth2Application.find_by(:name => "Local iD"))' # true converted to result code 0
    if [ $? -eq 0 ]; then
      echo "Registering default OAuth2 applications for user 'admin' ..."

      sed -i -e 's/^id_application:/#id_application:/' $workdir/config/settings.yml
      sed -i -e 's/^oauth_application:/#oauth_application:/' $workdir/config/settings.yml
      sed -i -e 's/^oauth_key:/#oauth_key:/' $workdir/config/settings.yml

      bundle exec rails oauth:register_apps["admin"]

      cat $workdir/config/settings.local.yml
    else
      echo "OAuth2 default applications already exist. No new applications registered."
    fi

  fi
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

log_and_tail() {
  local file=$1
  if [ -f "$file" ]; then
    echo "Logs from: $file"
    tail -F "$file" &
  else
    echo "⚠️ Log file not found: $file"
  fi
}


setup_production() {
  setup_env_vars

  echo "Waiting for PostgreSQL to be ready..."
  until pg_isready -h "$POSTGRES_HOST" -p 5432; do
    sleep 2
  done

  # Create the /passenger-instreg directory if it doesn’t exist. This is required in newer versions of Passenger.
  mkdir -p /var/run/passenger-instreg

  echo "Running database migrations..."
  time bundle exec rails db:migrate

  setup_admin

  if [ "$EXTERNAL_CGIMAP" == "false" ]; then
    echo "Running cgimap..."
    ./cgimap.sh
  fi

  echo "Logging and tailing logs..."
  log_and_tail /var/www/log/production.log
  log_and_tail /var/www/log/jobs_work.log
  log_and_tail /var/log/apache2/error.log
  log_and_tail /var/log/apache2/access.log

  echo "Starting Apache server..."
  start_background_jobs &
  apachectl -k start -DFOREGROUND
}

setup_development() {
  restore_db
  cp "$workdir/config/example.storage.yml" "$workdir/config/storage.yml"
  cp /tmp/settings.yml "$workdir/config/settings.yml"
  setup_env_vars
  bundle exec bin/yarn install
  bundle exec rails db:migrate --trace
  setup_admin
  bundle exec rake jobs:work &
  rails server --log-to-stdout
}

####################### Setting up Development or Production mode #######################
if [ "$ENVIRONMENT" = "development" ]; then
  setup_development
else
  setup_production
fi
