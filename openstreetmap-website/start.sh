#!/usr/bin/env bash
# Because we can not set up many env variable sin build process, we are going to process here!
# Precompile again, to catch the env variables
RAILS_ENV=production rake assets:precompile

# db:migrate 
bundle exec rails db:migrate

# Start the app
apachectl -k start -DFOREGROUND