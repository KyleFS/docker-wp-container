FROM wordpress:fpm

# Add our Debian packages
RUN set -ex; \
    apt-get update && apt-get install -y \
    gnupg \
    unzip \
    zip

# Add xDebug
RUN set -ex; \
    pecl install xdebug \
    && docker-php-ext-enable xdebug

# Remove the default error logging INI
RUN rm -f /usr/local/etc/php/conf.d/error-logging.ini

# Provide a clean set of INI settings
RUN { \
        echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
        echo 'display_errors = On'; \
        echo 'display_startup_errors = On'; \
        echo 'log_errors = On'; \
        echo 'error_log = /var/www/html/error_log'; \
        echo 'log_errors_max_len = 1024'; \
        echo 'ignore_repeated_errors = On'; \
        echo 'ignore_repeated_source = Off'; \
        echo 'html_errors = On'; \
        echo 'upload_max_filesize = 20M'; \
        echo 'post_max_size = 24M'; \
        echo 'memory_limit = 1024M'; \
        echo 'max_execution_time = 300'; \
        echo 'xdebug.remote_enable = 1'; \
        echo 'xdebug.remote_connect_back = 1'; \
        echo 'xdebug.remote_port = 9001'; \
        echo 'xdebug.scream = 0'; \
        echo 'xdebug.cli_color = 1'; \
        echo 'xdebug.show_local_vars = 1'; \
	} > /usr/local/etc/php/conf.d/DOCKER.ini

RUN set -ex; \
    url -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar; \
    chmod +x wp-cli.phar; \
    sudo mv wp-cli.phar /usr/local/bin/wp; \
    wp --allow-root --version

VOLUME /var/www/html
USER www-data
CMD ["wp", "shell"]