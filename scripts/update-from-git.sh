#!/bin/bash

# Quick Update from Git (for manual updates)
# This script safely updates from GitHub, discarding local changes

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
INSTALL_DIR="/opt/magicmirror-setup"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Quick update from Git"
log "========================================="

# Change to install directory
cd "$INSTALL_DIR" || exit 1

# Get current version
CURRENT_VERSION="unknown"
if [ -f "VERSION" ]; then
    CURRENT_VERSION=$(cat VERSION)
fi
log "Current version: $CURRENT_VERSION"

# Fetch latest changes
log "Fetching latest changes..."
git fetch --all --tags

# Discard any local changes (this prevents merge conflicts)
log "Discarding local changes..."
git reset --hard origin/main

# Get new version
NEW_VERSION="unknown"
if [ -f "VERSION" ]; then
    NEW_VERSION=$(cat VERSION)
fi
log "New version: $NEW_VERSION"

# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh 2>/dev/null || true

log "========================================="
log "Git update completed successfully!"
log "Old version: $CURRENT_VERSION"
log "New version: $NEW_VERSION"
log "========================================="

# Restart WebUI if running as root
if [ "$(id -u)" -eq 0 ]; then
    log "Restarting WebUI service..."
    systemctl restart mm-webui.service || log "Note: Run 'sudo systemctl restart mm-webui.service' to apply changes"
else
    log "Note: Run 'sudo systemctl restart mm-webui.service' to apply changes"
fi

exit 0
