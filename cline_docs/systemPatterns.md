# System Patterns

## Architecture Overview
1. Docker-based Development
   - Multi-container setup
   - Development/Production environments
   - Volume mounts for local development

2. Django Application Structure
   ```
   ledgerflow/
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

## Key Technical Decisions
1. Port Configuration
   - Internal: 8000 (Django)
   - External: 9000 (Public)
   - Reason: Avoid conflicts with common ports

2. Database Setup
   - PostgreSQL 15
   - Dedicated user/database
   - Health checks enabled
   - Persistent volume storage

3. Development Environment
   - Hot reload enabled
   - Debug mode active
   - Environment variables in .env.dev
   - Direct volume mounting for code changes

## Docker Configuration
1. Development (docker-compose.dev.yml)
   ```yaml
   services:
     django:
       build:
         context: .
         target: dev
       volumes:
         - .:/app
       ports:
         - "9000:8000"
       environment:
         - DEBUG=1
         - DATABASE_URL=postgres://ledgerflow:ledgerflow@postgres:5432/ledgerflow
     postgres:
       image: postgres:15
       environment:
         - POSTGRES_DB=ledgerflow
         - POSTGRES_USER=ledgerflow
         - POSTGRES_PASSWORD=ledgerflow
   ```

2. Production (docker-compose.prod.yml)
   - Similar structure
   - No volume mounts
   - Gunicorn for serving
   - Collected static files

## Database Patterns
1. Migrations
   - Django ORM
   - Version controlled
   - Backup before migrations
   - Migration history preserved

2. Backup/Restore
   - Regular SQL dumps
   - Point-in-time recovery
   - Migration history included
   - Data integrity checks

## Development Workflow
1. Code Changes
   - Edit files locally
   - Auto-reload in container
   - Run migrations as needed
   - Test in development first

2. Database Changes
   - Create migrations
   - Back up current state
   - Apply changes
   - Verify integrity

## Security Patterns
1. Development
   - Debug enabled
   - Local environment only
   - Default credentials
   - All ports accessible

2. Production
   - Debug disabled
   - Secure credentials
   - Limited port exposure
   - HTTPS required 