.PHONY: help dev-up dev-build dev-down prod-up prod-build prod-down migrate makemigrations shell test lint format clean

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