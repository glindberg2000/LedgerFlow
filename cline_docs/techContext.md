# Technical Context

## Technologies Used
1. Backend
   - Python 3.12
   - Django 5.0+
   - PostgreSQL 15
   - Gunicorn (production)

2. Development Tools
   - Docker
   - Docker Compose
   - Git
   - Make

3. Dependencies
   - See requirements/base.txt for core
   - See requirements/dev.txt for development

## Development Setup
1. Prerequisites
   - Docker Desktop
   - Python 3.12
   - Make (optional)

2. Environment Files
   ```
   .env.dev
   --------
   DEBUG=True
   POSTGRES_DB=ledgerflow
   POSTGRES_USER=ledgerflow
   POSTGRES_PASSWORD=ledgerflow
   SECRET_KEY=django-insecure-dev-key
   ALLOWED_HOSTS=localhost,127.0.0.1
   DATABASE_URL=postgres://ledgerflow:ledgerflow@postgres:5432/ledgerflow
   PORT=8000
   ```

3. Docker Configuration
   - docker-compose.dev.yml for development
   - docker-compose.prod.yml for production
   - Dockerfile (multi-stage build)

## Technical Constraints
1. Port Usage
   - 9000: Public access
   - 8000: Internal Django
   - 5432: PostgreSQL (internal)

2. File System
   ```
   /app/
   ├── ledgerflow/          # Django project
   │   ├── __init__.py
   │   ├── settings.py
   │   ├── urls.py
   │   └── wsgi.py
   ├── apps/               # Django applications
   │   └── profiles/       # Profiles app
   ├── manage.py
   ├── static/            # Static files
   └── media/            # User uploads
   ```

3. Database
   - Name: ledgerflow
   - User: ledgerflow
   - Password: ledgerflow (dev only)
   - Host: postgres
   - Port: 5432

## Development Commands
1. Start Development
   ```bash
   # Start all services
   docker compose -f docker-compose.dev.yml up -d
   
   # View logs
   docker compose -f docker-compose.dev.yml logs -f
   
   # Run migrations
   docker compose -f docker-compose.dev.yml exec django python manage.py migrate
   ```

2. Database Operations
   ```bash
   # Create backup
   docker compose -f docker-compose.dev.yml exec postgres pg_dump -U ledgerflow ledgerflow > backups/backup.sql
   
   # Restore backup
   docker compose -f docker-compose.dev.yml exec -T postgres psql -U ledgerflow ledgerflow < backups/backup.sql
   ```

3. Django Management
   ```bash
   # Create migrations
   docker compose -f docker-compose.dev.yml exec django python manage.py makemigrations
   
   # Run migrations
   docker compose -f docker-compose.dev.yml exec django python manage.py migrate
   
   # Create superuser
   docker compose -f docker-compose.dev.yml exec django python manage.py createsuperuser
   ```

## Security Notes
1. Development
   - Debug mode enabled
   - Default credentials in .env.dev
   - All ports exposed locally
   - No HTTPS required

2. Production
   - Debug mode disabled
   - Secure credentials required
   - Limited port exposure
   - HTTPS required
   - No default passwords 