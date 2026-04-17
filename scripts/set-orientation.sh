#!/bin/bash

# Set display orientation (portrait or landscape)
# Usage: ./set-orientation.sh <landscape|portrait|inverted-landscape|inverted-portrait>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <landscape|portrait|inverted-landscape|inverted-portrait>"
    exit 1
fi

ORIENTATION="$1"
CONFIG_FILE="/boot/config.txt"
LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# Map orientation to rotation value
case "$ORIENTATION" in
    landscape)
        ROTATION=0
        ;;
    portrait)
        ROTATION=1
        ;;
    inverted-landscape)
        ROTATION=2
        ;;
    inverted-portrait)
        ROTATION=3
        ;;
    *)
        log_error "Invalid orientation: $ORIENTATION"
        exit 1
        ;;
esac

log "Setting display orientation to: $ORIENTATION (rotation=$ROTATION)"

# Backup config file
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"

# Remove existing display_rotate setting
sed -i '/display_rotate/d' "$CONFIG_FILE"

# Add new display_rotate setting
echo "display_rotate=$ROTATION" >> "$CONFIG_FILE"

log "Display orientation updated"
log "A reboot is required for changes to take effect"

# Ask for reboot
read -p "Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Rebooting system..."
    reboot
fi
