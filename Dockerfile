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
    && apk add --no-cache bash sudo git zip unzip mc curl findutils supervisor sqlite3 libcap libpng-dev python3 openldap-clients mysql-client nodejs yarn \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure imap mysqli zip bcmath soap intl ldap msgpack igbinary redis swoole memcached pcov xdebug \
    && docker-php-ext-install gd imap mysqli zip bcmath soap intl ldap msgpack igbinary redis swoole memcached pcov xdebug \
    && npm install -g npm \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && mkdir /run/apache2 \
    && sed -ri \
           -e 's!^DocumentRoot "/var/www/localhost/htdocs"$!DocumentRoot "/var/www/loczip alhost/htdocs/public"!g' \
           -e 's!^<Directory "/var/www/localhost/htdocs">$!<Directory "/var/www/localhost/htdocs/public">!g' \
           -e 's!^#(LoadModule rewrite_module .*)$!\1!g' \
           -e 's!^(\s*AllowOverride) None.*$!\1 All!g' \
           -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
           -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
           "/etc/apache2/httpd.conf" \
       \
    && sed -ri \
           -e 's!^DocumentRoot "/var/www/localhost/htdocs"$!DocumentRoot "/var/www/localhost/htdocs/public"!g' \
           -e 's!^ServerName .*$!ServerName localhost!g' \
           "/etc/apache2/conf.d/ssl.conf" \
       \
    && sed -ri \
           -e 's!^(max_execution_time = )(.*)$!\1 72000!g' \
           -e 's!^(post_max_size = )(.*)$!\1 1024M!g' \
           -e 's!^(upload_max_filesize = )(.*)$!\1 1024M!g' \
           -e 's!^(memory_limit = )(.*)$!\1 2048M!g' \
           -e 's!^;(opcache.enable=)(.*)!\1 1!g' \
           -e 's!^;(opcache.memory_consumption=)(.*)!\1 1280!g' \
           -e 's!^;(opcache.max_accelerated_files=)(.*)!\1 65407!g' \
           -e 's!^;(opcache.validate_timestamps=)(.*)!\1 0!g' \
           -e 's!^;(opcache.save_comments=)(.*)!\1 1!g' \
           -e 's!^;(opcache.fast_shutdown=)(.*)!\1 0!g' \
           "/etc/php/8.1/cli/conf.d/laravel.ini" \
       \
    && rm -f index.html \
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
