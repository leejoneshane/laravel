#!/bin/sh
set -euo pipefail
cd /var/www/localhost/htdocs

if [[ "${DB_HOST}" != "db" ]]; then
  php artisan voyager:install --with-dummy
  php artisan storage:link
  chown -R apache:apache /var/www
fi

if [[ "${MAIL}" != "your@mail.addr" ]]; then
  sed -ri -e "s/^(\s*ServerAdmin).*$/\1 ${MAIL}/g" /etc/apache2/httpd.conf
  echo -e "admin\n${WEB_PASSWORD}\n" | php artisan voyager:admin ${MAIL}--create
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
