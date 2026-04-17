#!/bin/bash

# Check for MagicMirror WLAN Manager updates
# Returns JSON with update status

WLAN_INSTALL_DIR="/opt/magicmirror-wlan"
GITHUB_REPO="twicemind/magicmirror-wlan"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"

# Check if WLAN manager is installed
if [ ! -d "$WLAN_INSTALL_DIR" ]; then
    echo '{"installed": false, "update_available": false, "message": "WLAN Manager not installed"}'
    exit 0
fi

# Get current version
CURRENT_VERSION="unknown"
if [ -f "$WLAN_INSTALL_DIR/.version" ]; then
    CURRENT_VERSION=$(cat "$WLAN_INSTALL_DIR/.version")
fi

# Fetch latest release
if ! RELEASE_DATA=$(curl -s "$GITHUB_API" 2>/dev/null); then
    echo "{\"installed\": true, \"current_version\": \"$CURRENT_VERSION\", \"update_available\": false, \"message\": \"Failed to check for updates\"}"
    exit 0
fi

if ! echo "$RELEASE_DATA" | grep -q "tag_name"; then
    echo "{\"installed\": true, \"current_version\": \"$CURRENT_VERSION\", \"update_available\": false, \"message\": \"No releases found\"}"
    exit 0
fi

LATEST_VERSION=$(echo "$RELEASE_DATA" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

# Compare versions
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "{\"installed\": true, \"current_version\": \"$CURRENT_VERSION\", \"latest_version\": \"$LATEST_VERSION\", \"update_available\": false}"
else
    echo "{\"installed\": true, \"current_version\": \"$CURRENT_VERSION\", \"latest_version\": \"$LATEST_VERSION\", \"update_available\": true}"
fi

exit 0
