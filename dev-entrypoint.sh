#!/bin/sh
echo "xdebug.mode = $1
xdebug.client_host = $2
error_log = /var/www/log/$3/php_error_log" >> /usr/local/etc/php/conf.d/dev.ini

mkdir /var/www/log/$3

# This kills the process to reload the new config
# https://stackoverflow.com/a/43076457
kill -USR2 1

exec /usr/local/bin/docker-entrypoint.sh php-fpm
