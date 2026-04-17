#!/bin/bash

# Install a MagicMirror module
# Usage: ./install-module.sh <git-url> [module-name]

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <git-url> [module-name]"
    echo "Example: $0 https://github.com/hangorazvan/clock"
    exit 1
fi

GIT_URL="$1"
MODULE_NAME="$2"
CONTAINER_NAME="mm"
MODULES_DIR="/opt/mm/mounts/modules"
LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# Extract module name from URL if not provided
if [ -z "$MODULE_NAME" ]; then
    MODULE_NAME=$(basename "$GIT_URL" .git)
fi

log "Installing module: $MODULE_NAME from $GIT_URL"

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_error "MagicMirror container is not running"
    exit 1
fi

# Clone module inside container
log "Cloning repository..."
if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules && git clone $GIT_URL $MODULE_NAME"; then
    log "Repository cloned successfully"
else
    log_error "Failed to clone repository"
    exit 1
fi

# Install dependencies if package.json exists
if [ -f "$MODULES_DIR/$MODULE_NAME/package.json" ]; then
    log "Installing npm dependencies..."
    if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules/$MODULE_NAME && npm install"; then
        log "Dependencies installed successfully"
    else
        log_error "Failed to install dependencies"
        exit 1
    fi
fi

log "Module $MODULE_NAME installed successfully"
log "Remember to add the module to your config.json and restart MagicMirror"
