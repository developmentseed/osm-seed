#!/bin/sh

# max_connections
if [[ "${POSTGRES_DB_MAX_CONNECTIONS}X" != "X" ]]; then
  sed -i -e"s/^.*max_connections =.*$/max_connections = $POSTGRES_DB_MAX_CONNECTIONS/" $PGDATA/postgresql.conf
fi

# shared_buffers
if [[ "${POSTGRES_DB_SHARED_BUFFERS}X" != "X" ]]; then
  sed -i -e"s/^.*shared_buffers =.*$/shared_buffers = $POSTGRES_DB_SHARED_BUFFERS/" $PGDATA/postgresql.conf
fi

# work_mem
if [[ "${POSTGRES_DB_WORK_MEM}X" != "X" ]]; then
  sed -i -e"s/^.*#work_mem =.*$/work_mem = $POSTGRES_DB_WORK_MEM/" $PGDATA/postgresql.conf
fi

# maintenance_work_mem
if [[ "${POSTGRES_DB_MAINTENANCE_WORK_MEM}X" != "X" ]]; then
  sed -i -e"s/^.*maintenance_work_mem =.*$/maintenance_work_mem = $POSTGRES_DB_MAINTENANCE_WORK_MEM/" $PGDATA/postgresql.conf
fi

# effective_cache_size
if [[ "${POSTGRES_DB_EFFECTIVE_CACHE_SIZE}X" != "X" ]]; then
  sed -i -e"s/^.*effective_cache_size =.*$/effective_cache_size = $POSTGRES_DB_EFFECTIVE_CACHE_SIZE/" $PGDATA/postgresql.conf
fi
