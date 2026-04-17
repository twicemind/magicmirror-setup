#!/bin/bash

# MagicMirror Setup Self-Update Script
# Updates the setup itself from GitHub

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
INSTALL_DIR="/opt/magicmirror-setup"
REPO_URL="https://github.com/twicemind/magicmirror-setup.git"
BACKUP_DIR="/opt/magicmirror-setup-backup-$(date +%Y%m%d_%H%M%S)"

log() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    # Try to write to log file, but don't fail if not possible
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    local msg="[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
}

log "========================================="
log "Starting MagicMirror Setup self-update"
log "========================================="

# Check if we're running as root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    log_error "Git is not installed"
    exit 1
fi

# Check current version
CURRENT_VERSION="unknown"
if [ -f "$INSTALL_DIR/VERSION" ]; then
    CURRENT_VERSION=$(cat "$INSTALL_DIR/VERSION")
fi
log "Current version: $CURRENT_VERSION"

# Create backup
log "Creating backup..."
if [ -d "$INSTALL_DIR" ]; then
    cp -r "$INSTALL_DIR" "$BACKUP_DIR"
    log "Backup created at: $BACKUP_DIR"
fi

# Clone/pull latest version to temp directory
TEMP_DIR=$(mktemp -d)
log "Downloading latest version to $TEMP_DIR..."

if git clone "$REPO_URL" "$TEMP_DIR"; then
    log "Download successful"
else
    log_error "Failed to download latest version"
    exit 1
fi

# Get new version
NEW_VERSION="unknown"
if [ -f "$TEMP_DIR/VERSION" ]; then
    NEW_VERSION=$(cat "$TEMP_DIR/VERSION")
fi
log "New version: $NEW_VERSION"

# Check if update is needed
if [ "$CURRENT_VERSION" = "$NEW_VERSION" ] && [ "$1" != "--force" ]; then
    log "Already up to date (version $CURRENT_VERSION)"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Stop WebUI service temporarily
log "Stopping WebUI service..."
systemctl stop mm-webui.service || true

# Preserve configuration and data
log "Preserving custom configurations..."
if [ -f "$INSTALL_DIR/webui/venv" ]; then
    mv "$INSTALL_DIR/webui/venv" "$TEMP_DIR/webui/" 2>/dev/null || true
fi

# Update files
log "Installing new version..."
rsync -av --exclude='.git' --exclude='test' "$TEMP_DIR/" "$INSTALL_DIR/"

# Make scripts executable
chmod +x "$INSTALL_DIR/install.sh"
chmod +x "$INSTALL_DIR/scripts/"*.sh 2>/dev/null || true

# Reinstall Python dependencies
log "Updating Python dependencies..."
cd "$INSTALL_DIR/webui" || exit 1
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
# shellcheck disable=SC1091
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
deactivate

# Reload systemd (in case service files changed)
log "Reloading systemd..."
systemctl daemon-reload

# Restart WebUI service
log "Restarting WebUI service..."
systemctl start mm-webui.service

# Clean up
rm -rf "$TEMP_DIR"

log "========================================="
log "Setup updated successfully!"
log "Old version: $CURRENT_VERSION"
log "New version: $NEW_VERSION"
log "Backup available at: $BACKUP_DIR"
log "========================================="

exit 0
