#!/bin/sh
set -euo pipefail

if [ ! -e /var/www/localhost/htdocs/server.php ]; then
  cp -Rp /root/htdocs/* /var/www/localhost/htdocs
fi

if [ ! -e /var/www/localhost/database_is_ready ]; then
#  php artisan voyager:install --with-dummy
  chown -R apache:apache /var/www
  touch /var/www/localhost/database_is_ready
  php artisan make:auth

  if [[ "${MAIL}" != "your@mail.addr" ]]; then
    sed -ri -e "s/^(\s*ServerAdmin).*$/\1 ${MAIL}/g" /etc/apache2/httpd.conf
#    echo -e "admin\n${WEB_PASSWORD}\n" | php artisan voyager:admin ${MAIL} --create
  fi
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
