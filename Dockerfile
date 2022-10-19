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

RUN mkdir /var/www/xdebug
RUN chown www-data:www-data /var/www/xdebug

RUN mkdir /var/www/log
RUN chown www-data:www-data /var/www/log

# Provide a clean set of INI settings
RUN { \
        echo 'error_reporting = E_ALL & ~E_NOTICE'; \
        echo 'display_errors = On'; \
        echo 'display_startup_errors = On'; \
        echo 'log_errors = On'; \
        echo 'error_log = /var/www/log/php_error_log'; \
        echo 'log_errors_max_len = 1024'; \
        echo 'ignore_repeated_errors = On'; \
        echo 'ignore_repeated_source = Off'; \
        echo 'html_errors = On'; \
        echo 'upload_max_filesize = 40M'; \
        echo 'post_max_size = 48M'; \
        echo 'memory_limit = 1024M'; \
        echo 'max_input_vars = 3000'; \
        echo 'max_execution_time = 900'; \
        echo 'xdebug.client_port = 9003'; \
        echo 'xdebug.output_dir  = /var/www/xdebug'; \
        echo 'xdebug.start_with_request = trigger'; \
        echo 'xdebug.profiler_output_name = profile.%R'; \
        echo 'xdebug.profiler_append = 1'; \
        echo 'xdebug.scream = 1'; \
	} > /usr/local/etc/php/conf.d/dev.ini

RUN set -ex; \
    curl -o /usr/local/bin/wp -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
    chmod +x /usr/local/bin/wp; \
    wp --allow-root --version

RUN echo 'alias wp="wp --allow-root"' >>  /root/.bashrc
COPY ./import_all_sql.sh /var/www/import_all_sql.sh
RUN chmod +x /var/www/import_all_sql.sh

COPY dev-entrypoint.sh /usr/local/bin/dev-entrypoint.sh
RUN chmod +x /usr/local/bin/dev-entrypoint.sh
ENTRYPOINT ["dev-entrypoint.sh"]
CMD ["debug", "192.168.1.111"]
