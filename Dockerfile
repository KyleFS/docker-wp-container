FROM wordpress:fpm

# APT packages.
RUN set -ex; \
    apt-get update && apt-get install -y \
    cron \
    less \
    libicu-dev \
    mariadb-client \
    unzip \
    zip

# PECL packages.
RUN set -ex; \
    pecl install xdebug igbinary && \
    pecl install --configureoptions 'enable-apcu-debug="no"' apcu && \
    docker-php-ext-enable igbinary apcu xdebug

# Copy custom settings.
COPY ./fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./php.ini /usr/local/etc/php/conf.d/docker-dev.ini

# Remove the default error logging INI
RUN rm -f /usr/local/etc/php/conf.d/error-logging.ini

# Setup directories.
RUN mkdir /var/www/xdebug
RUN chown www-data:www-data /var/www/xdebug
RUN mkdir /var/www/log
RUN chown www-data:www-data /var/www/log

# Download and prep WP-CLI.
RUN set -ex; \
    curl -o /usr/local/bin/wp -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    wp --allow-root --version;

# Copy cron files, set permissions, then start the service.
COPY cron /usr/local/bin
RUN chmod +x /usr/local/bin/wp-cron.sh && \
	chmod +x /usr/local/bin/db.sh && \
    mv /usr/local/bin/crontab /etc/cron.d/wp-crontab && \
    chmod 0644 /etc/cron.d/wp-crontab && \
    crontab /etc/cron.d/wp-crontab && \
	service cron start

# Prep the entry point.
COPY dev-entrypoint.sh /usr/local/bin/dev-entrypoint.sh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh
ENTRYPOINT ["dev-entrypoint.sh"]
