#!/bin/sh
set -e

MODE=$1

if [ -z "$MODE" ]; then
    echo "❌ Error: Missing MODE argument (e.g., 'dev' or 'prod')"
    exit 1
fi

if [ "$MODE" != "dev" ] && [ "$MODE" != "prod" ]; then
    echo "❌ Error: MODE must be either 'dev' or 'prod'"
    exit 1
fi
ENV_FILE=".env.$MODE.local"

# Checking APP_SECRET
if grep -qsE '^APP_SECRET=.*[^[:space:]]+' "$ENV_FILE"; then
    APP_SECRET_EXISTS=true
else 
    APP_SECRET_EXISTS=false
fi

if [ "$MODE" = "dev" ]; then
    if [ "$APP_SECRET_EXISTS" = false ]; then
        SECRET=$(./generate-app-secret.sh)
        echo "APP_SECRET=$SECRET" >> "$ENV_FILE"
        echo "🔐 APP_SECRET created in $ENV_FILE : $SECRET"
    fi
    INSTALL_FLAGS=""
else
    echo "🔐 Checking APP_SECRET for prod"
    if [ "$APP_SECRET_EXISTS" = false ]; then
        echo "❌ APP_SECRET is missing and must be set in $ENV_FILE"
        exit 1
    fi
    INSTALL_FLAGS="--no-dev --optimize-autoloader"
fi

echo "📦 Installing dependencies"
composer install $INSTALL_FLAGS

if [ "$MODE" = "prod" ]; then
    echo "🔥 Warming up cache"
    php bin/console cache:warmup --env=prod

    echo "📦 Dumping environment variables"
    composer dump-env prod
fi

echo "🔑 Generating JWT keys"
php bin/console lexik:jwt:generate-keypair --skip-if-exists
# WARNING temporaire : les cles JWT doivent etre 
# persistees, et donc generees en dehors du build en production