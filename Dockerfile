FROM php:7.2-zts-alpine
MAINTAINER memed <gabriel.couto@memed.com.br>

# Adding sources
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Installing packages
RUN apk update \
    && apk upgrade --force \
    && apk add --no-cache --force $PHPIZE_DEPS \
    gnupg curl mysql-client git curl-dev libxml2-dev openssh-client

# Adding PHP extensions
RUN docker-php-ext-install pdo curl pdo_mysql dom mbstring bcmath zip opcache

RUN pecl install mongodb
RUN docker-php-ext-enable mongodb

RUN curl -sSL https://github.com/krakjoe/pthreads/archive/master.zip -o /tmp/pthreads.zip \
&& unzip /tmp/pthreads.zip -d /tmp \
&& cd /tmp/pthreads-* \
&& phpize \
&& ./configure \
&& make \
&& make install \
&& rm -rf /tmp/pthreads*

RUN docker-php-ext-enable pthreads

# Adding composer and prestissimo
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require hirak/prestissimo

# Default command
CMD ["php-fpm"]
