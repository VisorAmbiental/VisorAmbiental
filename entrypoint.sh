#!/bin/sh

# Espera hasta que la base de datos esté disponible
until php artisan migrate --force; do
  echo "Waiting for database to be ready..."
  sleep 5
done

# Ejecuta PHP-FPM
php-fpm