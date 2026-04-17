#!/bin/bash

# Get current fan configuration from /boot/firmware/config.txt or /boot/config.txt
# Returns JSON with current settings

CONFIG_FILE="/boot/firmware/config.txt"
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="/boot/config.txt"
fi

# Default values
ENABLED="false"
GPIO_PIN="4"
TEMP_START="60"
TEMP_STOP="50"

# Check if gpio-fan overlay is configured
if [ -f "$CONFIG_FILE" ]; then
    FAN_LINE=$(grep "^dtoverlay=gpio-fan" "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ -n "$FAN_LINE" ]; then
        ENABLED="true"
        
        # Extract GPIO pin
        if echo "$FAN_LINE" | grep -q "gpiopin="; then
            GPIO_PIN=$(echo "$FAN_LINE" | sed -n 's/.*gpiopin=\([0-9]*\).*/\1/p')
        fi
        
        # Extract temperature (in millidegrees, convert to degrees)
        if echo "$FAN_LINE" | grep -q "temp="; then
            TEMP_MILLIDEG=$(echo "$FAN_LINE" | sed -n 's/.*temp=\([0-9]*\).*/\1/p')
            TEMP_START=$((TEMP_MILLIDEG / 1000))
        fi
    fi
fi

# Output JSON
cat <<EOF
{
    "success": true,
    "settings": {
        "enabled": $ENABLED,
        "gpio_pin": "$GPIO_PIN",
        "temp_start": "$TEMP_START",
        "temp_stop": "$TEMP_STOP"
    }
}
EOF
