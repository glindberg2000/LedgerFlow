#!/bin/bash

# Define backup file path
BACKUP_FILE="/Users/greg/iCloud Drive (Archive)/repos/LedgerFlow_Archive/backups/dev/full_backup_20250422_201930/db/database.sql.gz"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found at $BACKUP_FILE"
    exit 1
fi

echo "Dropping existing tables..."
docker compose -f docker-compose.dev.yml exec -T postgres psql -U newuser mydatabase -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

echo "Restoring from backup..."
gunzip -c "$BACKUP_FILE" | docker compose -f docker-compose.dev.yml exec -T postgres psql -U newuser mydatabase

echo "Database restore completed!" 