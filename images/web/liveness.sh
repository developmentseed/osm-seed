#!/usr/bin/env bash
# This is a script for evaluating if apache2 is running in the container and PostgreSQL is reachable. 
check_process() {
    if ps aux | grep "$1" | grep -v grep > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check for apache2 process
check_process "apache2"
apache_status=$?

# Check PostgreSQL connection
check_postgres() {
    PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT 1;" > /dev/null 2>&1
    return $?
}

check_postgres
postgres_status=$?

if [ $apache_status -eq 0 ] && [ $postgres_status -eq 0 ]; then
    echo "Apache and PostgreSQL are running."
    exit 0
else
    [ $apache_status -ne 0 ] && echo "apache2 is not running!" >&2
    [ $postgres_status -ne 0 ] && echo "Failed to connect to PostgreSQL!" >&2
    exit 1
fi
