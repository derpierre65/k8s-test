FROM php:8.0.15-fpm

COPY . /var/www/html/

# Install depencencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    unzip \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip sockets mysqli

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

COPY /build/nginx/conf.d/default.conf /etc/nginx/sites-enabled/

# install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

WORKDIR /var/www/html/
EXPOSE 80
CMD ["/usr/local/bin/start"]