#!/bin/bash

# MagicMirror Modules Update Script
# Updates all installed MagicMirror modules

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
CONTAINER_NAME="mm"
MODULES_DIR="/opt/mm/mounts/modules"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Starting modules update process"
log "========================================="

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    log_error "Docker service is not running"
    exit 1
fi

# Check if MM container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_error "MagicMirror container '${CONTAINER_NAME}' is not running"
    exit 1
fi

# Check if modules directory exists
if [ ! -d "$MODULES_DIR" ]; then
    log_error "Modules directory not found: $MODULES_DIR"
    exit 1
fi

# Find all module directories (starting with MMM-)
MODULE_COUNT=0
UPDATED_COUNT=0
FAILED_COUNT=0

for module_dir in "$MODULES_DIR"/MMM-*; do
    if [ -d "$module_dir" ]; then
        MODULE_NAME=$(basename "$module_dir")
        MODULE_COUNT=$((MODULE_COUNT + 1))
        
        log "Processing module: $MODULE_NAME"
        
        # Check if it's a git repository
        if [ -d "$module_dir/.git" ]; then
            log "  Updating from git..."
            
            # Update module inside container
            if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules/$MODULE_NAME && git pull"; then
                log "  Git pull successful"
                
                # Check if package.json exists and run npm install
                if [ -f "$module_dir/package.json" ]; then
                    log "  Running npm install..."
                    if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules/$MODULE_NAME && npm install"; then
                        log "  npm install successful"
                        UPDATED_COUNT=$((UPDATED_COUNT + 1))
                    else
                        log_error "  npm install failed for $MODULE_NAME"
                        FAILED_COUNT=$((FAILED_COUNT + 1))
                    fi
                else
                    UPDATED_COUNT=$((UPDATED_COUNT + 1))
                fi
            else
                log "  No updates available or git pull failed"
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        else
            log "  Not a git repository, skipping"
        fi
    fi
done

log "========================================="
log "Module update summary:"
log "  Total modules: $MODULE_COUNT"
log "  Updated: $UPDATED_COUNT"
log "  Failed/Skipped: $FAILED_COUNT"
log "========================================="

# Restart container if any modules were updated
if [ $UPDATED_COUNT -gt 0 ]; then
    log "Restarting MagicMirror container to apply updates..."
    docker restart "$CONTAINER_NAME"
    log "Container restarted successfully"
fi

log "Modules update process completed"
log "========================================="
