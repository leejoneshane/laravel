FROM php:8.1-fpm-alpine

ENV TZ=Asia/Taipei
ENV APP_NAME='My Site'
ENV DB_HOST=mysql
ENV DB_PORT=3306
ENV DB_DATABASE=laravel
ENV DB_USERNAME=root
ENV CACHE_DRIVER=redis
ENV SESSION_DRIVER=redis
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html

RUN apk update \
    && apk add --no-cache bash sudo git zip unzip mc supervisor sqlite libcap freetype libpng libjpeg-turbo libzip c-client imap krb5 python3 openldap-clients mysql-client nodejs npm yarn nginx libgomp \
    && apk add --no-cache imagemagick-dev pcre-dev $PHPIZE_DEPS openssl-dev curl-dev icu-dev libxml2-dev libzip-dev imap-dev krb5-dev openldap-dev zlib-dev libjpeg-turbo-dev libpng-dev freetype-dev \
    && apk add --no-cache libreoffice libreoffice-lang-zh_tw openjdk17 font-noto-cjk \ 
    && echo -e "yes\nyes\nno\n" | pecl install igbinary redis \
    && echo -e "no\nyes\nyes\nyes\nno\n" | pecl install swoole \
    && echo -e "\n" | pecl install -o -f imagick \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure imap pdo_mysql zip bcmath soap intl ldap --host=${SYSTEM} --target=${SYSTEM}\
    && docker-php-ext-install gd imap pdo_mysql zip bcmath soap intl ldap opcache \
    && docker-php-ext-enable imagick swoole igbinary redis gd imap pdo_mysql zip bcmath soap intl ldap \
    && apk del pcre-dev $PHPIZE_DEPS openssl-dev curl-dev icu-dev libxml2-dev libzip-dev imap-dev krb5-dev openldap-dev zlib-dev libjpeg-turbo-dev libpng-dev freetype-dev \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN composer create-project --no-progress --prefer-dist laravel/laravel /var/www/html \
    && composer require doctrine/dbal \
                        http-interop/http-factory-guzzle \
                        google/apiclient \
                        laravel/socialite \
                        laravel/passport \
                        laravel/ui \
                        socialiteproviders/google \
                        socialiteproviders/facebook \
                        socialiteproviders/yahoo \
                        socialiteproviders/line \
                        appstract/laravel-opcache \
                        jenssegers/agent \
                        krustnic/docx-merge \
                        ncjoes/office-converter \
                        simplesoftwareio/simple-qrcode \
    && php artisan vendor:publish --provider="Laravel\Scout\ScoutServiceProvider" \
    && php artisan vendor:publish --provider="Appstract\Opcache\OpcacheServiceProvider" --tag="config" \
    && setcap "cap_net_bind_service=+ep" /usr/local/bin/php \
    && composer update \
    && mkdir -p /var/www/html/vendor/DocxMerge/DocxMerge \
    && cp /var/www/html/vendor/krustnic/docx-merge/* /var/www/html/vendor/DocxMerge/DocxMerge \
    && npm install axios tailwindcss postcss autoprefixer @preset/cli @tailwindcss/typography @tailwindcss/forms @tailwindcss/line-clamp @tailwindcss/aspect-ratio

COPY supervisord.conf /etc/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY laravel.conf /etc/nginx/http.d/default.conf
COPY crontab /etc/crontabs/root
COPY php.ini /usr/local/etc/php/conf.d/laravel.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY postcss.config.js /var/www/html/postcss.config.js
COPY tailwind.config.js /var/www/html/tailwind.config.js

RUN rm -rf /var/www/localhost \
    && chown -R www-data:www-data /var/www

VOLUME /var/www/html
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]