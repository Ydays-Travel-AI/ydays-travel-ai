#!/bin/sh
set -e

MODE=$1

if [ -z "$MODE" ]; then
    echo "❌ Error: Missing MODE argument (e.g., 'dev' or 'prod')"
    exit 1
fi

# Adds APP_SECRET only if it is missing
echo "🔐 Generating APP_SECRET (if needed)"
if ! grep -qsE '^APP_SECRET=.*[^[:space:]]+' .env.local; then
    SECRET=$(php -r 'echo bin2hex(random_bytes(16));')
    echo "APP_SECRET=$SECRET" >> .env.local
    echo "APP_SECRET created in .env.local : $SECRET"
else
    echo "APP_SECRET already exists in .env.local."
fi

echo "📦 Installing dependencies"
composer install

if [ "$MODE" = "prod" ]; then
  echo "🔥 Warming up cache"
  php bin/console cache:warmup --env=prod
  
  echo "📦 Dumping environment variables"
  composer dump-env prod
fi