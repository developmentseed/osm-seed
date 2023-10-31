#!/usr/bin/env bash
set -ex

# Build frontend
cd /osmcha-frontend
REACT_APP_VERSION=ohm REACT_APP_STACK=PRODUCTION PUBLIC_URL=$OSMCHA_URL npx react-scripts build
cp -R build/*.html /app/osmchadjango/frontend/templates/frontend/
cp -R build/* /app/osmchadjango/static/
cp -R build/static/* /app/osmchadjango/static/

# Start service
cd /app
python3 manage.py collectstatic --noinput
python3 manage.py migrate
supervisord -c /etc/supervisor/supervisord.conf
