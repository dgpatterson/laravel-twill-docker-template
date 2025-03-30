#!/bin/bash

# Attempt to load DB config from root .env if it exists
if [ -f .env ]; then
  export $(grep -E '^(DB_DATABASE|DB_USERNAME|DB_PASSWORD)=' .env | xargs)
fi

read -p "Enter app name: " APP_NAME
read -p "MySQL DB name [${DB_DATABASE:-laravel}]: " INPUT_DB_DATABASE
read -p "MySQL username [${DB_USERNAME:-laravel}]: " INPUT_DB_USERNAME
read -p "MySQL password [${DB_PASSWORD:-secret}]: " INPUT_DB_PASSWORD

# Use existing values or fall back to input/default
DB_DATABASE=${INPUT_DB_DATABASE:-${DB_DATABASE:-laravel}}
DB_USERNAME=${INPUT_DB_USERNAME:-${DB_USERNAME:-laravel}}
DB_PASSWORD=${INPUT_DB_PASSWORD:-${DB_PASSWORD:-secret}}

# Detect sed style for compatibility (macOS vs GNU)
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_FLAGS=(-i "")
else
  SED_FLAGS=(-i)
fi

# Laravel .env setup
cp src/.env.example src/.env
sed "${SED_FLAGS[@]}" "s/^APP_NAME=.*/APP_NAME=\"$APP_NAME\"/" src/.env
sed "${SED_FLAGS[@]}" "s/^DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" src/.env
sed "${SED_FLAGS[@]}" "s/^DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" src/.env
sed "${SED_FLAGS[@]}" "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" src/.env

# Create or update root .env file
COMPOSE_PROJECT_NAME=$(basename "$PWD")

cat > .env <<EOT
COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD
MYSQL_PORT=3306
NGINX_PORT=8080
VITE_PORT=5173
EOT

# Start containers
docker compose up -d --build

# Wait for MySQL to be ready
echo "Waiting for MySQL to initialize..."
sleep 60

# Laravel init
docker compose exec php php artisan config:clear
docker compose exec php php artisan key:generate
docker compose exec php php artisan migrate
docker compose exec php php artisan twill:install

# Permissions fix
docker compose exec php chown -R www-data:www-data storage bootstrap/cache
docker compose exec php chmod -R 775 storage bootstrap/cache

echo "✅ Init complete. Visit http://localhost:8080"