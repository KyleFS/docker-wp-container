#!/bin/sh
echo "xdebug.mode = %1
xdebug.client_host = %2" >> /usr/local/etc/php/conf.d/dev.ini

kill -USR2 1

exec /usr/local/bin/docker-entrypoint.sh php-fpm
