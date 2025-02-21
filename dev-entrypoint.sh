#!/bin/sh

# Set XDebug mode based off ENV.
XDEBUG_MODE=${XDEBUG_MODE:-off}
echo "xdebug.mode = ${XDEBUG_MODE}" >> /usr/local/etc/php/conf.d/docker-dev.ini

# Build a shell script with the core env for cron.
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export WORDPRESS_[^CONFIG]" > /usr/local/bin/cron-env.sh
chmod +x /usr/local/bin/cron-env.sh

# Existing wp-config.php.
if [ -f /var/www/html/wp-config.php ]; then
  mv /var/www/html/wp-config.php /var/www/html/wp-config.backup.php
fi

wget https://raw.githubusercontent.com/KyleFS/docker-wp-config-php/main/wp-config.php -O /var/www/html/wp-config.php
chown www-data:www-data wp-config.php

###############################
# No PHP  changes below this. #
###############################
# Reload the config.
kill -USR2 1

# Finalize setup.
if [ -f /var/www/html/wp-load.php ]; then
  # There's an existing WP install.
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
  exec /usr/local/bin/docker-entrypoint.sh "php-fpm"
fi



