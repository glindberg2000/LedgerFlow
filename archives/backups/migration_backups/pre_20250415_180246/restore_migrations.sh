#!/bin/bash

# Restore migrations
echo "Restoring migrations..."
rm -rf ../../pdf_extractor_web/profiles/migrations
cp -r . ../../pdf_extractor_web/profiles/migrations/

# Reset Django migration state
echo "Resetting Django migration state..."
cd ../../pdf_extractor_web
python manage.py migrate profiles zero --fake
cd ../..

echo "Migration restore complete!"
