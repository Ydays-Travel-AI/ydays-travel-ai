#!/bin/sh
set -e

if ! command -v php >/dev/null 2>&1; then
    echo "❌ Erreur: PHP est requis pour générer le secret" >&2
    exit 1
fi

SECRET=$(php -r 'echo bin2hex(random_bytes(16));')

if [ -z "$SECRET" ]; then
    echo "❌ Erreur: Échec de la génération du secret" >&2
    exit 1
fi

echo "$SECRET"
