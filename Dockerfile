FROM php:7.2-cli-alpine
MAINTAINER memed <gabriel.couto@memed.com.br>

# Adding sources
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Installing packages
RUN apk update && apk upgrade --force
RUN export DEBIAN_FRONTEND=noninteractive && apk add --force gnupg curl mysql-client git curl-dev libxml2-dev openssh

# Adding PHP extensions
RUN docker-php-ext-install pdo curl pdo_mysql dom mbstring bcmath zip opcache
RUN pecl install mongodb
RUN docker-php-ext-enable mongodb

# Adding composer and prestissimo
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer && composer global require hirak/prestissimo

# Default command
CMD ["php-fpm"]
