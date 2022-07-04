#!/bin/sh
set -euo pipefail
  
if [[ "${FETCH}" == "yes" || ! -e /var/www/html/artisan ]]; then
  cp -Rp /root/html/* /var/www/html
  cp -Rp /root/html/.[^.]* /var/www/html
fi
chown -R www-data:www-data /var/www

if mysqlshow --host=${DB_HOST} --user=${DB_USERNAME} --password=${DB_PASSWORD} ${DB_DATABASE} users; then
  echo "database ready!"
else
  php artisan migrate:refresh
  php artisan passport:install
  php artisan october:install
fi

if [[ "${INIT}" == "yes" ]]; then
  echo -e "yes\nyes\nyes\n" | php artisan migrate:refresh
  echo -e "0" | php artisan vendor:publish
  php artisan -q make:auth
  php artisan config:clear
  php artisan view:clear
  php artisan cache:clear
fi

exec php-fpm
