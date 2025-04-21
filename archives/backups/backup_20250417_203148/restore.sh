#!/bin/bash

# Restore main database
echo "Restoring main database..."
if [ -n "" ]; then
    PGPASSWORD="" psql -U "newuser" "mydatabase" < main_database.sql
else
    psql -U "newuser" "mydatabase" < main_database.sql
fi

# Restore test database
echo "Restoring test database..."
if [ -n "" ]; then
    PGPASSWORD="" psql -U "newuser" "test_database" < test_database.sql
else
    psql -U "newuser" "test_database" < test_database.sql
fi

# Restore migrations
echo "Restoring migrations..."
cp -r migrations/* pdf_extractor_web/profiles/migrations/
cp -r migrations/* test_django/pdf_extractor_web/profiles/migrations/

# Restore memory bank
echo "Restoring memory bank..."
cp -r cline_docs/* ../cline_docs/

echo "Restore complete!"
