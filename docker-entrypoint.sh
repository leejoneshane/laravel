#!/bin/sh
set -euo pipefail

php artisan voyager:admin ${MAIL} --create

rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
