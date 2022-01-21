FROM php:8.0.15-fpm-alpine

# Install depencencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk add --no-cache --virtual \
    git \
    freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
    curl \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    nginx

# Clear cache
RUN #apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-configure sockets
RUN docker-php-ext-install pdo_mysql mysqli sockets mbstring exif pcntl bcmath gd zip

# Install Redis & MongoDB PHP Extension
RUN pecl install redis \
    && pecl install mongodb \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mongodb

# clean up
RUN docker-php-source delete \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /tmp/* /var/cache/apk/*

COPY . /var/www/html/
COPY build/start.sh /usr/local/bin/start
COPY build/nginx/conf.d/default.conf /etc/nginx/sites-enabled/

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html/
EXPOSE 80
CMD ["/usr/local/bin/start"]