FROM php:8.0-fpm

COPY . /var/www/

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