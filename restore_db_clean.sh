#!/bin/bash

BACKUP_FILE="archives/docker_archive/database_backups/test_django_backup_20250420_013431.sql.gz"

# Check if backup file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo "Backup file ${BACKUP_FILE} not found!"
    exit 1
fi

# Drop all tables
echo "Dropping existing tables..."
docker compose -f docker-compose.dev.yml exec postgres psql -U newuser mydatabase << 'EOF'
DO $$ DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;
EOF

# Decompress backup
echo "Decompressing backup..."
gunzip -c "${BACKUP_FILE}" > temp_backup.sql

# Restore database using docker compose
echo "Restoring database..."
docker compose -f docker-compose.dev.yml exec -T postgres psql -U newuser mydatabase < temp_backup.sql

# Clean up
rm temp_backup.sql

echo "Database restore completed!" 