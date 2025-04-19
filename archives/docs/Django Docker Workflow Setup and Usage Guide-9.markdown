# Django Docker Workflow Setup and Usage Guide

This guide provides a complete workflow for managing a Django application with PostgreSQL in Docker, featuring separate development (dev) and production (prod) environments. It ensures isolation, supports live editing in dev, and enables easy rollbacks. Optimized for solo developers using Cursor AI on macOS with Docker Desktop.

---

## 1. Should You Create a New Repository?

Decide whether to start fresh or use a branch:

- **New Repository**:
  - **Pros**: Clean slate, no clutter.
  - **Cons**: Loses commit history.
  - **When to Choose**: Messy or sensitive repo.
- **New Branch**:
  - **Pros**: Retains history.
  - **Cons**: May need cleanup.
  - **When to Choose**: Manageable repo.

**Tip**: Use Cursor AI to assess your codebase. For a new repo, migrate code; for a branch, skip to setup.

---

## 2. Migrating Your Code (Optional)

If creating a new repo:

1. **Backup**:
   ```bash
   git clone <your-repo-url> backup-repo
   ```
2. **Create Repo**:
   ```bash
   mkdir new-django-app
   cd new-django-app
   git init
   ```
3. **Copy Code**:
   ```bash
   cp -r ../old-repo/app ./app
   cp ../old-repo/manage.py .
   ```
4. **Commit**:
   ```bash
   git add .
   git commit -m "Initial migration"
   git remote add origin <new-repo-url>
   git push origin main
   ```
5. **Migrate Database**:
   ```bash
   pg_dump -U <user> -d <db_name> -Fc > old_db.dump
   ```

If using a branch:
```bash
git checkout -b new-workflow
```

---

## 3. Setting Up the Workflow

**Note**: Requires Docker Desktop ≥4.11 (Compose v2.5) for healthcheck-based `depends_on`.

### 3.1. File Structure

```
myapp/
├── app/                     # Django source
│   └── manage.py
├── static/                  # Static files
├── requirements/
│   ├── base.txt
│   └── dev.txt
├── .dockerignore
├── .gitignore
├── .env.sample
├── Dockerfile
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.prod.yml
├── .env.dev
├── .env.prod
├── deploy.sh
├── Makefile
```

### 3.2. Docker Compose Files

**`docker-compose.yml`**:
```yaml
version: '3.9'
services:
  django:
    depends_on:
      postgres:
        condition: service_healthy
    ports:
      - "8000:8000"
    restart: on-failure
  postgres:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      retries: 5
volumes:
  postgres_data: {}
```

**`docker-compose.dev.yml`**:
```yaml
version: '3.9'
services:
  django:
    build:
      context: .
      target: dev
    volumes:
      - ./app:/app:cached
      - ./static:/static
    env_file:
      - .env.dev
  postgres:
    env_file:
      - .env.dev
    volumes:
      - postgres_data:/var/lib/postgresql/data:delegated
  adminer:
    image: adminer
    ports:
      - "127.0.0.1:8081:8080"  # Bind to localhost to avoid clashes
    depends_on:
      - postgres
volumes:
  postgres_data:
    name: postgres_data_dev
```

**Note**: If running prod on the same host, change/disable Adminer’s port to avoid conflicts (e.g., use a different port or comment out the service).

**`docker-compose.prod.yml`**:
```yaml
version: '3.9'
services:
  django:
    image: myregistry/myapp:${TAG}@sha256:<digest>  # Replace with registry and digest
    depends_on:
      postgres:
        condition: service_healthy
    env_file:
      - .env.prod
    restart: on-failure
  postgres:
    env_file:
      - .env.prod
    volumes:
      - postgres_data:/var/lib/postgresql/data:delegated
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      retries: 5
volumes:
  postgres_data:
    name: postgres_data_prod
```

**Note**: Do NOT enable Adminer in production to avoid security risks. For static files, consider offloading to S3/CloudFront for scalability.

### 3.3. Dockerfile

```dockerfile
FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements/base.txt .
RUN pip install -r base.txt

FROM base AS dev
COPY requirements/dev.txt .
RUN pip install -r dev.txt
COPY . .
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

FROM base AS prod
RUN pip install gunicorn
COPY . .
RUN mkdir -p /static
RUN python manage.py collectstatic --noinput --verbosity 0
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app.wsgi:application"]
```

### 3.4. Requirements

**`requirements/base.txt`**:
```
django>=5.0
psycopg[binary]>=3.1
django-environ
gunicorn
```

**`requirements/dev.txt`**:
```
django-debug-toolbar
```

### 3.5. Environment Files

**`.env.sample`**:
```
DEBUG=
POSTGRES_DB=
POSTGRES_USER=
POSTGRES_PASSWORD=
SECRET_KEY=
ALLOWED_HOSTS=
```

**`.env.dev`**:
```
DEBUG=True
POSTGRES_DB=dev_db
POSTGRES_USER=user
POSTGRES_PASSWORD=pass
```

**`.env.prod`**:
```
DEBUG=False
POSTGRES_DB=prod_db
POSTGRES_USER=user
POSTGRES_PASSWORD=pass
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=yourdomain.com,localhost
```

### 3.6. Gitignore

**`.gitignore`**:
```
*.env
__pycache__
*.pyc
```

### 3.7. Dockerignore

**`.dockerignore`**:
```
__pycache__
*.pyc
.git
.env*
```

### 3.8. Django Settings

Update `settings.py`:
```python
import os
import environ
env = environ.Env()
environ.Env.read_env()
DEBUG = env.bool('DEBUG', default=False)
SECRET_KEY = env.str('SECRET_KEY', default='django-insecure-default')
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS', default=['*'])
DATABASES = {
    'default': env.db_url(
        'DATABASE_URL',
        default=f"postgres://{env('POSTGRES_USER')}:{env('POSTGRES_PASSWORD')}@postgres:5432/{env('POSTGRES_DB')}",
        conn_max_age=600,
        conn_health_checks=True,
        options={'connect_timeout': 3}
    )
}
STATIC_ROOT = '/static'
```

### 3.9. Deployment Script

**`deploy.sh`**:
```bash
#!/bin/bash
set -e
source .env.prod
TAG=$1
ts=$(date +%F_%H-%M)
docker compose -p myapp-prod --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d postgres
DB_CID=$(docker compose -p myapp-prod ps -q postgres)
docker compose -p myapp-prod -f docker-compose.yml -f docker-compose.prod.yml pull django
docker exec "$DB_CID" pg_dump -U "$POSTGRES_USER" -Fc "$POSTGRES_DB" > "prod_${ts}.dump"
TAG=$TAG docker compose -p myapp-prod --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d
docker compose -p myapp-prod -f docker-compose.yml -f docker-compose.prod.yml exec django python manage.py migrate --noinput
```

Make executable:
```bash
chmod +x deploy.sh
```

### 3.10. Create Database Volumes

```bash
docker volume create postgres_data_dev
docker volume create postgres_data_prod
```

### 3.11. Import Existing Database (if Migrating)

```bash
cat old_db.dump | docker exec -i myapp-dev_postgres_1 pg_restore -U user -d dev_db -c
docker compose -p myapp-dev -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py migrate
```

### 3.12. Create Superuser

```bash
docker compose -p myapp-dev -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py createsuperuser
```

### 3.13. Test the Setup

```bash
make dev-up
```

Visit `http://localhost:8000` (app) and `http://localhost:8081` (Adminer). Edit `./app`; changes reflect live.

---

## 4. Day-to-Day Development

### 4.1. Start Dev Environment

```bash
make dev-up
```

### 4.2. Make Code Changes

Edit `./app` in Cursor AI. Changes appear instantly.

### 4.3. Run Migrations

**Dev**:
```bash
docker compose -p myapp-dev -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py makemigrations
docker compose -p myapp-dev -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py migrate
```

**Prod**:
```bash
docker compose -p myapp-prod -f docker-compose.yml -f docker-compose.prod.yml exec django python manage.py migrate
```

### 4.4. Collect Static Files (Dev)

```bash
make collect
```

### 4.5. Deploy to Prod

1. Build and push:
   ```bash
   docker build -t myregistry/myapp:v1.2.3 .
   docker push myregistry/myapp:v1.2.3
   ```
2. Deploy:
   ```bash
   bash deploy.sh v1.2.3
   ```
3. Pin the image digest in `docker-compose.prod.yml`.

Example:
```bash
make prod-up TAG=v1.2.3
```

### 4.6. Roll Back Changes

- **Code**:
  ```bash
  TAG=v1.2.2 docker compose -p myapp-prod --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d
  ```
- **Database**:
  ```bash
  cat prod_<timestamp>.dump | docker exec -i myapp-prod_postgres_1 pg_restore -U user -d prod_db -c
  ```

---

## 5. Using Cursor AI

- Leverage Cursor AI for code completion and Git operations.
- Stay on the `dev` branch for edits.

---

## 6. macOS Tips

- Use `:cached` (code) and `:delegated` (Postgres) for performance.
- For x86 dependencies:
  ```bash
  export DOCKER_DEFAULT_PLATFORM=linux/amd64
  ```
  Unset after successful build:
  ```bash
  unset DOCKER_DEFAULT_PLATFORM
  ```

---

## 7. Maintenance cheatsheet

- View logs: `make logs-dev`
- Stop and remove containers: `docker compose -p myapp-dev -f docker-compose.yml -f docker-compose.dev.yml down`
- Remove volumes: `docker compose -p myapp-dev -f docker-compose.yml -f docker-compose.dev.yml down -v`
- List volumes: `docker volume ls`
- Inspect container: `docker inspect myapp-dev_django_1`

---

## 8. Tips

- Work in `dev` branch; merge to `main` for prod.
- Use semantic tags (e.g., `v1.2.3`) and pin digests.
- Backup prod databases before deploying.
- For new projects, consider `postgres:16` (supported until November 2028) if libraries and extensions are compatible; `postgres:15` is safer for migrations.

---

## 9. Next Steps: CI/CD

Ready to automate? See [this Docker-Compose deploy workflow](https://github.com/actions/example-docker-compose) for a minimal setup.