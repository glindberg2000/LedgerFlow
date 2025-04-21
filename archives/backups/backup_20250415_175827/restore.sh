#!/bin/bash

# Restore database
echo "Restoring database..."
psql -U postgres pdf_extractor < database.sql

# Restore migrations
echo "Restoring migrations..."
rm -rf ../profiles/migrations
cp -r migrations ../profiles/

# Restore git state
echo "Restoring git state..."
git reset --hard HEAD
git clean -fd
git checkout backup_${TIMESTAMP}

echo "Restore complete!"
