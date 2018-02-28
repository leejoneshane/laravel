# laravel
This is a docker image for PHP framework: laravel, it has pre-installed predis/predis(for redis cache), laravel/socialite(OAuth authentication with Facebook, Twitter, Google, LinkedIn, GitHub and Bitbucket), laravel/passport(to develop OAUTH2 server), guzzlehttp/guzzle(a PHP HTTP client and framework for building web service clients).

The size just 88MB since it build on Alpine.

# How to use
This image not include database and redis. You should run mysql first, like below:
```
docker run -e MYSQL_ROOT_PASSWORD=your.password -e MYSQL_DATABASE=laravel -d mysql
```
If this is the first container on your computer, then it's ip will be 172.17.0.2.

Then you should run redis secondary, like below:
```
docker run -d redis
```
If this is the second container on your computer, then it's ip will be 172.17.0.3.

Now, you can lunch laravel like below:
```
docker run --name=laravel -p 80:80 -p 443:443 -d leejoneshane/laravel
```
# First time running

You should use __Kitematic__ or use -e parameter in docker command to defind the environment variable list below to tell laravel container how to start:

* __MAIL=admin@admin.com__ This will be your admin account.
* __WEB_PASSWORD=your.password__ You need to change it.
* __DB_HOST=172.17.0.2__ Link to mysql container.
* __DB_PORT=3306__ If you use another port change this, or you can bypass it.
* __DB_DATABASE=laravel__ If you use another name change this, or you can bypass it.
* __DB_USERNAME=root__ If you use another account change this, or you can bypass it.
* __DB_PASSWORD=should.match.MYSQL_ROOT_PASSWORD__ You must change it.
* __REDIS_HOST=172.17.0.3__ Link to redis container.
* __REDIS_PORT=6379__ If you use another port change this, or you can bypass it.
* __REDIS_PASSWORD=null__ If you setup password for redis change it, or you can bypass it.
* __CACHE_DRIVER=redis__ If you don't want to use redis, change it to __file__.
* __SESSION_DRIVER=redis__ If you don't want to use redis, change it to __file__.

<div align="center">
<img src="https://github.com/leejoneshane/laravel/blob/master/kitematic.png?raw=true">
</div>

# Work with SSL

This image can use letsencrypt SSL certificate, but before send request to letsencrypt, you should registered a FQDN and complete DNS configuration. use the environment variable below to tell the container:

__DOMAIN=the.site.fqdn__

Then you should lunch the container's console, And run the script named gencerts.sh to get SSL certificate::
```
docker exec laravel bash
\#>gencerts.sh
```
Wait a second you should get your certificate.

# Login to admin panel

Use browser to connect the url below, login whith your MAIL/WEB_PASSWORD to management your site.

http://the.site.fqdn/admin
