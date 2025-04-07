#!/bin/sh
set -e

CHECK_MODE=$1
ENV_FILE=".env.local"

if [ -z "$CHECK_MODE" ]; then
    echo "❌ Error: Missing parameter. Use 'check' to require APP_SECRET or 'generate' to create it if missing."
    exit 1
fi

if [ "$CHECK_MODE" != "check" ] && [ "$CHECK_MODE" != "generate" ]; then
    echo "❌ Error: Invalid parameter '$CHECK_MODE'. Use 'check' or 'generate'."
    exit 1
fi

if grep -qsE '^APP_SECRET=.*[^[:space:]]+' "$ENV_FILE"; then
    APP_SECRET_EXISTS=true
else 
    APP_SECRET_EXISTS=false
fi

if [ "$CHECK_MODE" = "generate" ]; then
    if [ "$APP_SECRET_EXISTS" = true ]; then
        echo "✅ APP_SECRET already exists in $ENV_FILE."
    else
        SECRET=$(php -r 'echo bin2hex(random_bytes(16));')
        echo "APP_SECRET=$SECRET" >> "$ENV_FILE"
        echo "✅ APP_SECRET created in $ENV_FILE : $SECRET"
    fi
else
    if [ "$APP_SECRET_EXISTS" = true ]; then
        echo "✅ APP_SECRET exists in $ENV_FILE."
    else
        echo "❌ APP_SECRET is missing and must be set in $ENV_FILE"
        exit 1
    fi
fi