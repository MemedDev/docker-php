FROM php:7.1-fpm
MAINTAINER memed <gabriel.couto@memed.com.br>

# Adding sources
RUN echo 'deb http://httpredir.debian.org/debian jessie contrib' >> /etc/apt/sources.list

# Installing packages
RUN apt-get update && apt-get upgrade -y
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y --force-yes libssl-dev curl mysql-client-5.5 libcurl4-gnutls-dev libxml2-dev libpng12-dev libicu-dev libjpeg62-turbo-dev libjpeg62-turbo zlib1g-dev libmemcached11 libmemcached-dev git libgmp-dev psmisc nodejs nodejs-legacy xpdf libmagickwand-dev imagemagick

# Building memcached extension
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git && cd php-memcached && phpize && ./configure && make install

# Creating symlink for libgmb
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h 

# Install PHP Imagick extension
RUN yes "" | pecl install imagick

# Adding PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install pdo curl gd intl pdo_mysql dom mbstring gmp bcmath zip opcache
RUN docker-php-ext-enable memcached
RUN docker-php-ext-enable imagick

# Cleaning
RUN apt-get clean && apt-get autoremove -y

# Adding composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer

# Adding npm
RUN curl https://www.npmjs.com/install.sh | sh

# Adding Grunt
RUN npm install -g grunt-cli

# Default command
CMD ["php-fpm"]
