# System Patterns

## System Architecture

### Docker-based Development
- Multi-container setup with Docker Compose
- Separate containers for:
  - Django application
  - PostgreSQL database
  - Redis cache
- Persistent volumes for database data
- Hot-reload for development

### Database Management
- PostgreSQL as primary database
- Regular backup strategy using backup_database.sh
- Restore capability using restore_database.sh
- Migration management through Django

### Development Workflow
1. Environment setup through .env files
2. Docker container orchestration
3. Database migrations
4. Static file collection
5. Superuser creation

### Backup and Restore Pattern
1. Automated backup creation
2. Compressed SQL dumps (.sql.gz)
3. Restore process:
   - Decompress backup
   - Drop existing tables
   - Restore from SQL
   - Apply migrations if needed

### Error Handling
- Database connection retries
- Redis connection fallback
- Static file serving fallback
- Migration conflict resolution

### Security Patterns
- Environment-based configuration
- No hardcoded credentials
- Secure password storage
- Limited port exposure

## Architecture Overview

### System Architecture
- Django-based monolithic application
- Containerized services using Docker
- PostgreSQL for data persistence
- Environment-based configuration

### Design Patterns

#### Application Structure
- Django apps for modular functionality
- Model-View-Template (MVT) pattern
- Class-based views for consistency
- URL routing for RESTful endpoints

#### Data Layer
- Django ORM for database operations
- Migration-based schema management
- Automated backup/restore procedures
- Data validation through Django forms

#### Authentication & Authorization
- Django authentication system
- Role-based access control
- Session management
- Secure password handling

#### File Management
- Media file handling
- Static file serving
- File upload processing
- Backup management

### Development Patterns

#### Code Organization
- Modular Django apps
- Separation of concerns
- DRY (Don't Repeat Yourself)
- SOLID principles

#### Testing
- Unit tests with Django test framework
- Integration testing
- Test fixtures and factories
- Coverage reporting

#### Deployment
- Docker-based deployment
- Environment separation
- Configuration management
- Backup procedures

### Best Practices

#### Code Quality
- PEP 8 compliance
- Documentation standards
- Type hints usage
- Code review process

#### Security
- Environment variables for secrets
- CSRF protection
- XSS prevention
- SQL injection protection

#### Performance
- Database optimization
- Query optimization
- Caching strategies
- Resource management

#### Maintenance
- Regular backups
- Version control
- Documentation updates
- Dependency management

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

## Tool Architecture
- Tools are modular Python packages in the `tools/` directory
- Each tool package should have a clear `__init__.py` exposing its public interface
- Tool functions are registered in the database with exact module paths
- Tools should be self-contained with their own requirements and documentation

## Database Persistence
- Docker volumes used for persistent storage
- Volumes survive container restarts and rebuilds
- Never use `docker compose down -v` in development
- Regular backups stored in `archives/docker_archive/database_backups/`

## Search Integration
- SearXNG used as primary search engine
- Search tools exposed through standardized interface
- Tool configuration stored in database
- Module paths must point to exact function (e.g., `tools.search_tool.search_web`)

## Error Handling
- Detailed error logging in Django admin
- Tool errors captured and displayed in UI
- Database errors logged with full context
- Backup restoration procedures for data recovery

## Development Patterns
- Use Docker Compose for service orchestration
- Maintain persistent database state
- Document all tool interfaces
- Keep module paths up to date in admin
- Regular database backups
- Clear separation of development and production configs 