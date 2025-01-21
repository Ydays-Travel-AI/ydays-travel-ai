#!/bin/bash
# Adds APP_SECRET only if it is missing
if ! grep -qsE '^APP_SECRET=.*[^[:space:]]+' .env.local; then
    SECRET=$(php -r 'echo bin2hex(random_bytes(16));')
    echo "APP_SECRET=$SECRET" >> .env.local
    echo "APP_SECRET created in .env.local : $SECRET"
else
    echo "APP_SECRET already exists in .env.local."
fi