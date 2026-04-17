#!/bin/bash

# Get systemd services and timers status
# Returns JSON output

# Services to monitor
SERVICES=(
    "mm-webui.service"
    "mm-splash.service"
    "docker.service"
)

# Timers to monitor  
TIMERS=(
    "mm-os-update.timer"
    "mm-docker-update.timer"
    "mm-modules-update.timer"
    "mm-setup-update.timer"
)

# Start JSON output
echo "{"
echo '  "services": {'

# Check services
first=true
for service in "${SERVICES[@]}"; do
    if [ "$first" = false ]; then
        echo ","
    fi
    first=false
    
    # Get service status
    if systemctl is-active --quiet "$service"; then
        state="active"
    elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
        state="inactive"
    else
        state="disabled"
    fi
    
    echo -n "    \"$service\": \"$state\""
done

echo ""
echo "  },"
echo '  "timers": {'

# Check timers
first=true
for timer in "${TIMERS[@]}"; do
    if [ "$first" = false ]; then
        echo ","
    fi
    first=false
    
    # Get  timer status and next run time
    if systemctl is-active --quiet "$timer"; then
        state="active"
        # Get next run time
        next_run=$(systemctl status "$timer" 2>/dev/null | grep "Trigger:" | sed 's/.*Trigger: //' | head -1)
        if [ -z "$next_run" ]; then
            next_run="unknown"
        fi
    else
        state="inactive"
        next_run="n/a"
    fi
    
    echo -n "    \"$timer\": {\"state\": \"$state\", \"next_run\": \"$next_run\"}"
done

echo ""
echo "  }"
echo "}"
