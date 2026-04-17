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
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root (use: sudo bash $0)"
    exit 1
fi

log "System will reboot now..."
log "========================================="

# Reboot immediately (using now or +0 for immediate reboot)
# Brief delay allows HTTP response to be sent back
shutdown -r now "System reboot requested via MagicMirror WebUI" &

echo "System reboot initiated"
exit 0
