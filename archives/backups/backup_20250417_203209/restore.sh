#!/bin/bash

# Restore main database
echo "Restoring main database..."
docker exec -i postgres_container psql -U ${POSTGRES_USER} -d mydatabase < main_database.sql

# Restore test database
echo "Restoring test database..."
docker exec -i postgres_test psql -U newuser -d mydatabase < test_database.sql

# Restore migrations
echo "Restoring migrations..."
cp -r migrations/* ../pdf_extractor_web/profiles/migrations/

# Restore memory bank
echo "Restoring memory bank..."
cp -r cline_docs/* ../cline_docs/

echo "Restore complete!"
