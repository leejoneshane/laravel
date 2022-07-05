FROM php:fpm-alpine

# what system type to compiler: intel cpu (below) or apple m1 (use 'armv7-pc-linux-musl')
ARG SYSTEM x86_64-pc-linux-musl

ENV FETCH no
ENV INIT no
ENV DOMAIN server.tld
ENV MAIL admin@admin.com
ENV WEB_PASSWORD password
ENV TZ Asia/Taipei
ENV APP_NAME 'My Site'
ENV APP_KEY base64:fx/bpfXs+pQ3j7eeZP5gkqWxBtbhUpaqELdpQeeP/N8=
ENV DB_HOST mysql
ENV DB_PORT 3306
ENV DB_DATABASE laravel
ENV DB_USERNAME root
ENV DB_PASSWORD password
ENV CACHE_DRIVER redis
ENV SESSION_DRIVER redis
ENV REDIS_HOST redis
ENV REDIS_PORT 6379
ENV REDIS_PASSWORD null
ENV MAIL_HOST mailhog
ENV MAIL_PORT 1025
ENV MAIL_USERNAME null
ENV MAIL_PASSWORD null
ENV MAIL_ENCRYPTION null
ENV MAIL_FROM_ADDRESS 'webmaster@tc.meps.tp.edu.tw'
ENV MAIL_FROM_NAME 'My Site'

WORKDIR /var/www/html

RUN apk update \
    && apk add --no-cache bash sudo git zip unzip mc supervisor sqlite libcap freetype libpng libjpeg-turbo libzip c-client imap krb5 python3 openssl openldap-clients mysql-client nodejs npm yarn nginx \
    && apk add --no-cache pcre-dev $PHPIZE_DEPS openssl-dev curl-dev icu-dev libxml2-dev libzip-dev imap-dev krb5-dev openssl-dev openldap-dev zlib-dev libjpeg-turbo-dev libpng-dev freetype-dev \ 
    && echo -e "yes\nyes\nno\n" | pecl install igbinary redis \
    && echo -e "no\nyes\nyes\nyes\nyes\n" | pecl install swoole \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap pdo_mysql zip bcmath soap intl ldap --host=${SYSTEM} --target=${SYSTEM}\
    && docker-php-ext-install gd imap pdo_mysql zip bcmath soap intl ldap \
    && docker-php-ext-enable swoole igbinary redis gd imap pdo_mysql zip bcmath soap intl ldap \
    && apk del pcre-dev $PHPIZE_DEPS openssl-dev curl-dev icu-dev libxml2-dev libzip-dev imap-dev krb5-dev openssl-dev openldap-dev zlib-dev libjpeg-turbo-dev libpng-dev freetype-dev \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN composer create-project --no-progress --prefer-dist laravel/laravel /var/www/html \
    && composer require laravel/socialite \
                        laravel/passport \
                        october/october \
    && chown -R www-data:www-data /var/www \
    && cp -Rp /var/www/html /root \
    && setcap "cap_net_bind_service=+ep" /usr/local/bin/php

ADD docker-entrypoint.sh /usr/local/bin/
COPY php.ini /usr/local/etc/php/conf.d/laravel.ini
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY crontab /etc/crontabs/root
COPY supervisord.conf /etc/supervisord.conf

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME /var/www/html
EXPOSE 80
CMD ["docker-entrypoint.sh"]
