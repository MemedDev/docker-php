FROM php:7.0-fpm
MAINTAINER memed <gabriel.couto@memed.com.br>

# Adding sources && upgrade && Installing packages && ttf-mscorefonts using DEB && Cleaning packages
RUN echo 'deb http://httpredir.debian.org/debian jessie contrib' >> /etc/apt/sources.list
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y --force-yes xorg libssl-dev libxrender-dev fontconfig xfonts-75dpi curl mysql-client-5.5 libcurl4-gnutls-dev libxml2-dev libpng12-dev libicu-dev libmcrypt-dev libjpeg62-turbo-dev libfreetype6-dev libjpeg62-turbo zlib1g-dev libmemcached11 libmemcached-dev git libgmp-dev psmisc nodejs nodejs-legacy npm xpdf libmagickwand-dev imagemagick xfonts-utils cabextract wget && \
    wget http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb && dpkg -i ttf-mscorefonts-installer_3.6_all.deb && rm -f ttf-mscorefonts-installer_3.6_all.deb && \
    apt-get clean && apt-get autoremove -y

# Building memcached extension && Creating symlink for libgmb && Install PHP Imagick extension
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git && cd php-memcached && phpize && ./configure && make install && \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
    yes "" | pecl install imagick

# Adding PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install pdo curl gd intl pdo_mysql mcrypt dom mbstring gmp bcmath zip opcache && \
    docker-php-ext-enable memcached && \
    docker-php-ext-enable imagick && \
    pecl install mongodb && \
    docker-php-ext-enable mongodb

# Upgrading Node && Adding composer && npm-cache && Grunt && Bower
RUN npm cache clean -f && npm install -g n && n stable && \
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && php composer-setup.php && php -r "unlink('composer-setup.php');" && mv composer.phar /usr/local/bin/composer && \
    npm install -g npm-cache && \
    npm install -g grunt-cli && \
    npm install -g bower

# Default command
CMD ["php-fpm"]
