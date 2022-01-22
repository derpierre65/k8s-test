#!/bin/sh

set -e

ROLE=${CONTAINER_ROLE:-app}

cd /var/www/html/

php artisan config:cache
php artisan route:cache
php artisan view:cache

if [ "$ROLE" = "app" ]; then
  exec /usr/bin/supervisord -n -c "/etc/supervisord_plain.conf"
else
  echo "Unsupported CONTAINER_ROLE \"$ROLE\""

  exit 1
fi