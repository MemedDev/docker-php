FROM php:7.2-cli-alpine
MAINTAINER memed <gabriel.couto@memed.com.br>

# Adding sources
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Installing packages
RUN apk update && apk upgrade --force  && apk add --force gnupg curl mysql-client git curl-dev libxml2-dev openssh-client

# Adding PHP extensions
RUN docker-php-ext-install pdo curl pdo_mysql dom mbstring bcmath zip opcache soap sockets
RUN docker-php-ext-enable soap

# Adding composer and prestissimo
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer && composer global require hirak/prestissimo
