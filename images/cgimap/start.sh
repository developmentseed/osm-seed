#!/usr/bin/env bash
set -ex

/usr/sbin/lighttpd -f lighttpd.conf

/usr/local/bin/openstreetmap-cgimap \
	--port=8000 \
	--instances=30 \
	--dbname=$POSTGRES_DB \
	--host=$POSTGRES_HOST \
	--username=$POSTGRES_USER \
	--password=$POSTGRES_PASSWORD

