FROM php:8.2-fpm

RUN apt update

RUN apt install -y nginx
RUN apt install -y ufw
RUN ufw allow 'Nginx HTTP'

RUN apt install -y \
    git \
    curl \
    libicu-dev \
    libbz2-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    g++ \ 
    gcc make autoconf libc-dev pkg-config \
    libssl-dev 


WORKDIR /var/www

COPY php/config/php.ini /usr/local/etc/php/conf.d/

COPY php/config/php.ini /usr/local/etc/php/conf.d/
COPY php/config/fpm/php-fpm.conf /usr/local/etc/
COPY php/config/fpm/pool.d /usr/local/etc/pool.d

# composer
ENV COMPOSER_HOME /var/composer

RUN curl -sS https://getcomposer.org/installer |                \
       php -- --install-dir=/usr/local/bin --filename=composer

RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

RUN rm -f /usr/local/etc/php/conf.d/assert_local.ini
COPY php/config/assert_deploy.ini /usr/local/etc/php/conf.d/
COPY php/config/opcache.ini /usr/local/etc/php/conf.d/

COPY ./app /var/www

RUN rm -rf /etc/nginx/
COPY nginx/config/ /etc/nginx/

EXPOSE 80/tcp
EXPOSE 80/udp

COPY docker-entrypoint.sh /tmp/docker-entrypoint.sh
RUN ["chmod", "+x", "/tmp/docker-entrypoint.sh"]
CMD /tmp/docker-entrypoint.sh