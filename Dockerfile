FROM alpine

ENV MAIL your@mail.addr
ENV DOMAIN server.tld
ENV DB_HOST db
ENV DB_DATABASE laravel
ENV DB_USERNAME laraveluser
ENV DB_PASSWORD password
ADD docker-entrypoint.sh /usr/local/bin/
ADD gencerts.sh /usr/local/bin/
WORKDIR /var/www/localhost/htdocs

RUN apk update  \
    && apk add --no-cache git curl certbot acme-client openssl mysql-client apache2 apache2-ssl php7-apache2 \
                          php7-curl php7-openssl php7-json php7-phar php7-dom php7-mysqlnd php7-pdo_mysql \
                          php7-mcrypt php7-ctype php7-xml php7-mbstring python \
    && mkdir /run/apache2 \
    && sed -ri \
           -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
           -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
           -e 's!^#(LoadModule rewrite_module .*)$!\1!g' \
           -e 's!^(\s*AllowOverride) None.*$!\1 All!g' \
           "/etc/apache2/httpd.conf" \
       \
    && sed -ri \
           -e 's!^(max_execution_time = )(.*)$!\1 72000!g' \
           -e 's!^(post_max_size = )(.*)$!\1 10M!g' \
           -e 's!^(upload_max_filesize = )(.*)$!\1 10M!g' \
           -e 's!^(memory_limit = )(.*)$!\1 10M!g' \
           "/etc/php7/php.ini" \
       \
    && rm -f index.html \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && /usr/bin/composer create-project laravel/laravel /var/www/localhost/htdocs --no-progress --prefer-dist \
    && composer install \
    && chown -R apache:apache /var/www

USER apache
VOLUME /var/www/localhost/htdocs
EXPOSE 80 443 
CMD ["docker-entrypoint.sh"]
