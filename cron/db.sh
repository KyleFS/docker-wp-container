#!/bin/sh

ENV_FILE="/usr/local/bin/cron-env.sh"

if [ ! -e "ENV_FILE" ]; then
    exit 1
fi

. ENV_FILE

cd /var/www/html || exit
wp --allow-root --quiet db optimize
