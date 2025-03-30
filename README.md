# Laravel + Twill + Vite Docker Template

This is a public starter template for rapidly building modern Laravel apps with [Twill CMS](https://twillcms.com/) and [Vite](https://vitejs.dev/), fully containerized with Docker.

This template is perfect for teams or solo devs who want:
- Dockerized local development across PHP, MySQL, and Nginx
- Content management with Twill
- Hot-reloading and asset bundling with Vite
- One-command bootstrapping with `init-project.sh`

---

## 🚀 Quick Start

```bash
git clone https://github.com/yourusername/laravel-twill-docker-template.git my-new-project
cd my-new-project
./init-project.sh
```

You’ll be prompted to set your app name and database credentials. 

After the containers are built, you'll be prompted to create a Twill superuser.

Everything else just works!

Once setup completes, visit:

http://localhost:8080/admin to log in to the Twill CMS Admin area.

---

## 🛠 Requirements

- Docker + Docker Compose
- Unix-like terminal (Linux/macOS/WSL recommended)
- Node (only if you want to develop outside container)

---


## Deploying to Laravel Forge
If you're deploying to [Laravel Forge](https://forge.laravel.com/) and keeping Laravel inside the `src/` folder:

1. **Update your Forge site's web root**:
    - Set "Web Directory" to:
      ```
      src/public
      ```

2. **Symlink `.env` for production**:
    - In your Forge deploy script, add:
      ```bash
      cd src
      ln -sf ../.env .env
      composer install --no-dev --optimize-autoloader
      php artisan migrate --force
      php artisan config:cache
      ```

This allows you to keep Docker-based local development while using a standard Forge deployment for production.