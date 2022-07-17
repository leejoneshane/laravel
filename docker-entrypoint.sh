#!/bin/sh
set -euo pipefail

echo $1

if [[ "${1}" -eq "fetch" || ! -e /var/www/html/artisan ]]; then
  cp -Rp /root/html/* /var/www/html
  cp -Rp /root/html/.[^.]* /var/www/html
  chown -R www-data:www-data /var/www
fi

if mysqlshow --host=${DB_HOST} --user=${DB_USERNAME} --password=${DB_PASSWORD} ${DB_DATABASE} users; then
  echo "database ready!"
else
  composer require meilisearch/meilisearch-php laravel/telescope laravel/scout
  php artisan migrate:refresh
  php artisan passport:install
  php artisan telescope:install
fi

if [[ "${1}" -eq "init" ]]; then
  echo -e "yes\nyes\nyes\n" | php artisan migrate:refresh
  echo -e "0" | php artisan vendor:publish
  php artisan -q make:auth
  php artisan config:clear
  php artisan view:clear
  php artisan cache:clear
fi

supervisord -n -c /etc/supervisord.conf
