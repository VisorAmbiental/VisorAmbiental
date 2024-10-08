# Utiliza una imagen base de PHP con extensiones comunes
FROM php:8.1-fpm

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
    npm

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .

# Instala dependencias de Composer y Node.js
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs && \
    npm install && \
    npm run production


# Da permisos a las carpetas de almacenamiento y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache



# Configuración de Laravel
RUN php artisan config:cache && \
php artisan route:cache && \
php artisan view:cache


# Ejecuta las migraciones de la base de datos
RUN php artisan migrate --force


# Exponer el puerto
EXPOSE 9000


# Comando para iniciar PHP-FPM
CMD ["php-fpm"]