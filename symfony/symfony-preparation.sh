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

if [ "$MODE" = "dev" ]; then
    echo "🔐 Generating APP_SECRET for dev"
    ./prepare-app-secret.sh generate

    echo "🔥 Warming up cache"
    php bin/console cache:warmup --env=dev

    INSTALL_FLAGS=""
else
    echo "🔐 Checking APP_SECRET for prod"
    ./prepare-app-secret.sh check

    echo "🔥 Warming up cache"
    php bin/console cache:warmup --env=prod

    echo "📦 Dumping environment variables"
    composer dump-env prod

    INSTALL_FLAGS="--no-dev --optimize-autoloader"
fi

echo "📦 Installing dependencies"
composer install $INSTALL_FLAGS
