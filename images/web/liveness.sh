#!/usr/bin/env bash
# This is a script for evaluating if openstreetmap-cgimap, apache2, and PostgreSQL are running in the container.
check_process() {
    if ps aux | grep "$1" | grep -v grep > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check for openstreetmap-cgimap process
check_process "/openstreetmap-cgimap/build/openstreetmap-cgimap"
cgimap_status=$?

# Check for apache2 process
check_process "apache2"
apache_status=$?

# Check PostgreSQL connection
check_postgres() {
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;" > /dev/null 2>&1
    return $?
}

check_postgres
postgres_status=$?

if [ $cgimap_status -eq 0 ] && [ $apache_status -eq 0 ] && [ $postgres_status -eq 0 ]; then
    echo "All services (openstreetmap-cgimap, apache2, PostgreSQL) are running."
    exit 0
else
    [ $cgimap_status -ne 0 ] && echo "openstreetmap-cgimap is not running!" 1>&2
    [ $apache_status -ne 0 ] && echo "apache2 is not running!" 1>&2
    [ $postgres_status -ne 0 ] && echo "Failed to connect to PostgreSQL!" 1>&2
    exit 1
fi