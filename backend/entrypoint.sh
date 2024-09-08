#!/bin/bash
set -e

# Move to working directory
cd /usr/src/app/snypy/

echo "Startring Snypy Server..."

# RUN_MODE
if [ -z "$RUN_MODE" ]; then
    export RUN_MODE="production"
fi

echo "Running in $RUN_MODE mode"

# GUNICORN_WORKERS
if [ -z "$GUNICORN_WORKERS" ]; then
    export GUNICORN_WORKERS=2
fi

echo "Using $GUNICORN_WORKERS workers"

# BIND_ADDRESS
if [ -z "$BIND_ADDRESS" ]; then
    export BIND_ADDRESS="0.0.0.0:8000"
fi

echo "Binding to address $BIND_ADDRESS"

# Check if run command is provided
if [ -z "$@" ]; then
    echo "No command provided. Running default Django server."

    if [ "$RUN_MODE" != "production" ]; then
        echo "Install dev dependencies..."
        pip install -r ../requirements/dev.txt
    fi

    echo "Running migrations..."
    python manage.py migrate

    echo "Collecting static files..."
    python manage.py collectstatic --noinput

    if [ "$RUN_MODE" = "production" ]; then
        echo "Starting gunicorn..."
        exec gunicorn snypy.wsgi --workers $GUNICORN_WORKERS --bind $BIND_ADDRESS
    else
        echo "Starting development server..."
        python manage.py runserver $BIND_ADDRESS
    fi
else
    echo "Running custom command: $@"
    exec "$@"
fi
