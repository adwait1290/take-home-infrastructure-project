# Start the first intermediate image from parent image
FROM wordpress:latest as builder

# Install necessary packages, using zip and libzip-dev for composer
RUN apt-get update && \
    apt-get install -y libpng-dev unzip git&& \
    docker-php-ext-install -j$(nproc) mysqli gd && \
    docker-php-ext-enable opcache mysqli

# Change WORKDIR
WORKDIR /var/www/html
# Copy your application's  files
COPY ./wordpress /var/www/html/

# Enable the necessary apache mods
RUN a2enmod expires deflate rewrite

# PHP and Opcache optimizations
RUN { \
   echo 'memory_limit=256M'; \
   echo 'post_max_size=64M'; \
   echo 'upload_max_filesize=64M'; \
   echo 'opcache.memory_consumption=256'; \
   echo 'opcache.preload=/var/www/html/preload.php'; \
   } > /usr/local/etc/php/conf.d/zz-conf.ini

# Start the second stage based on the same parent image
FROM wordpress:latest

# Copy from the builder stage
COPY --from=builder /var/www/html/ /var/www/html/

# Specify the working directory
WORKDIR /var/www/html

# Address server name issue
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn

# Port to expose
EXPOSE 80

# Don't use CMD since in Fargate the CMD is overridden by the command defined in the container definition.
ENTRYPOINT ["apache2-foreground"]
