#!/usr/bin/env bash
set -x
export BUILD_ENV=prod
export REACT_APP_PRODUCTION_API_URL=/api/v1
sed -i "s|https://osmcha.org|$OSMCHA_URL|g" package.json
yarn build:${BUILD_ENV}
find /app/build -type f -exec sed -i "s/www.openstreetmap.org/$OSMCHA_API_URL/g" {} +
cp -r /app/build/* /assets/
