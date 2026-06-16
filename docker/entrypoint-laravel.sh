#!/bin/bash
set -e

cd /var/www/laravel

if [ ! -f "artisan" ]; then
    echo ">>> Installing Laravel..."
    composer create-project laravel/laravel . --prefer-dist --no-interaction
fi

chown -R www-data:www-data /var/www/laravel
chmod -R 755 /var/www/laravel
chmod -R 775 /var/www/laravel/storage
chmod -R 775 /var/www/laravel/bootstrap/cache

if [ ! -f ".env" ]; then
    cp .env.example .env
    php8.2 artisan key:generate
fi

sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-0.0.0.0}/" .env
sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-benchmark}/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-root}/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-}/" .env

mkdir -p /run/php

echo ">>> Starting PHP-FPM..."
php-fpm8.2 -D

echo ">>> Starting Nginx on port 8002..."
nginx -g "daemon off;"
