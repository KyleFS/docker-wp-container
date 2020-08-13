FROM php:7.4-fpm

RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev \
		unzip \
		zip; \
	\
	docker-php-ext-configure gd --with-freetype --with-jpeg; \
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		mysqli \
		zip; \
	\
	pecl install imagick-3.4.4; \
	docker-php-ext-enable imagick; \
	pecl install xdebug; \
	docker-php-ext-enable xdebug; \
	docker-php-ext-enable opcache;

# Provide a clean set of INI settings
RUN { \
        echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
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
