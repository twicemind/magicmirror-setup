#!/bin/bash
# Ensure standard module configurations exist in config.js
# Only adds missing configurations, does not modify existing ones

set -e

CONFIG_FILE="/opt/mm/mounts/config/config.js"
BACKUP_FILE="/opt/mm/mounts/config/config.js.backup-$(date +%Y%m%d_%H%M%S)"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Checking module configurations in config.js..."

# Check if config.js exists
if [ ! -f "$CONFIG_FILE" ]; then
    log "ERROR: config.js not found at $CONFIG_FILE"
    exit 1
fi

# Backup config.js
cp "$CONFIG_FILE" "$BACKUP_FILE"
log "Backup created: $BACKUP_FILE"

# Create a temporary file for modifications
TMP_FILE=$(mktemp)
cp "$CONFIG_FILE" "$TMP_FILE"

MODIFIED=false

# Function to check if a module is already configured
module_exists() {
    local module_name="$1"
    grep -q "module:.*['\"]${module_name}['\"]" "$CONFIG_FILE"
}

# Function to add module config before the closing modules bracket
add_module_config() {
    local config_block="$1"
    
    # Find the last occurrence of closing bracket and brace for modules array
    # Insert the new module config before it
    awk -v config="$config_block" '
    /modules:[[:space:]]*\[/ { in_modules=1 }
    in_modules && /^[[:space:]]*\][[:space:]]*$/ {
        print config
        print $0
        in_modules=0
        next
    }
    { print }
    ' "$TMP_FILE" > "${TMP_FILE}.new"
    
    mv "${TMP_FILE}.new" "$TMP_FILE"
}

# Check and add MMM-PirateSkyForecast
if ! module_exists "MMM-PirateSkyForecast"; then
    log "Adding MMM-PirateSkyForecast configuration..."
    CONFIG_BLOCK='		{
			module: "MMM-PirateSkyForecast",
			position: "top_right",
			config: {
				apiKey: "YOUR_OPENWEATHERMAP_API_KEY",
				latitude: 52.5200,
				longitude: 13.4050,
				updateInterval: 600000, // 10 minutes
				showSummary: true,
				showDetails: true,
				showWind: true,
				showPrecipitation: true
			}
		},'
    add_module_config "$CONFIG_BLOCK"
    MODIFIED=true
fi

# Check and add MMM-SystemTemperature
if ! module_exists "MMM-SystemTemperature"; then
    log "Adding MMM-SystemTemperature configuration..."
    CONFIG_BLOCK='		{
			module: "MMM-SystemTemperature",
			position: "top_left",
			config: {
				updateInterval: 10000, // 10 seconds
				animationSpeed: 0,
				iconView: true,
				sendNotifications: true
			}
		},'
    add_module_config "$CONFIG_BLOCK"
    MODIFIED=true
fi

# Check and add MMM-Remote-Control
if ! module_exists "MMM-Remote-Control"; then
    log "Adding MMM-Remote-Control configuration..."
    CONFIG_BLOCK='		{
			module: "MMM-Remote-Control",
			config: {
				apiKey: "",
				customCommand: {},
				showAlert: true,
				customMenu: "custom_menu.json",
				apiKey: ""
			}
		},'
    add_module_config "$CONFIG_BLOCK"
    MODIFIED=true
fi

if [ "$MODIFIED" = true ]; then
    # Validate the modified file (basic check)
    if grep -q "modules:" "$TMP_FILE" && grep -q "}" "$TMP_FILE"; then
        mv "$TMP_FILE" "$CONFIG_FILE"
        log "✅ Module configurations updated successfully"
        log "Backup available at: $BACKUP_FILE"
        exit 0
    else
        log "❌ Modified config appears invalid, keeping original"
        rm "$TMP_FILE"
        exit 1
    fi
else
    log "✅ All standard module configurations already present"
    rm "$TMP_FILE"
    rm "$BACKUP_FILE"  # No changes, remove backup
    exit 0
fi
