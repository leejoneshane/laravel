#!/bin/sh
set -euo pipefail

if [ ! -e /var/www/localhost/htdocs/artisan ]; then
  cp -Rp /root/htdocs/* /var/www/localhost/htdocs
else
  cd /root/htdocs
  newver=$(php artisan --version)
  cd /var/www/localhost/htdocs
  ver=$(php artisan --version)
  if [ "$ver" != "$newver" ]; then
    cp -Rp /root/htdocs/* /var/www/localhost/htdocs
  fi
fi

if [ ! -e /var/www/localhost/database_is_ready ]; then
#  php artisan voyager:install --with-dummy
  chown -R apache:apache /var/www
  touch /var/www/localhost/database_is_ready
  php artisan migrate:refresh
  echo -e "0" | php artisan vendor:publish
  php artisan make:auth

  if [[ "${MAIL}" != "your@mail.addr" ]]; then
    sed -ri -e "s/^(\s*ServerAdmin).*$/\1 ${MAIL}/g" /etc/apache2/httpd.conf
#    echo -e "admin\n${WEB_PASSWORD}\n" | php artisan voyager:admin ${MAIL} --create
  fi
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
