#!/bin/bash

# Check for Setup Updates
# Returns version information and update availability

set -e

INSTALL_DIR="/opt/magicmirror-setup"
REPO_URL="https://api.github.com/repos/twicemind/magicmirror-setup/releases/latest"

# Get current version
CURRENT_VERSION="unknown"
if [ -f "$INSTALL_DIR/VERSION" ]; then
    CURRENT_VERSION=$(cat "$INSTALL_DIR/VERSION")
fi

# Get latest version from GitHub
LATEST_VERSION=$(curl -s "$REPO_URL" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/' || echo "unknown")

# Output JSON
cat <<EOF
{
  "current_version": "$CURRENT_VERSION",
  "latest_version": "$LATEST_VERSION",
  "update_available": $([ "$CURRENT_VERSION" != "$LATEST_VERSION" ] && echo "true" || echo "false")
}
EOF
