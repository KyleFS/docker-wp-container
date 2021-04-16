FROM wordpress:fpm

# Add our Debian packages
RUN set -ex; \
    apt-get update && apt-get install -y \
    less \
    libicu-dev \
    mariadb-client \
    unzip \
    zip

# Add xDebug & intl
RUN set -ex; \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-configure intl \
  	&& docker-php-ext-install intl

#Add FPM settings
COPY ./fpm.conf /usr/local/etc/php-fpm.d/www.conf

# Remove the default error logging INI
RUN rm -f /usr/local/etc/php/conf.d/error-logging.ini

# Provide a clean set of INI settings
RUN { \
        echo 'error_reporting = E_ALL & ~E_NOTICE'; \
        echo 'display_errors = On'; \
        echo 'display_startup_errors = On'; \
        echo 'log_errors = On'; \
        echo 'error_log = /var/www/html/error_log'; \
        echo 'log_errors_max_len = 1024'; \
        echo 'ignore_repeated_errors = On'; \
        echo 'ignore_repeated_source = Off'; \
        echo 'html_errors = On'; \
        echo 'upload_max_filesize = 40M'; \
        echo 'post_max_size = 48M'; \
        echo 'memory_limit = 1024M'; \
        echo 'max_execution_time = 900'; \
	} > /usr/local/etc/php/conf.d/dev.ini

RUN set -ex; \
    curl -o /usr/local/bin/wp -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
    chmod +x /usr/local/bin/wp; \
    wp --allow-root --version

RUN echo 'alias wp="wp --allow-root"' >>  /root/.bashrc

COPY ./import_all_sql.sh /var/www/import_all_sql.sh

RUN chmod +x /var/www/import_all_sql.sh

COPY dev-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dev-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
