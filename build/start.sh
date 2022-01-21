#!/bin/sh

cd /var/www/

php composer install
php artisan config:cache
php artisan route:cache
php artisan view:cache
