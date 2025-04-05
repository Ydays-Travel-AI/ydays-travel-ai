#!/bin/sh
set -e

echo "🔐 Generating app secret"
if ! grep -qsE '^APP_SECRET=.*[^[:space:]]+' .env.local; then
  SECRET=$(php -r 'echo bin2hex(random_bytes(16));')
  echo "APP_SECRET=$SECRET" >> .env.local
  echo "APP_SECRET created in .env.local : $SECRET"
else
  echo "APP_SECRET already exists in .env.local."
fi

echo "📦 Installing dependencies"
if [ "$MODE" = "prod" ]; then
  composer install --no-dev --optimize-autoloader
else
  composer install
fi

if [ "$MODE" = "prod" ]; then
  echo "🔥 Warming up Symfony cache (prod)"
  php bin/console cache:warmup --env=prod

  echo "📦 Dumping environment variables"
  composer dump-env prod

  echo "🚀 Starting PHP-FPM"
  exec php-fpm
else
  echo "🚀 Starting Symfony server (dev mode)"
  rm -rf ~/.symfony*/var/*
  exec symfony server:start --no-tls --allow-all-ip
fi