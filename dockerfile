# Utiliza una imagen base de PHP con extensiones comunes
FROM php:8.1-fpm-bullseye

# Instala dependencias del sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libpq-dev && \
    docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .

RUN RUN sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /usr/local/etc/php-fpm.d/www.conf

# Instala dependencias de Composer
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Da permisos a las carpetas de almacenamiento y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public

# Exponer el puerto para Nginx
EXPOSE 9000

# Ejecutar migraciones y luego iniciar Nginx y PHP-FPM
  CMD ["php-fpm"]
