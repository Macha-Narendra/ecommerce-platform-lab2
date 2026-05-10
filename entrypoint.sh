#!/bin/sh

echo "Waiting for PostgreSQL..."

while ! nc -z postgres 5432; do
  sleep 1
done

echo "PostgreSQL started"

echo "Running migrations..."
python manage.py migrate

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting Gunicorn..."

gunicorn config.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 3
