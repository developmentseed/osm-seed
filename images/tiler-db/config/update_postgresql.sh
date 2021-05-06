#!/bin/sh
set -e
if [ "${POSTGRES_DB_MAX_CONNECTIONS}X" != "X" ]; then
  set -x;
  sed -i -e"s/^.*max_connections =.*$/max_connections = $POSTGRES_DB_MAX_CONNECTIONS/" $PGDATA/postgresql.conf
  set +x;
fi
