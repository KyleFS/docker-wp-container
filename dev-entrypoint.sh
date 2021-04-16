#!/usr/bin/env bash
set -Eeuo pipefail

echo "xdebug.mode = debug
xdebug.client_host = 192.168.1.111
xdebug.client_port = 9003" >> /usr/local/etc/php/conf.d/dev.ini

exec "$@"
