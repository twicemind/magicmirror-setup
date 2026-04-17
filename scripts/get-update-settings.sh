#!/bin/bash

# Get Update Settings
# Returns current update configuration as JSON

set -e

# Get timer status and configuration
get_timer_config() {
    local timer_name=$1
    local enabled="false"
    local schedule="02:00:00"
    
    # Check if timer is enabled
    if systemctl is-enabled "${timer_name}" &>/dev/null; then
        enabled="true"
    fi
    
    # Get schedule from timer file
    if [ -f "/etc/systemd/system/${timer_name}" ]; then
        schedule=$(grep "OnCalendar=" "/etc/systemd/system/${timer_name}" | sed 's/OnCalendar=\*-\*-\* //' || echo "02:00:00")
    fi
    
    echo "{\"enabled\": $enabled, \"schedule\": \"$schedule\"}"
}

# Build JSON response
cat <<EOF
{
  "os_updates": $(get_timer_config "mm-os-update.timer"),
  "docker_updates": $(get_timer_config "mm-docker-update.timer"),
  "module_updates": $(get_timer_config "mm-modules-update.timer"),
  "setup_updates": $(get_timer_config "mm-setup-update.timer")
}
EOF
