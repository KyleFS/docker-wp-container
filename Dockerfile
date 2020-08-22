FROM wordpress:fpm

# Add our Debian packages
RUN set -ex; \
    apt-get update && apt-get install -y \
    less \
    mariadb-client \
    unzip \
    zip

# Add xDebug
RUN set -ex; \
    pecl install xdebug \
    && docker-php-ext-enable xdebug

# Remove the default error logging INI
RUN rm -f /usr/local/etc/php/conf.d/error-logging.ini

COPY ./fpm.conf /usr/local/etc/php-fpm.d/www.conf
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
        echo 'max_execution_time = 600'; \
        echo 'xdebug.remote_enable = 1'; \
        echo 'xdebug.remote_connect_back = 1'; \
        echo 'xdebug.remote_port = 9001'; \
        echo 'xdebug.scream = 0'; \
        echo 'xdebug.cli_color = 1'; \
        echo 'xdebug.show_local_vars = 1'; \
        echo 'pm = dynamic'; \
        echo 'pm.max_children = 20'; \
        echo 'pm.start_servers = 1'; \
        echo 'pm.min_spare_servers = 1'; \
        echo 'pm.max_spare_servers = 3'; \
	} > /usr/local/etc/php/conf.d/dev.ini

RUN set -ex; \
    curl -o /usr/local/bin/wp -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
    chmod +x /usr/local/bin/wp; \
    wp --allow-root --version

RUN echo 'alias wp="wp --allow-root"' >>  /root/.bashrc

COPY ./import_all_sql.sh /var/www/import_all_sql.sh

RUN chmod +x /var/www/import_all_sql.sh