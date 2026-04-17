#!/bin/bash

# Clean up old MagicMirror Setup Backups
# Keeps only the 3 most recent backups

LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Cleaning up old MagicMirror Setup backups"
log "========================================="

# Count all backups
BACKUP_COUNT=$(find /opt -maxdepth 1 -type d -name "magicmirror-setup-backup-*" 2>/dev/null | wc -l)
log "Found $BACKUP_COUNT backup(s)"

if [ "$BACKUP_COUNT" -le 3 ]; then
    log "Only $BACKUP_COUNT backup(s) found - nothing to clean up"
    log "========================================="
    exit 0
fi

# Delete all but the 3 newest backups
DELETED=0
find /opt -maxdepth 1 -type d -name "magicmirror-setup-backup-*" -printf '%T@ %p\n' 2>/dev/null | \
    sort -n | head -n -3 | cut -d' ' -f2- | \
    while read -r old_backup; do
        log "Removing: $old_backup"
        rm -rf "$old_backup"
        DELETED=$((DELETED + 1))
    done

log "Cleanup completed - removed old backups"
log "Kept the 3 most recent backups"
log "========================================="

exit 0
