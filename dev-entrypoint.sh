#!/bin/sh

# Set XDebug mode based off ENV.
XDEBUG_MODE=${XDEBUG_MODE:-off}
echo "xdebug.mode = ${XDEBUG_MODE}" >> /usr/local/etc/php/conf.d/docker-dev.ini

# Build a shell script with the core env for cron.
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export WORDPRESS_[^CONFIG]" > /usr/local/bin/cron-env.sh
chmod +x /usr/local/bin/cron-env.sh

# Existing wp-config.php.
if [ -f /var/www/html/wp-config.php ]; then
  cp /var/www/html/wp-config.php /var/www/html/wp-config.backup.php
fi

# Make sure theres no wp-config remaining.
rm -rf /var/www/html/wp-config.php

# Download dev wp-config and set ownership correctly.
curl -o /var/www/html/wp-config.php https://raw.githubusercontent.com/KyleFS/docker-wp-config-php/main/wp-config.php && \
chown www-data:www-data /var/www/html/wp-config.php;

###############################
# No PHP  changes below this. #
###############################
# Reload the config.
kill -USR2 1

# Finalize setup.
if [ ! -e index.php ] && [ ! -e wp-includes/version.php ]; then
  # There's an existing WP install.
  echo "Existing install found, prepping for dev."
  # Run WP-CLI commands.
  wp --allow-root --quiet option set blog_public 0
  wp --allow-root --quiet plugin install query-monitor --activate --force
  wp --allow-root --quiet config shuffle-salts
  wp --allow-root --quiet rewrite flush
  # Exec php-fpm as we won't run the default entry point.
  exec php-fpm
else
  # No existing WP install.
  # Run the base images entrypoint.
  echo "No existing install, running default docker-entrypoint."
  exec /usr/local/bin/docker-entrypoint.sh "php-fpm"
fi



