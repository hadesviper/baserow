#!/usr/bin/env bash

# Sets up all of the environment variables used by Baserow all in one with defaults
# or what the user has provided.

set -euo pipefail

export DOCKER_USER=${DOCKER_USER:-baserow_docker_user}
export DATA_DIR=${DATA_DIR:-/baserow/data}

export BASEROW_AMOUNT_OF_WORKERS=${BASEROW_AMOUNT_OF_WORKERS:-1}
export BASEROW_AMOUNT_OF_GUNICORN_WORKERS=${BASEROW_AMOUNT_OF_GUNICORN_WORKERS:-3}

export BASEROW_ENABLE_SECURE_PROXY_SSL_HEADER=${BASEROW_ENABLE_SECURE_PROXY_SSL_HEADER:-}

export PYTHONUNBUFFERED=1
export PYTHONPATH="${PYTHONPATH:-}:/baserow/backend/src:/baserow/premium/backend/src"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export TMPDIR=${TMPDIR:-/dev/shm}

export DATABASE_PASSWORD="${DATABASE_PASSWORD:-}"
export DATABASE_NAME="${DATABASE_NAME:-baserow}"
export DATABASE_USER="${DATABASE_USER:-baserow}"
export DATABASE_HOST="${DATABASE_HOST:-embed}"
export DATABASE_PORT="${DATABASE_PORT:-5432}"
export PGDATA="$DATA_DIR/postgres/"
export EXTRA_POSTGRES_ARGS="${EXTRA_POSTGRES_ARGS:-}"
export DISABLE_EMBEDDED_PSQL="${DISABLE_EMBEDDED_PSQL:-}"
export BASEROW_RUN_MINIMAL="${BASEROW_RUN_MINIMAL:-}"

export REDIS_HOST="${REDIS_HOST:-embed}"

export BASEROW_PUBLIC_URL="${BASEROW_PUBLIC_URL:-http://localhost}"
export BASEROW_CADDY_ADDRESSES="${BASEROW_CADDY_ADDRESSES:-:80}"
export BASEROW_CADDY_GLOBAL_CONF="${BASEROW_CADDY_GLOBAL_CONF:-}"


export PRIVATE_BACKEND_URL='http://localhost:8000'
export PRIVATE_WEB_FRONTEND_URL='http://localhost:3000'
export BASEROW_BACKEND_BACKEND_PORT=127.0.0.1
export BASEROW_WEBFRONTEND_BIND_ADDRESS=127.0.0.1

export DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE:-'baserow.config.settings.base'}
export SYNC_TEMPLATES_ON_STARTUP=${SYNC_TEMPLATES_ON_STARTUP:-true}
export MIGRATE_ON_STARTUP=${MIGRATE_ON_STARTUP:-true}
export MEDIA_ROOT="$DATA_DIR/media"
