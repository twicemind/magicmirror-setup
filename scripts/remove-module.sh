#!/bin/bash

# Remove a MagicMirror module
# Usage: ./remove-module.sh <module-name>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <module-name>"
    echo "Example: $0 MMM-Clock"
    exit 1
fi

MODULE_NAME="$1"
MODULES_DIR="/opt/mm/mounts/modules"
LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "Removing module: $MODULE_NAME"

# Check if module exists
if [ ! -d "$MODULES_DIR/$MODULE_NAME" ]; then
    log_error "Module not found: $MODULE_NAME"
    exit 1
fi

# Remove module directory
log "Removing module directory..."
rm -rf "$MODULES_DIR/$MODULE_NAME"

log "Module $MODULE_NAME removed successfully"
log "Remember to remove the module from your config.json and restart MagicMirror"
