#!/bin/sh
set -e

# MODE = dev should be used during runtime
# MODE = prod should be used during build
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

APP_SECRET_EXISTS=$(grep -qsE '^APP_SECRET=.*[^[:space:]]+' "$ENV_FILE" && echo true || echo false)
JWT_PASSPHRASE_EXISTS=$(grep -qsE '^JWT_PASSPHRASE=.*[^[:space:]]+' "$ENV_FILE" && echo true || echo false)

if [ "$MODE" = "prod" ]; then
    # This variables are required in production and cannot be generated automatically (not persistent)
    if [ "$APP_SECRET_EXISTS" = false ]; then
        echo "❌ APP_SECRET is missing and must be set in $ENV_FILE (check README.md)"
        exit 1
    fi
    if [ "$JWT_PASSPHRASE_EXISTS" = false ]; then
        echo "❌ JWT_PASSPHRASE is missing and must be set in $ENV_FILE (check README.md)"
        exit 1
    fi

    INSTALL_FLAGS="--no-dev --optimize-autoloader"
else
    if [ "$APP_SECRET_EXISTS" = false ]; then
        SECRET=$(./generate-app-secret.sh)
        echo "APP_SECRET=$SECRET" >> "$ENV_FILE"
        echo "🔐 APP_SECRET generated in $ENV_FILE"
    fi

    if [ "$JWT_PASSPHRASE_EXISTS" = false ]; then
        echo "JWT_PASSPHRASE=$(openssl rand -hex 32)" >> "$ENV_FILE"
        echo "🔐 JWT_PASSPHRASE generated in $ENV_FILE"
    fi

    INSTALL_FLAGS=""
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