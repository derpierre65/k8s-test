FROM php:8.0.15-fpm

# Install depencencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip sockets mysqli
RUN docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-configure sockets
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install Redis & MongoDB PHP Extension
RUN pecl install redis \
    && pecl install mongodb \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable mongodb

COPY . /var/www/html/
COPY build/start.sh /usr/local/bin/start
COPY build/nginx/conf.d/default.conf /etc/nginx/sites-enabled/

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html/
EXPOSE 80
CMD ["/usr/local/bin/start"]