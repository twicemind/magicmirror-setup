#!/bin/bash

# MagicMirror Setup Self-Update Script
# Updates the setup itself from GitHub

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
INSTALL_DIR="/opt/magicmirror-setup"
REPO_URL="https://github.com/twicemind/magicmirror-setup.git"
BACKUP_DIR="/opt/magicmirror-setup-backup-$(date +%Y%m%d_%H%M%S)"

log() {
    local msg
    msg="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    # Try to write to log file, but don't fail if not possible
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    local msg
    msg="[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
}

log "========================================="
log "Starting MagicMirror Setup self-update"
log "========================================="

# Check if we're running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root (use: sudo bash $0)"
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
    
    # Clean up old backups (keep only the 3 most recent)
    log "Cleaning up old backups..."
    BACKUP_COUNT=$(find /opt -maxdepth 1 -type d -name "magicmirror-setup-backup-*" 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 3 ]; then
        # Find all backups, sort by modification time (oldest first), skip the 3 newest, and delete the rest
        find /opt -maxdepth 1 -type d -name "magicmirror-setup-backup-*" -printf '%T@ %p\n' 2>/dev/null | \
            sort -n | head -n -3 | cut -d' ' -f2- | \
            while read -r old_backup; do
                log "Removing old backup: $old_backup"
                rm -rf "$old_backup"
            done
    fi
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
if [ -d "$INSTALL_DIR/webui/venv" ]; then
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

# Ensure correct ownership
log "Setting ownership..."
chown -R mm:mm "$INSTALL_DIR"

# Reload systemd (in case service files changed)
log "Reloading systemd..."
systemctl daemon-reload

log "========================================="
log "Setup updated successfully!"
log "Old version: $CURRENT_VERSION"
log "New version: $NEW_VERSION"
log "Backup available at: $BACKUP_DIR"
log "========================================="

# Clean up
rm -rf "$TEMP_DIR"

# Restart WebUI service in the background after a short delay
# This allows the HTTP response to be sent before the service restarts
log "Scheduling WebUI restart in 3 seconds..."
(
    sleep 3
    log "Restarting WebUI service..."
    if systemctl restart mm-webui.service; then
        log "WebUI service restarted successfully"
    else
        log "WebUI restart failed, trying start..."
        if systemctl start mm-webui.service; then
            log "WebUI service started"
        else
            log "ERROR: WebUI service failed to start"
        fi
    fi
) >> "$LOG_FILE" 2>&1 &

exit 0
