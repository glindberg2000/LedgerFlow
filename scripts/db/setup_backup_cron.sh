#!/bin/bash

# Get the absolute path to the backup scripts
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_BACKUP_SCRIPT="$SCRIPT_DIR/backup_dev_db.sh"
FULL_BACKUP_SCRIPT="$SCRIPT_DIR/backup_dev_full.sh"

# Create a temporary cron file
TEMP_CRON=$(mktemp)
crontab -l > "$TEMP_CRON" 2>/dev/null

# Get current time and add 5 minutes for test
CURRENT_MIN=$(date +%M)
TEST_MIN=$(( (CURRENT_MIN + 5) % 60 ))
TEST_HOUR=$(date +%H)
if [ $TEST_MIN -lt $CURRENT_MIN ]; then
    TEST_HOUR=$(( (TEST_HOUR + 1) % 24 ))
fi

# Add backup jobs if they don't exist
if ! grep -q "backup_dev_db.sh" "$TEMP_CRON"; then
    # Hourly database backup
    echo "0 * * * * $DB_BACKUP_SCRIPT >> /Users/greg/iCloud\\ Drive\\ \\(Archive\\)/repos/LedgerFlow_Archive/backups/dev/db_backup.log 2>&1" >> "$TEMP_CRON"
    # Daily full backup at 2 AM
    echo "0 2 * * * $FULL_BACKUP_SCRIPT >> /Users/greg/iCloud\\ Drive\\ \\(Archive\\)/repos/LedgerFlow_Archive/backups/dev/full_backup.log 2>&1" >> "$TEMP_CRON"
    # Test run in 5 minutes
    echo "$TEST_MIN $TEST_HOUR * * * $FULL_BACKUP_SCRIPT >> /Users/greg/iCloud\\ Drive\\ \\(Archive\\)/repos/LedgerFlow_Archive/backups/dev/test_backup.log 2>&1" >> "$TEMP_CRON"
    crontab "$TEMP_CRON"
    echo "Backup cron jobs installed successfully"
    echo "Test backup scheduled for $(date -v +5M '+%H:%M')"
else
    echo "Backup cron jobs already exist"
fi

# Clean up
rm "$TEMP_CRON"

# Show current cron jobs
echo "Current cron jobs:"
crontab -l 