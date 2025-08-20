FROM composer:latest

RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -h /tmp -s /bin/sh -D laravel

RUN chown -R laravel:laravel /var/www/html
RUN chown -R laravel:laravel /tmp

WORKDIR /var/www/html

USER laravel

ENTRYPOINT [ "composer", "--ignore-platform-reqs" ]