# Laravel + Twill + Vite Docker Template

This is a public starter template for rapidly building modern Laravel apps with [Twill CMS](https://twillcms.com/) and [Vite](https://vitejs.dev/), fully containerized with Docker.

This template is perfect for teams or solo devs who want:
- Dockerized local development across PHP, MySQL, and Nginx
- Content management with Twill
- Hot-reloading and asset bundling with Vite
- One-command bootstrapping with `init-project.sh`

---

## 🚀 Quick Start

Click the **Use this template** button on Github to create a new repository using this one as the template.

Once the repo is created in your account, clone it locally and run the install process:

```bash
git clone https://github.com/yourusername/my-new-project.git
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
If you're deploying to [Laravel Forge](https://forge.laravel.com/), it's as simple as creating a new site and selecting this repo from your repository list.
