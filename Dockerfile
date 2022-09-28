FROM php:7.2-fpm

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=node_14.x

# Adding sources and Installing packages
RUN echo 'deb http://httpredir.debian.org/debian jessie contrib' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade -y && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y gnupg xorg libssl-dev libxrender-dev fontconfig xfonts-75dpi default-mysql-client libcurl4-gnutls-dev libxml2-dev libpng-dev libicu-dev libmcrypt-dev libjpeg62-turbo-dev libfreetype6-dev libjpeg62-turbo zlib1g-dev libmemcached11 libmemcached-dev libgmp-dev psmisc xpdf libmagickwand-dev xfonts-utils cabextract curl wget git supervisor imagemagick nginx jq nodejs && \
    apt-get clean && \
    apt-get autoremove -y && \
    npm cache clean -f && \
    npm install -g npm-cache grunt-cli yarn gulp-cli gulp && \
    ln -s /usr/bin/node /usr/bin/nodejs
    
# Install ttf-mscorefonts using DEB
RUN wget http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb && \
    dpkg -i ttf-mscorefonts-installer_3.6_all.deb && \
    rm -f ttf-mscorefonts-installer_3.6_all.deb

# Building memcached extension
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git && \
    cd php-memcached && phpize && \
    ./configure && make install

# Creating symlink for libgmb
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h 

# Adding composer and prestissimo
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# Adding PHP extensions
RUN yes "" | pecl install mongodb timezonedb imagick && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install pdo curl gd intl pdo_mysql dom mbstring gmp bcmath zip opcache sysvsem soap sockets && \
    docker-php-ext-enable memcached && \
    docker-php-ext-enable imagick && \
    docker-php-ext-enable sysvsem && \
    docker-php-ext-enable soap && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-enable timezonedb

RUN sed -i 's/<policy domain="coder" rights="none" pattern="PDF" \/>/<!-- <policy domain="coder" rights="none" pattern="PDF" \/> -->/g' /etc/ImageMagick-6/policy.xml

# PHP configs
COPY "php" "/usr/local/etc/php"

# Default command
CMD ["php-fpm"]
