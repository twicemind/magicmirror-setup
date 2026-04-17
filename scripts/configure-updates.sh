#!/bin/bash

# Update Settings Configuration Script
# Configures automatic update timers

set -e

LOG_FILE="/var/log/magicmirror-setup.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# Parse arguments
UPDATE_TYPE=""
ENABLED=""
SCHEDULE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            UPDATE_TYPE="$2"
            shift 2
            ;;
        --enabled)
            ENABLED="$2"
            shift 2
            ;;
        --schedule)
            SCHEDULE="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$UPDATE_TYPE" ]; then
    log_error "Update type is required (--type)"
    exit 1
fi

# Map update type to timer name
case "$UPDATE_TYPE" in
    "os")
        TIMER_NAME="mm-os-update.timer"
        ;;
    "docker")
        TIMER_NAME="mm-docker-update.timer"
        ;;
    "modules")
        TIMER_NAME="mm-modules-update.timer"
        ;;
    "setup")
        TIMER_NAME="mm-setup-update.timer"
        ;;
    *)
        log_error "Invalid update type: $UPDATE_TYPE"
        exit 1
        ;;
esac

log "========================================="
log "Configuring $UPDATE_TYPE updates"
log "========================================="

# Update schedule if provided
if [ -n "$SCHEDULE" ]; then
    log "Updating schedule to: $SCHEDULE"
    
    TIMER_FILE="/etc/systemd/system/$TIMER_NAME"
    
    if [ ! -f "$TIMER_FILE" ]; then
        log_error "Timer file not found: $TIMER_FILE"
        exit 1
    fi
    
    # Update the OnCalendar line
    sed -i "s/OnCalendar=.*/OnCalendar=*-*-* $SCHEDULE/" "$TIMER_FILE"
    
    # Reload systemd
    systemctl daemon-reload
    
    log "Schedule updated successfully"
fi

# Enable or disable timer
if [ -n "$ENABLED" ]; then
    if [ "$ENABLED" = "true" ]; then
        log "Enabling $TIMER_NAME..."
        systemctl enable "$TIMER_NAME"
        systemctl start "$TIMER_NAME"
        log "Timer enabled and started"
    else
        log "Disabling $TIMER_NAME..."
        systemctl stop "$TIMER_NAME"
        systemctl disable "$TIMER_NAME"
        log "Timer stopped and disabled"
    fi
fi

log "Configuration completed successfully"
log "========================================="

exit 0
