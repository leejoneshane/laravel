FROM leejoneshane/letsencrypt-nginx

ADD default.conf /etc/nginx/conf.d/default.conf

RUN apk add --no-cache bash git php php-curl php-openssl php-json php-phar php-dom \
                          php-mysql php-pdo_mysql php-mcrypt php-ctype php-xml python \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && /usr/bin/composer create-project laravel/laravel /var/www/laravel --no-progress --prefer-dist \
    && chown -R nginx:nginx /var/www/laravel/storage /var/www/laravel/bootstrap/cache

ENV MAIL your@mail.addr
ENV DOMAIN server.tld

USER nginx
WORKDIR /var/www/laravel
VOLUME /var/www/laravel
EXPOSE 80 443 
CMD ["nginx", "-g", "daemon off;"]
