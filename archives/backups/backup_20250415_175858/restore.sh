#!/bin/bash

# Get database credentials from settings
DB_NAME=$(python -c "from pdf_extractor_web.settings import DATABASES; print(DATABASES['default']['NAME'])")
DB_USER=$(python -c "from pdf_extractor_web.settings import DATABASES; print(DATABASES['default']['USER'])")
DB_PASSWORD=$(python -c "from pdf_extractor_web.settings import DATABASES; print(DATABASES['default']['PASSWORD'])")

# Restore database
echo "Restoring database..."
PGPASSWORD="${DB_PASSWORD}" psql -U "${DB_USER}" "${DB_NAME}" < database.sql

# Restore migrations
echo "Restoring migrations..."
rm -rf ../pdf_extractor_web/profiles/migrations
cp -r migrations ../pdf_extractor_web/profiles/

# Restore git state
echo "Restoring git state..."
git reset --hard HEAD
git clean -fd
git checkout backup_20250415_175858

echo "Restore complete!"
