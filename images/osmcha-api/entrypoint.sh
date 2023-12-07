#!/bin/bash
set -e
cmd="$@"

# This entrypoint is used to play nicely with the current cookiecutter configuration.
# Since docker-compose relies heavily on environment variables itself for configuration, we'd have to define multiple
# environment variables just to support cookiecutter out of the box. That makes no sense, so this little entrypoint
# does all this for us.
export REDIS_URL=redis://redis:6379
# the official postgres image uses 'postgres' as default user if not set explictly.
if [ -z "$POSTGRES_USER" ]; then
    export POSTGRES_USER=postgres
fi

if [ -z "$POSTGRES_HOST" ]; then
    export POSTGRES_HOST=postgres
fi

export PGHOST=$POSTGRES_HOST
export POSTGRES_USER=$POSTGRES_USER
export POSTGRES_PASSWORD=$POSTGRES_PASSWORD
# export DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/$POSTGRES_USER

export CELERY_BROKER_URL=$REDIS_URL/0


function postgres_ready(){
python << END
import sys
import psycopg2
try:
    conn = psycopg2.connect(dbname="$POSTGRES_USER", user="$POSTGRES_USER", password="$POSTGRES_PASSWORD", host="$POSTGRES_HOST")
except psycopg2.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

until postgres_ready; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - continuing..."

# Collect static files
python manage.py collectstatic --noinput

# Create directory for static files
mkdir -p /staticfiles/static

# Copy static files
cp -r /app/staticfiles/* /staticfiles/static/

# Execute the passed command
exec $cmd

# Start Gunicorn
gunicorn --workers 4 --bind 0.0.0.0:5000 --log-file "-" --access-logfile "-" config.wsgi