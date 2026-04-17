#!/bin/bash

# MagicMirror WLAN Manager Update Script
# Updates the WLAN manager from GitHub releases

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
WLAN_INSTALL_DIR="/opt/magicmirror-wlan"
WLAN_LOG_FILE="/var/log/magicmirror-wlan.log"
GITHUB_REPO="twicemind/magicmirror-wlan"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
MM_MODULES_DIR="/opt/mm/mounts/modules"
BACKUP_DIR="/opt/magicmirror-wlan-backup-$(date +%Y%m%d_%H%M%S)"

log() {
    local msg
    msg="[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
    echo "$msg" >> "$WLAN_LOG_FILE" 2>/dev/null || true
}

log_error() {
    local msg
    msg="[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
    echo "$msg" >> "$WLAN_LOG_FILE" 2>/dev/null || true
}

log "========================================="
log "Starting MagicMirror WLAN Manager update"
log "========================================="

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root (use: sudo bash $0)"
    exit 1
fi

# Check if WLAN manager is installed
if [ ! -d "$WLAN_INSTALL_DIR" ]; then
    log_error "MagicMirror WLAN Manager is not installed at $WLAN_INSTALL_DIR"
    log "To install, run: sudo bash /opt/magicmirror-setup/initial-modules/install-magicmirror-wlan.sh"
    exit 1
fi

# Check current version
CURRENT_VERSION="unknown"
if [ -f "$WLAN_INSTALL_DIR/.version" ]; then
    CURRENT_VERSION=$(cat "$WLAN_INSTALL_DIR/.version")
fi
log "Current version: $CURRENT_VERSION"

# Fetch latest release information
log "Checking for updates from GitHub..."
if ! RELEASE_DATA=$(curl -s "$GITHUB_API" 2>/dev/null); then
    log_error "Failed to fetch release information from GitHub"
    exit 1
fi

if ! echo "$RELEASE_DATA" | grep -q "tag_name"; then
    log_error "No releases found on GitHub"
    exit 1
fi

LATEST_VERSION=$(echo "$RELEASE_DATA" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
RELEASE_URL=$(echo "$RELEASE_DATA" | grep '"browser_download_url":.*\.tar\.gz"' | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')

log "Latest version: $LATEST_VERSION"

# Check if update is needed
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    log "Already running the latest version ($CURRENT_VERSION)"
    log "No update needed"
    log "========================================="
    exit 0
fi

log "Update available: $CURRENT_VERSION → $LATEST_VERSION"

# Stop services before update
log "Stopping WLAN services..."
systemctl stop wlan-network-monitor.service 2>/dev/null || true
systemctl stop wlan-webui.service 2>/dev/null || true
log "Services stopped"

# Create backup
log "Creating backup..."
if cp -r "$WLAN_INSTALL_DIR" "$BACKUP_DIR"; then
    log "Backup created at: $BACKUP_DIR"
else
    log_error "Failed to create backup"
    # Start services again
    systemctl start wlan-network-monitor.service 2>/dev/null || true
    systemctl start wlan-webui.service 2>/dev/null || true
    exit 1
fi

# Download new release
log "Downloading release $LATEST_VERSION..."
TEMP_DIR="/tmp/magicmirror-wlan-update-$$"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

if ! curl -L -o "$TEMP_DIR/release.tar.gz" "$RELEASE_URL" 2>/dev/null; then
    log_error "Failed to download release"
    rm -rf "$TEMP_DIR"
    # Start services again
    systemctl start wlan-network-monitor.service 2>/dev/null || true
    systemctl start wlan-webui.service 2>/dev/null || true
    exit 1
fi

log "Download complete, extracting..."

# Preserve config before extraction
TEMP_CONFIG_DIR="$TEMP_DIR/config-backup"
mkdir -p "$TEMP_CONFIG_DIR"
if [ -d "$WLAN_INSTALL_DIR/config" ]; then
    cp -r "$WLAN_INSTALL_DIR/config/"* "$TEMP_CONFIG_DIR/" 2>/dev/null || true
    log "Configuration backed up"
fi

# Remove old installation (except config)
log "Removing old files..."
find "$WLAN_INSTALL_DIR" -mindepth 1 -maxdepth 1 ! -name 'config' -exec rm -rf {} + 2>/dev/null || true

# Extract new release
log "Installing new version..."
if ! tar -xzf "$TEMP_DIR/release.tar.gz" -C "$WLAN_INSTALL_DIR" --strip-components=1 2>/dev/null; then
    log_error "Failed to extract release archive"
    log "Restoring from backup..."
    rm -rf "$WLAN_INSTALL_DIR"
    cp -r "$BACKUP_DIR" "$WLAN_INSTALL_DIR"
    rm -rf "$TEMP_DIR"
    # Start services again
    systemctl start wlan-network-monitor.service 2>/dev/null || true
    systemctl start wlan-webui.service 2>/dev/null || true
    exit 1
fi

# Restore config
if [ -d "$TEMP_CONFIG_DIR" ] && [ "$(ls -A $TEMP_CONFIG_DIR)" ]; then
    log "Restoring configuration..."
    cp -r "$TEMP_CONFIG_DIR/"* "$WLAN_INSTALL_DIR/config/" 2>/dev/null || true
fi

# Make scripts executable
chmod +x "$WLAN_INSTALL_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$WLAN_INSTALL_DIR/scripts/"*.py 2>/dev/null || true

# Update Python dependencies
log "Updating Python dependencies..."
cd "$WLAN_INSTALL_DIR/webui"
if [ -d "venv" ]; then
    # shellcheck disable=SC1091
    source venv/bin/activate
    pip install --quiet --upgrade pip
    pip install --quiet -r requirements.txt
    deactivate
    log "Python dependencies updated"
fi

# Update MagicMirror module
if [ -d "$WLAN_INSTALL_DIR/MMM-WLANManager" ] && [ -d "$MM_MODULES_DIR" ]; then
    log "Updating MagicMirror module..."
    rm -rf "$MM_MODULES_DIR/MMM-WLANManager"
    cp -r "$WLAN_INSTALL_DIR/MMM-WLANManager" "$MM_MODULES_DIR/"
    log "MagicMirror module updated"
fi

# Update version marker
echo "$LATEST_VERSION" > "$WLAN_INSTALL_DIR/.version"

# Cleanup
rm -rf "$TEMP_DIR"

# Clean up old backups (keep only the 3 most recent)
log "Cleaning up old backups..."
BACKUP_COUNT=$(find /opt -maxdepth 1 -type d -name "magicmirror-wlan-backup-*" 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 3 ]; then
    find /opt -maxdepth 1 -type d -name "magicmirror-wlan-backup-*" -printf '%T@ %p\n' 2>/dev/null | \
        sort -n | \
        head -n -3 | \
        cut -d' ' -f2- | \
        xargs rm -rf 2>/dev/null || true
    log "Old backups cleaned up"
fi

# Restart services with new version
log "Restarting WLAN services..."
systemctl daemon-reload
systemctl restart wlan-network-monitor.service || log_error "Failed to restart network monitor"
systemctl restart wlan-webui.service || log_error "Failed to restart WebUI"

log "========================================="
log "WLAN Manager update completed successfully"
log "Updated from $CURRENT_VERSION to $LATEST_VERSION"
log "========================================="

exit 0
