#!/bin/bash

# Restart MagicMirror container

set -e

CONTAINER_NAME="mm"
LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "Restarting MagicMirror container..."

if docker restart "$CONTAINER_NAME"; then
    log "Container restarted successfully"
    exit 0
else
    log_error "Failed to restart container"
    exit 1
fi
