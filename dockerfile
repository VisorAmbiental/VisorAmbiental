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

# Instala extensiones de PHP requeridas para Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .

# Instala dependencias de Composer
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Instala dependencias de Node.js
RUN npm install

# Compila los assets de Vue.js si es necesario
RUN npm run build

# Da permisos a las carpetas de almacenamiento y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configuración de Laravel
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Exponer el puerto
EXPOSE 9000

# Comando para iniciar PHP-FPM
CMD ["php-fpm"]

