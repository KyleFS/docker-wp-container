FROM wordpress:latest
RUN set -ex; \
        apt-get update && apt-get install -y \
		zip \
		unzip

RUN rm -f /usr/local/etc/php/conf.d/error-logging.ini

RUN { \
		echo 'error_reporting = E_ERROR | E_WARNING | E_PARSE | E_CORE_ERROR | E_CORE_WARNING | E_COMPILE_ERROR | E_COMPILE_WARNING | E_RECOVERABLE_ERROR'; \
		echo 'display_errors = On'; \
		echo 'display_startup_errors = On'; \
		echo 'log_errors = On'; \
		echo 'error_log = /var/www/html/error_log'; \
		echo 'log_errors_max_len = 1024'; \
		echo 'ignore_repeated_errors = On'; \
		echo 'ignore_repeated_source = Off'; \
		echo 'html_errors = Off'; \

		echo 'upload_max_filesize = 20M'; \
		echo 'post_max_size = 24M'; \
		echo 'memory_limit = 512M'; \
		echo 'max_execution_time = 35'; \
	} > /usr/local/etc/php/conf.d/DOCKER.ini


#https://github.com/docker-library/wordpress/blob/master/Dockerfile-debian.template
