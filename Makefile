.PHONY: help dev-up dev-build dev-down prod-up prod-build prod-down migrate makemigrations shell test lint format clean dev prod rollback backup restore nuke status init-prod verify-backup smoke-test

help:
	@echo "Available commands:"
	@echo "  make dev-up      - Start development environment"
	@echo "  make dev-build   - Build development environment"
	@echo "  make dev-down    - Stop development environment"
	@echo "  make prod-up     - Start production environment"
	@echo "  make prod-build  - Build production environment"
	@echo "  make prod-down   - Stop production environment"
	@echo "  make migrate     - Run database migrations"
	@echo "  make migrations  - Create database migrations"
	@echo "  make shell       - Open Django shell"
	@echo "  make test        - Run tests"
	@echo "  make lint        - Run linters"
	@echo "  make format      - Format code"
	@echo "  make clean       - Remove Python artifacts"
	@echo "  make dev         - Start development environment"
	@echo "  make prod TAG=<tag> - Deploy specific version to production"
	@echo "  make rollback TAG=<tag> - Rollback to specific version"
	@echo "  make backup      - Create manual backup"
	@echo "  make restore FILE=<path> - Restore from backup file"
	@echo "  make nuke ENV=<dev|prod> - Destroy environment (requires confirmation)"
	@echo "  make status      - Check services status"
	@echo "  make init-prod   - Initialize production environment"
	@echo "  make verify-backup FILE=<path> - Verify backup integrity"
	@echo "  make smoke-test  - Run smoke tests"

# Environment validation
ENV ?= dev
ifeq ($(ENV),prod)
	COMPOSE_PROJECT_NAME=ledger-prod
else
	COMPOSE_PROJECT_NAME=ledger-dev
endif

# Safety checks
check-env:
	@if [ "$(ENV)" = "prod" ]; then \
		echo "🚨 PRODUCTION ENVIRONMENT DETECTED"; \
		read -p "Type CONFIRM to proceed: " confirm; \
		if [ "$$confirm" != "CONFIRM" ]; then \
			echo "Operation cancelled"; \
			exit 1; \
		fi \
	fi

dev-up:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up

dev-build:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml build

dev-down:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down

prod-up:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

prod-build:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml build

prod-down:
	docker compose -f docker-compose.yml -f docker-compose.prod.yml down

migrate:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py migrate

migrations:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py makemigrations

shell:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py shell

test:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django python manage.py test

lint:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django flake8 .

format:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django black .
	docker compose -f docker-compose.yml -f docker-compose.dev.yml exec django isort .

clean:
	find . -type d -name "__pycache__" -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type f -name ".coverage" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +
	find . -type d -name "*.egg" -exec rm -r {} +
	find . -type d -name ".pytest_cache" -exec rm -r {} +

dev: ## start dev env
	docker compose -p ledger-dev -f docker-compose.dev.yml up -d

prod: ## deploy image tag to prod
	@if [ -z "$(TAG)" ]; then echo "TAG is required. Usage: make prod TAG=<tag>"; exit 1; fi
	TAG=$(TAG) docker compose -p ledger-prod -f docker-compose.yml -f docker-compose.prod.yml pull django
	TAG=$(TAG) docker compose -p ledger-prod -f docker-compose.yml -f docker-compose.prod.yml up -d

rollback: ## quick rollback
	@if [ -z "$(TAG)" ]; then echo "TAG is required. Usage: make rollback TAG=<tag>"; exit 1; fi
	TAG=$(TAG) docker compose -p ledger-prod -f docker-compose.yml -f docker-compose.prod.yml up -d

# Never deletes prod
nuke: check-env
	@if [ "$(ENV)" = "prod" ]; then \
		echo "🚫 Refusing to nuke prod"; \
		exit 1; \
	fi
	@read -p "Type DESTROY to wipe $(ENV): " x; \
	if [ "$$x" = "DESTROY" ]; then \
		docker compose -p $(COMPOSE_PROJECT_NAME) down -v; \
	else \
		echo "Operation cancelled"; \
		exit 1; \
	fi

status: ## check services status
	@echo "Development Environment:"
	@docker compose -p ledger-dev -f docker-compose.dev.yml ps
	@echo "\nProduction Environment:"
	@docker compose -p ledger-prod -f docker-compose.yml -f docker-compose.prod.yml ps

# Backup with size verification
backup:
	@echo "📦 Creating backup..."
	@mkdir -p backups
	@BACKUP_FILE=backups/manual_`date +%F_%T`.dump; \
	docker compose -p $(COMPOSE_PROJECT_NAME) exec -T postgres \
		pg_dump -U newuser -d mydatabase -Fc --clean > $$BACKUP_FILE; \
	if [ $$(stat -f%z $$BACKUP_FILE) -lt 10240 ]; then \
		echo "❌ ERROR: Backup file too small!"; \
		rm $$BACKUP_FILE; \
		exit 1; \
	else \
		echo "✅ Backup created: $$BACKUP_FILE"; \
	fi

# Restore with verification
restore: check-env
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make restore FILE=path/to/backup.dump"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "❌ Backup file not found: $(FILE)"; \
		exit 1; \
	fi
	@echo "🔄 Restoring from $(FILE)..."
	@docker compose -p $(COMPOSE_PROJECT_NAME) exec -T postgres \
		pg_restore -U newuser -d mydatabase --clean --if-exists < $(FILE)

# Initialize production environment
init-prod:
	@echo "🔒 Initializing production environment..."
	@./scripts/create_protected_volumes.sh

# Verify backup integrity
verify-backup:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make verify-backup FILE=path/to/backup.dump"; \
		exit 1; \
	fi
	@echo "🔍 Verifying backup: $(FILE)"
	@if [ ! -f "$(FILE)" ]; then \
		echo "❌ File not found"; \
		exit 1; \
	fi
	@if [ $$(stat -f%z "$(FILE)") -lt 10240 ]; then \
		echo "❌ Backup file too small"; \
		exit 1; \
	fi
	@docker compose -p ledger-dev exec -T postgres \
		pg_restore --list "$(FILE)" > /dev/null && \
		echo "✅ Backup verified successfully" || \
		(echo "❌ Backup verification failed"; exit 1)

# Run smoke tests
smoke-test:
	@echo "🔬 Running smoke tests..."
	@./scripts/ledger_docker compose -p ledger-test exec django pytest tests/smoke 