# Utiliza una imagen base de PHP con extensiones comunes
FROM php:8.1-fpm-bullseye

# Instala dependencias del sistema
RUN apt-get update --fix-missing && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    nginx \
    unzip \
    supervisor \
    libpq-dev && \
    docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Crear el directorio de PHP y configurar permisos y PHP-FPM
RUN mkdir -p /var/run/php && \ 
    chown -R www-data:www-data /var/run/php && \
    chmod 775 /var/run/php && \
    sed -i 's|listen = /var/run/php/php8.1-fpm.sock|listen = 127.0.0.1:9000|' /usr/local/etc/php-fpm.d/www.conf && \

   # sed -i 's|listen = 127.0.0.1:9000|listen = /var/run/php/php8.1-fpm.sock|' /usr/local/etc/php-fpm.d/www.conf && \
    echo "listen.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660" >> /usr/local/etc/php-fpm.d/www.conf


RUN sed -i 's|listen = /var/run/php/php8.1-fpm.sock|listen = 127.0.0.1:9000|' /usr/local/etc/php-fpm.d/zz-docker.conf


#RUN sed -i 's|listen = 9000|listen = /var/run/php/php8.1-fpm.sock|' /usr/local/etc/php-fpm.d/zz-docker.conf 


# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo
WORKDIR /var/www/html

# Copia los archivos del proyecto
COPY . .


# Crea un archivo de logs
RUN mkdir -p /var/log \
    touch /var/log/php-fpm.log \
    chown www-data:www-data /var/log/php-fpm.log \
    chmod 644 /var/log/php-fpm.log



# Ejecuta Composer para instalar dependencias
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Da permisos a las carpetas de almacenamiento y cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public && \
RUN sed -i 's|listen = /var/run/php/php8.1-fpm.sock|listen = 127.0.0.1:9000|' /usr/local/etc/php-fpm.d/www.conf &&\
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/public

RUN sed -i 's|listen = /var/run/php/php8.1-fpm.sock|listen = 127.0.0.1:9000|' /usr/local/etc/php-fpm.d/zz-docker.conf


# Remover la configuración por defecto de Nginx
RUN rm /etc/nginx/sites-enabled/default

# Copiar configuración de Nginx
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Copiar archivo de configuración de supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Exponer el puerto para PHP-FPM
EXPOSE 9000

# Ejecutar PHP-FPM
#CMD ["php-fpm"]
CMD ["/usr/bin/supervisord"]

