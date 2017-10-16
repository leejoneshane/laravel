#!/bin/sh
set -euo pipefail

if [[ "${DB_HOST}" != "db" ]]; then
  sed -ri \
      -e 's!^(DB_HOST=).*$!\1 ${DB_HOST}!g' \
      -e 's!^(DB_DATABASE=).*$!\1${DB_DATABASE}!g' \
      -e 's!^(DB_USERNAME=).*$!\1${DB_USERNAME}!g' \
      -e 's!^(DB_PASSWORD=).*$!\1${DB_PASSWORD}!g' \
      /var/www/localhost/htdocs/.env
  php artisan voyager:install
fi

if [[ "${MAIL}" != "your@mail.addr" ]]; then
  sed -ri -e "s/^(\s*ServerAdmin).*$/\1 ${MAIL}/g" /etc/apache2/httpd.conf
  php artisan voyager:admin ${MAIL} --create
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
