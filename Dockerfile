FROM php:7.0-fpm
MAINTAINER memed <gabriel.couto@memed.com.br>

# Adding sources
RUN echo 'deb http://httpredir.debian.org/debian jessie contrib' >> /etc/apt/sources.list

# Installing packages
RUN apt-get update && apt-get upgrade -y
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --force-yes xorg libssl-dev libxrender-dev fontconfig ttf-mscorefonts-installer xfonts-75dpi curl mysql-client-5.5 libcurl4-gnutls-dev libxml2-dev libpng12-dev libicu-dev libmcrypt-dev libjpeg62-turbo-dev libfreetype6-dev libjpeg62-turbo zlib1g-dev libmemcached11 libmemcached-dev

# Building memcached extension
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git && cd php-memcached && phpize && ./configure && make install

# Adding PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install pdo curl gd intl pdo_mysql mcrypt dom mbstring
RUN docker-php-ext-enable memcached

# Adding wkhtmltopdf
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && dpkg -i http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

# Cleaning
RUN apt-get clean && apt-get autoremove -y

# Adding composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# Default command
CMD ["php-fpm"]
