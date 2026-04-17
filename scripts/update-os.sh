#!/bin/bash

# MagicMirror OS Update Script
# Performs system updates and automatic reboot if needed

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
REBOOT_REQUIRED="/var/run/reboot-required"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Starting OS update process"
log "========================================="

# Update package lists
log "Updating package lists..."
apt-get update

# Upgrade packages
log "Upgrading packages..."
apt-get upgrade -y

# Dist upgrade (for kernel and other critical updates)
log "Performing distribution upgrade..."
apt-get dist-upgrade -y

# Clean up
log "Cleaning up..."
apt-get autoremove -y
apt-get autoclean

log "OS update completed successfully"

# Check if reboot is required
if [ -f "$REBOOT_REQUIRED" ]; then
    log "Reboot required. Scheduling reboot in 1 minute..."
    shutdown -r +1 "System reboot required after updates. Rebooting in 1 minute..."
else
    log "No reboot required"
fi

log "========================================="
