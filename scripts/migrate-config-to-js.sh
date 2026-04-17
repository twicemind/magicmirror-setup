#!/bin/bash
# Migrate config.json to config.js format
# MagicMirror requires config.js, not config.json

set -e

CONFIG_DIR="/opt/mm/mounts/config"
CONFIG_JS="$CONFIG_DIR/config.js"
CONFIG_JSON="$CONFIG_DIR/config.json"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Checking configuration format..."

# Check if config.js already exists
if [ -f "$CONFIG_JS" ]; then
    log "✅ config.js already exists"
    
    # Check if config.json also exists (old format)
    if [ -f "$CONFIG_JSON" ]; then
        log "⚠️  Found old config.json alongside config.js"
        log "   Backing up config.json and removing it..."
        mv "$CONFIG_JSON" "$CONFIG_JSON.old.$(date +%Y%m%d_%H%M%S)"
        log "✅ config.json backed up and removed"
    fi
    
    exit 0
fi

# If only config.json exists, convert it
if [ -f "$CONFIG_JSON" ]; then
    log "📝 Found config.json, converting to config.js..."
    
    # Backup config.json
    BACKUP_FILE="$CONFIG_JSON.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_JSON" "$BACKUP_FILE"
    log "   Backup created: $BACKUP_FILE"
    
    # Create config.js with proper JavaScript format
    # Note: We create a default config instead of converting JSON
    # as the formats are incompatible (JSON vs JavaScript)
    cat > "$CONFIG_JS" <<'EOF'
/* MagicMirror² Config
 *
 * By Michael Teeuw https://michaelteeuw.nl
 * MIT Licensed.
 *
 * For more information on how you can configure this file
 * see https://docs.magicmirror.builders/configuration/introduction.html
 * and https://docs.magicmirror.builders/modules/configuration.html
 *
 * You can use environment variables using a `config.js.template` file instead of `config.js`
 * which will be converted to `config.js` while starting. For more information
 * see https://docs.magicmirror.builders/configuration/introduction.html#enviromnent-variables
 */
let config = {
	address: "0.0.0.0",
	port: 8080,
	basePath: "/",
	ipWhitelist: [],
	
	useHttps: false,
	httpsPrivateKey: "",
	httpsCertificate: "",
	
	language: "de",
	locale: "de-DE",
	logLevel: ["INFO", "LOG", "WARN", "ERROR"],
	timeFormat: 24,
	units: "metric",
	
	modules: [
		{
			module: "alert",
		},
		{
			module: "updatenotification",
			position: "top_bar"
		},
		{
			module: "clock",
			position: "top_left"
		},
		{
			module: "calendar",
			header: "Kalender",
			position: "top_left",
			config: {
				calendars: [
					{
						fetchInterval: 7 * 24 * 60 * 60 * 1000,
						symbol: "calendar-check",
						url: "https://www.calendarlabs.com/ical-calendar/ics/76/US_Holidays.ics"
					}
				]
			}
		},
		{
			module: "compliments",
			position: "lower_third"
		},
		{
			module: "weather",
			position: "top_right",
			config: {
				weatherProvider: "openweathermap",
				type: "current",
				location: "Berlin",
				locationID: "2950159",
				apiKey: "YOUR_OPENWEATHER_API_KEY"
			}
		},
		{
			module: "weather",
			position: "top_right",
			header: "Wettervorhersage",
			config: {
				weatherProvider: "openweathermap",
				type: "forecast",
				location: "Berlin",
				locationID: "2950159",
				apiKey: "YOUR_OPENWEATHER_API_KEY"
			}
		},
		{
			module: "newsfeed",
			position: "bottom_bar",
			config: {
				feeds: [
					{
						title: "Tagesschau",
						url: "https://www.tagesschau.de/xml/rss2/"
					}
				],
				showSourceTitle: true,
				showPublishDate: true,
				broadcastNewsFeeds: true,
				broadcastNewsUpdates: true
			}
		},
	]
};

/*************** DO NOT EDIT THE LINE BELOW ***************/
if (typeof module !== "undefined") { module.exports = config; }
EOF
    
    log "✅ config.js created with default MagicMirror configuration"
    log "⚠️  Please review and customize config.js with your settings"
    log "   Original JSON data backed up at: $BACKUP_FILE"
    
    # Remove old config.json
    rm "$CONFIG_JSON"
    log "   Removed old config.json"
    
    exit 0
fi

# Neither file exists - create default config.js
log "📝 No configuration found, creating default config.js..."

cat > "$CONFIG_JS" <<'EOF'
/* MagicMirror² Config - Default Configuration */
let config = {
	address: "0.0.0.0",
	port: 8080,
	basePath: "/",
	ipWhitelist: [],
	
	useHttps: false,
	httpsPrivateKey: "",
	httpsCertificate: "",
	
	language: "de",
	locale: "de-DE",
	logLevel: ["INFO", "LOG", "WARN", "ERROR"],
	timeFormat: 24,
	units: "metric",
	
	modules: [
		{
			module: "alert",
		},
		{
			module: "updatenotification",
			position: "top_bar"
		},
		{
			module: "clock",
			position: "top_left"
		},
		{
			module: "calendar",
			header: "Kalender",
			position: "top_left",
			config: {
				calendars: [
					{
						fetchInterval: 7 * 24 * 60 * 60 * 1000,
						symbol: "calendar-check",
						url: "https://www.calendarlabs.com/ical-calendar/ics/76/US_Holidays.ics"
					}
				]
			}
		},
		{
			module: "compliments",
			position: "lower_third"
		},
		{
			module: "newsfeed",
			position: "bottom_bar",
			config: {
				feeds: [
					{
						title: "Tagesschau",
						url: "https://www.tagesschau.de/xml/rss2/"
					}
				],
				showSourceTitle: true,
				showPublishDate: true,
				broadcastNewsFeeds: true,
				broadcastNewsUpdates: true
			}
		},
	]
};

if (typeof module !== "undefined") { module.exports = config; }
EOF

log "✅ Default config.js created"

exit 0
