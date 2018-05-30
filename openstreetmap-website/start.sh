#!/usr/bin/env bash
workdir="/var/www"
# Because we can not set up many env variable sin build process, we are going to process here!
# Precompile again, to catch the env variables
RAILS_ENV=production rake assets:precompile

# db:migrate 
bundle exec rails db:migrate

# # Create the Application to run iD
idappregister > $workdir/idApplication.js
# aws s3 cp $workdir/idApplication.js $S3_OSM_PATH/idAplication/idApplication.json

# Start the app
apachectl -k start -DFOREGROUND