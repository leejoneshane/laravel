FROM alpine

ENV MAIL your@mail.addr
ENV DOMAIN server.tld
ENV DB_HOST db
ENV DB_DATABASE laravel
ENV DB_USERNAME laraveluser
ENV DB_PASSWORD password

RUN apk add --no-cache bash git php7-fpm php7-curl php7-openssl php7-json php7-phar php7-dom \
                          php7-mysqlnd php7-pdo_mysql php7-mcrypt php7-ctype php7-xml python \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && /usr/bin/composer create-project laravel/laravel /var/www/laravel --no-progress --prefer-dist \
    && chown -R nginx:nginx /var/www/laravel/storage /var/www/laravel/bootstrap/cache



USER nginx
WORKDIR /var/www/laravel
VOLUME /var/www/laravel
EXPOSE 80 443 
CMD ["nginx", "-g", "daemon off;"]
