#!/bin/bash

# Reboot System Script
# Safely reboots the Raspberry Pi

set -e

LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "System reboot requested via WebUI"
log "========================================="

# Check if we're running as root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

log "System will reboot in 5 seconds..."
log "========================================="

# Schedule reboot in 5 seconds to allow HTTP response to be sent
shutdown -r +0.1 "System reboot requested via MagicMirror WebUI"

echo "System reboot initiated"
exit 0
