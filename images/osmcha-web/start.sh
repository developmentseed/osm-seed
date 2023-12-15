#!/usr/bin/env bash
set -ex
sed -i "s|https://osmcha.org|$OSMCHA_URL|g" package.json
yarn build:prod
cp -R build/* /staticfiles/

# mkdir -p /staticfiles/static/
# chmod a+rw /staticfiles/static/