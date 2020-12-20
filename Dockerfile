FROM php:7.2-cli-alpine

# Adding sources
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Installing packages
RUN apk update && apk upgrade --force  && apk add --force gnupg curl mysql-client git curl-dev libxml2-dev openssh-client

# Adding PHP extensions
RUN docker-php-ext-install pdo curl pdo_mysql dom mbstring bcmath zip opcache soap sockets sysvsem && \
    docker-php-ext-enable soap && \
    docker-php-ext-enable sysvsem

# Adding composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"
