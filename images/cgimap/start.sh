#!/usr/bin/env bash
set -ex

# Make sure that the follow env vars has been declare
# API_WEB_HOST
# API_WEB_PORT
envsubst < lighttpd.conf.template > lighttpd.conf
/usr/sbin/lighttpd -f lighttpd.conf

/usr/local/bin/openstreetmap-cgimap \
	--port=8000 \
	--instances=30 \
	--dbname=$POSTGRES_DB \
	--host=$POSTGRES_HOST \
	--username=$POSTGRES_USER \
	--password=$POSTGRES_PASSWORD

