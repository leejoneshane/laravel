#!/bin/sh
set -euo pipefail

if [[ "${MAIL}" != "your@mail.addr" ]]; then
  php artisan voyager:admin ${MAIL} --create
fi

if [[ "${DB_HOST}" != "db" ]]; then
  php artisan migrate:install
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
