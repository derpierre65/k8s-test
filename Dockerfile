FROM php:8.0.15-fpm-alpine

COPY . /var/www/

# Install depencencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update && apk upgrade && apk add --no-cache --virtual \
	    .build-deps $PHPIZE_DEPS g++ make libstdc++ curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev bash build-base libzip-dev \
        freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
        php8-curl php8-mbstring php8-xml php8-zip php8-bcmath php8-intl php8-gd php8-pcntl \
        php8-pdo_mysql php8-sqlite3 php8-pecl-redis php8-pecl-mongodb \
        nginx \
        nodejs npm \
        git \
        imagemagick imagemagick-libs \
        bash

# Enable php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install exif \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
	&& docker-php-ext-install sockets \
	&& docker-php-ext-install pcntl \
	&& docker-php-ext-configure sockets

# Install Redis & MongoDB PHP Extension
RUN pecl install redis \
    && pecl install mongodb \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mongodb

# install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

# Copy NGINX config
COPY build/nginx_default_site.conf /etc/nginx/sites-available/default
COPY build/nginx.conf /etc/nginx/nginx.conf

# Change php-fpm config
COPY build/fpm_www.conf /usr/local/etc/php-fpm.d/www.conf

# Copy the start script
COPY build/start.sh /usr/local/bin/start
RUN chmod o+x /usr/local/bin/start

# expose port 80
EXPOSE 80

CMD ["/usr/local/bin/start"]