FROM php:fpm-alpine

ENV FETCH no
ENV INIT no
ENV DOMAIN server.tld
ENV MAIL admin@admin.com
ENV WEB_PASSWORD password
ENV TZ Asia/Taipei
ENV APP_KEY base64:fx/bpfXs+pQ3j7eeZP5gkqWxBtbhUpaqELdpQeeP/N8=
ENV DB_HOST db
ENV DB_PORT 3306
ENV DB_DATABASE laravel
ENV DB_USERNAME root
ENV DB_PASSWORD password
ENV REDIS_HOST redis
ENV REDIS_PORT 6379
ENV REDIS_PASSWORD null
ENV CACHE_DRIVER redis
ENV SESSION_DRIVER redis

ADD docker-entrypoint.sh /usr/local/bin/
COPY php.ini /etc/php/8.1/cli/conf.d/laravel.ini
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
WORKDIR /var/www/localhost/htdocs

RUN apk update \
    && apk add --no-cache bash sudo git zip unzip mc curl findutils supervisor sqlite libcap libjpeg-turbo-dev libpng-dev freetype-dev python3 openldap-clients mysql-client nodejs yarn \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap mysqli zip bcmath soap intl ldap msgpack igbinary redis swoole memcached pcov xdebug \
    && docker-php-ext-install gd imap mysqli zip bcmath soap intl ldap msgpack igbinary redis swoole memcached pcov xdebug \
    && npm install -g npm \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && /usr/bin/composer create-project --no-progress --prefer-dist laravel/laravel /var/www/localhost/htdocs \
    && composer require predis/predis \
                        laravel/socialite \
                        laravel/passport \
                        guzzlehttp/guzzle \
                        appstract/laravel-opcache \
                        tcg/voyager \
    && chown -R apache:apache /var/www \
    && cp -Rp /var/www/localhost/htdocs /root \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.1

VOLUME /var/www/localhost/htdocs
EXPOSE 80 443 
CMD ["docker-entrypoint.sh"]
