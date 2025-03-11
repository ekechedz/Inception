FROM wordpress:latest

# Install PHP extensions for WordPress
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev     && docker-php-ext-configure gd --with-freetype --with-jpeg     && docker-php-ext-install gd

# Expose HTTP port for WordPress
EXPOSE 80
