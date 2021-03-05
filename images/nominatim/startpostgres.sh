#!/bin/bash
# service postgresql start -D $PGDATA
su - postgres -c "/usr/lib/postgresql/12/bin/pg_ctl -D $PGDATA start"
tail -f /var/log/postgresql/postgresql-12-main.log
