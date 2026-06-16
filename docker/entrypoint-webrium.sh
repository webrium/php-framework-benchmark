#!/bin/bash
set -e

cd /var/www/webrium

if [ ! -f "composer.json" ]; then
    echo ">>> Installing Webrium..."
    composer create-project webrium/webrium . --prefer-dist --no-interaction 2>/dev/null || \
    composer create-project webrium/webirum . --prefer-dist --no-interaction
fi

chown -R www-data:www-data /var/www/webrium
chmod -R 755 /var/www/webrium

for dir in storage cache logs bootstrap/cache; do
    if [ -d "$dir" ]; then
        chmod -R 775 "$dir"
    fi
done

if [ -f ".env" ]; then
    sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-0.0.0.0}/" .env
    sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-benchmark}/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-root}/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-}/" .env
elif [ -f ".env.example" ]; then
    cp .env.example .env
    sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-0.0.0.0}/" .env
    sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-benchmark}/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-root}/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-}/" .env
fi

mkdir -p /run/php

echo ">>> Starting PHP-FPM..."
php-fpm8.2 -D

echo ">>> Starting Nginx on port 8001..."
nginx -g "daemon off;"
