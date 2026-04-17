#!/bin/bash

# Configure GPIO fan settings in /boot/firmware/config.txt or /boot/config.txt
# Usage: configure-fan.sh --enabled true --gpio 14 --temp-start 60

set -e

CONFIG_FILE="/boot/firmware/config.txt"
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="/boot/config.txt"
fi

# Parse arguments
ENABLED=""
GPIO_PIN=""
TEMP_START=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --enabled)
            ENABLED="$2"
            shift 2
            ;;
        --gpio)
            GPIO_PIN="$2"
            shift 2
            ;;
        --temp-start)
            TEMP_START="$2"
            shift 2
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$ENABLED" ]; then
    echo "Error: --enabled parameter is required (true/false)"
    exit 1
fi

# Remove existing gpio-fan configuration
sudo sed -i '/^dtoverlay=gpio-fan/d' "$CONFIG_FILE"

if [ "$ENABLED" = "true" ]; then
    # Set defaults if not provided
    GPIO_PIN=${GPIO_PIN:-4}
    TEMP_START=${TEMP_START:-60}
    
    # Convert temperature to millidegrees
    TEMP_MILLIDEG=$((TEMP_START * 1000))
    
    # Add new configuration at the end
    echo "dtoverlay=gpio-fan,gpiopin=$GPIO_PIN,temp=$TEMP_MILLIDEG" | sudo tee -a "$CONFIG_FILE" > /dev/null
    
    echo "Fan enabled: GPIO$GPIO_PIN, starts at ${TEMP_START}°C"
    echo "Note: Reboot required for changes to take effect"
else
    echo "Fan disabled"
    echo "Note: Reboot required for changes to take effect"
fi

exit 0
