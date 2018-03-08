#!/bin/sh
set -euo pipefail

if [[ "${FETCH}" == "yes" || ! -e /var/www/localhost/htdocs/artisan ]]; then
  cp -Rp /root/htdocs/* /var/www/localhost/htdocs
  cp -Rp /root/htdocs/.[^.]* /var/www/localhost/htdocs
fi

if [ "${INIT}" == "yes" ]; then
#  php artisan voyager:install --with-dummy
  chown -R apache:apache /var/www
  echo -e "yes\nyes\nyes\n" | php artisan migrate:refresh
  echo -e "0" | php artisan vendor:publish
  php artisan make:auth

  if [[ "${MAIL}" != "your@mail.addr" ]]; then
    sed -ri -e "s/^(\s*ServerAdmin).*$/\1 ${MAIL}/g" /etc/apache2/httpd.conf
#    echo -e "admin\n${WEB_PASSWORD}\n" | php artisan voyager:admin ${MAIL} --create
  fi
fi

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
