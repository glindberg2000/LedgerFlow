#!/bin/bash

# Database configuration (update these values)
DB_NAME="pdf_extractor"
DB_USER="greg"
DB_PASSWORD=""

# Restore database
echo "Restoring database..."
if [ -n "$DB_PASSWORD" ]; then
    PGPASSWORD="${DB_PASSWORD}" psql -U "${DB_USER}" "${DB_NAME}" < database.sql
else
    psql -U "${DB_USER}" "${DB_NAME}" < database.sql
fi

# Restore migrations
echo "Restoring migrations..."
rm -rf ../pdf_extractor_web/profiles/migrations
cp -r migrations ../pdf_extractor_web/profiles/

# Restore memory bank
echo "Restoring memory bank..."
rm -rf ../cline_docs/*
cp -r cline_docs/* ../cline_docs/

# Restore git state
echo "Restoring git state..."
git reset --hard HEAD
git clean -fd
git checkout backup_20250417_004345

echo "Restore complete!"
