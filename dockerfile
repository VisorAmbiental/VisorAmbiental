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
    npm \
    nginx \
    libpq-dev && \
    docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


RUN find / -name 'www.conf'

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .


# Copiar el script wait-for-it
COPY scripts/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh


# Instala dependencias de Composer y Node.js
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs && \
    npm install && \
    npm run production


# Da permisos a las carpetas de almacenamiento y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public


# Limpiar la caché y configurar Laravel
RUN php artisan config:clear && \
    php artisan cache:clear && \
    php artisan route:clear && \
    php artisan view:clear && \
    php artisan route:cache && \
    php artisan view:cache



RUN rm /etc/nginx/sites-enabled/default

# Copiar configuración de Nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf


# Verificar sin default.config existe en el contenedor
RUN ls -la /etc/nginx/conf.d/

# Crear directorio de logs y copiar los logs de nginx para tener acceso a ellos
RUN mkdir -p /var/www/html/nginx-logs && \
    touch /var/log/nginx/access.log /var/log/nginx/error.log && \
    chmod 777 /var/log/nginx/access.log /var/log/nginx/error.log && \    
    cp /var/log/nginx/access.log /var/www/html/nginx-logs/access.log && \
    cp /var/log/nginx/error.log /var/www/html/nginx-logs/error.log
 

# Exponer el puerto para Nginx
EXPOSE 80



# Ejecutar migraciones y luego iniciar Nginx y PHP-FPM
 #CMD  sh    -c   "php artisan migrate --path=database/migrations/custom/2022_04_24_000000_enable_postgis_extension.php --force && php artisan migrate --force && nginx -g 'daemon off;' && php-fpm -F"
  CMD  sh    -c   "php artisan migrate --path=database/migrations/custom/2022_04_24_000000_enable_postgis_extension.php --force && php artisan migrate --force && service nginx start && php-fpm -F"
