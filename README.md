# laravel

This is a docker image for PHP framework: laravel, it has pre-installed laravel 9, php 8.1 fpm, nginx, php-redis, php-igbinary, php-swoole, laravel/socialite(OAuth authentication with Facebook, Twitter, Google, LinkedIn, GitHub and Bitbucket), laravel/passport(to develop OAUTH2 server), http-interop/http-factory-guzzle(HTTP factory implemented for Guzzle.).

# How to use

We recommend that you use docker-compose to build the service container, which will create the mysql database container and phpmyadmin management tool container for you. In order to facilitate your website development, mailhog, melisearch, redis servers will also be created.

# First time running

The current directory will be mounted into the container as the home directory of the website: /var/www/html, and the following two commands can be used with docker exec command:
* __fetch__: If you accidentally delete a file and cause your website to get an HTTP 500 error, you can use this command to rebuild the website directory and get back the deleted file, but make sure to backup first so that you don't waste your hard work.
* __init__: If you need to rebuild the data table, please use this command.

# Work with SSL

This container does not support https, please use traefik or other similar tools to obtain a free TLS key for you.
