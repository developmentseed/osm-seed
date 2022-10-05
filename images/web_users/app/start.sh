#!/bin/bash
set -e
export DEBUG=1
export SECRET_KEY=foo
export DJANGO_ALLOWED_HOSTS="localhost 127.0.0.1 [::1]"
export DJANGO_SUPERUSER_USERNAME=admin3
export DJANGO_SUPERUSER_PASSWORD=1234
export DJANGO_SUPERUSER_EMAIL="admi3n@admin.com"

function startApp () {
    # python manage.py inspectdb > models.py
    python manage.py migrate
    python manage.py createsuperuser --noinputs
    python manage.py runserver 0.0.0.0:8000
}

flag=true
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  until $(curl -sf -o /dev/null $SERVER_URL); do
    echo "Waiting to start rails ports server..."
    sleep 2
  done & startApp
done
