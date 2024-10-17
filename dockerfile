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
    npm \
    nginx \
    libpq-dev && \
    docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*



# Crear el directorio de PHP y configurar permisos y PHP-FPM
RUN mkdir -p /var/run/php && \
    chown -R www-data:www-data /var/run/php && \
    chmod 775 /var/run/php && \
    #sed -i 's|listen = *|listen = /var/run/php/php8.1-fpm.sock|' /usr/local/etc/php-fpm.d/www.conf && \
    echo "listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660" >> /usr/local/etc/php-fpm.d/www.conf

RUN sed -i 's|listen = 9000|listen = /var/run/php/php8.1-fpm.sock|' /usr/local/etc/php-fpm.d/zz-docker.conf 

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .


# Copia los archivos compilados desde tu máquina local al contenedor
COPY public /var/www/html/public

# Instala dependencias de Composer sin necesidad de npm
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Da permisos a las carpetas de almacenamiento y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public


# Remover la configuración por defecto de Nginx
RUN rm /etc/nginx/sites-enabled/default

# Copiar configuración de Nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf


# Exponer el puerto para Nginx
EXPOSE 80

# Ejecutar migraciones y luego iniciar Nginx y PHP-FPM
  CMD ["sh", "-c", "php artisan migrate --path=database/migrations/custom/2022_04_24_000000_enable_postgis_extension.php --force && php artisan migrate --force && service nginx start && php-fpm -F"]
 #CMD ["sh", "-c", "php artisan migrate --path=database/migrations/custom/2022_04_24_000000_enable_postgis_extension.php --force && php artisan migrate --force && service nginx start && php-fpm -F & tail -f /var/log/nginx/*.log"]