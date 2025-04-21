#!/bin/bash

# Database configuration for test container
DB_NAME="mydatabase"
DB_USER="newuser"
DB_PASSWORD="newpassword"
DB_HOST="localhost"
DB_PORT="5433"

# Restore database
echo "Restoring database to test container..."
PGPASSWORD="${DB_PASSWORD}" psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" "${DB_NAME}" < database.sql

# Restore migrations
echo "Restoring migrations..."
rm -rf ../pdf_extractor_web/profiles/migrations
cp -r migrations ../pdf_extractor_web/profiles/

# Restore memory bank
echo "Restoring memory bank..."
rm -rf ../cline_docs/*
cp -r cline_docs/* ../cline_docs/

echo "Test restore complete!" 