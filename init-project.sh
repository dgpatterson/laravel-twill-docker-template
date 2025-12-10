#!/bin/bash

# Set error handling to stop script if we get errors
set -e

# Load DB defaults from existing .env if present
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

# macOS vs GNU sed
if [[ "$OSTYPE" == "darwin"* ]]; then SED_FLAGS=(-i ""); else SED_FLAGS=(-i); fi

# 1) Make Laravel .env from example and fill important bits
cp .env.example .env
# ensure local/dev defaults
sed "${SED_FLAGS[@]}" "s/^APP_NAME=.*/APP_NAME=\"$APP_NAME\"/" .env
sed "${SED_FLAGS[@]}" "s/^APP_ENV=.*/APP_ENV=local/" .env
sed "${SED_FLAGS[@]}" "s/^APP_DEBUG=.*/APP_DEBUG=true/" .env
sed "${SED_FLAGS[@]}" "s|^APP_URL=.*|APP_URL=http://localhost:8080|" .env

# DB to use docker network host and your chosen creds
sed "${SED_FLAGS[@]}" "s/^DB_HOST=.*/DB_HOST=mysql/" .env
sed "${SED_FLAGS[@]}" "s/^DB_PORT=.*/DB_PORT=3306/" .env
sed "${SED_FLAGS[@]}" "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE}/" .env
sed "${SED_FLAGS[@]}" "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME}/" .env
sed "${SED_FLAGS[@]}" "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env

# 2) Append Compose-only variables (do NOT overwrite .env)
COMPOSE_PROJECT_NAME=$(basename "$PWD")
{
  echo ""
  echo "# ---- docker compose vars ----"
  echo "COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}"
  echo "MYSQL_PORT=3306"
  echo "NGINX_PORT=8080"
  echo "VITE_PORT=5173"
} >> .env

# 3) Start containers
docker compose up -d --build

# 4) Wait for MySQL to be ready (simple retry loop)
echo "Waiting for MySQL to initialize..."
for i in {1..30}; do
  if docker compose exec -T mysql mysqladmin ping -h localhost --silent; then
    break
  fi
  sleep 2
done

# 5) Laravel init
docker compose exec php composer install
docker compose exec php php artisan config:clear
docker compose exec php php artisan key:generate
docker compose exec php php artisan migrate
docker compose exec php php artisan twill:install

# 6) Permissions
docker compose exec php chown -R www-data:www-data storage bootstrap/cache
docker compose exec php chmod -R 775 storage bootstrap/cache

echo "✅ Init complete. Visit http://localhost:8080"
