#!/bin/sh

# Set XDebug mode based off ENV.
XDEBUG_MODE=${XDEBUG_MODE:-off}
echo "xdebug.mode = ${XDEBUG_MODE}" >> /usr/local/etc/php/conf.d/docker-dev.ini

# Build a shell script with the core env for cron.
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export WORDPRESS_[^CONFIG]" > /usr/local/bin/cron-env.sh
chmod +x /usr/local/bin/cron-env.sh

###############################
# No PHP  changes below this. #
###############################

# Reload the config.
kill -USR2 1

# Run WP-CLI commands now that PHP is configured.
wp --allow-root --quiet option set blog_public 0
wp --allow-root --quiet plugin install query-monitor --activate --force
wp --allow-root --quiet config shuffle-salts
wp --allow-root --quiet rewrite flush

# Run the base  images entrypoint.
exec /usr/local/bin/docker-entrypoint.sh "php-fpm"
