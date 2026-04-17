#!/bin/bash
# Install MagicMirror WLAN Manager
# Automatic WiFi management with HotSpot fallback and web configuration
#
# This script is automatically run during magicmirror-setup installation
# It can also be run manually: sudo bash initial-modules/install-magicmirror-wlan.sh

set -e

# Configuration
WLAN_INSTALL_DIR="/opt/magicmirror-wlan"
WLAN_LOG_FILE="/var/log/magicmirror-wlan.log"
GITHUB_REPO="twicemind/magicmirror-wlan"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
MM_MODULES_DIR="/opt/mm/mounts/modules"
CONTAINER_NAME="mm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$WLAN_LOG_FILE" 2>/dev/null || true
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$WLAN_LOG_FILE" 2>/dev/null || true
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1" >> "$WLAN_LOG_FILE" 2>/dev/null || true
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$WLAN_LOG_FILE" 2>/dev/null || true
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

echo ""
echo "========================================="
echo "  Installing MagicMirror WLAN Manager"
echo "========================================="
echo ""

# Create log file
touch "$WLAN_LOG_FILE"
chmod 644 "$WLAN_LOG_FILE"

log "Starting MagicMirror WLAN Manager installation..."

# Check if already installed
if [ -f "$WLAN_INSTALL_DIR/.installed" ]; then
    log_info "MagicMirror WLAN Manager is already installed"
    log_info "To reinstall, first run: sudo bash $WLAN_INSTALL_DIR/uninstall.sh"
    echo ""
    echo "   ℹ️  Already installed, skipping"
    exit 0
fi

# Install required packages
log "Installing required packages..."
apt-get update -qq
apt-get install -y -qq \
    hostapd \
    dnsmasq \
    iptables \
    python3 \
    python3-pip \
    python3-venv \
    wireless-tools \
    iw \
    curl \
    jq \
    > /dev/null 2>&1

log "✓ Required packages installed"

# Download latest release
log "Downloading latest release from GitHub..."

TEMP_DIR="/tmp/magicmirror-wlan-install-$$"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

if RELEASE_DATA=$(curl -s "$GITHUB_API" 2>/dev/null) && echo "$RELEASE_DATA" | grep -q "tag_name"; then
    RELEASE_TAG=$(echo "$RELEASE_DATA" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
    RELEASE_URL=$(echo "$RELEASE_DATA" | grep '"browser_download_url":.*\.tar\.gz"' | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')
    
    if [ -n "$RELEASE_URL" ]; then
        log "Downloading release $RELEASE_TAG..."
        if curl -L -o "$TEMP_DIR/release.tar.gz" "$RELEASE_URL" 2>/dev/null; then
            log "Extracting release archive..."
            mkdir -p "$WLAN_INSTALL_DIR"
            tar -xzf "$TEMP_DIR/release.tar.gz" -C "$WLAN_INSTALL_DIR" --strip-components=1 2>/dev/null
            log "✓ Using release $RELEASE_TAG"
        else
            log_error "Failed to download release"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        log_error "Could not find release download URL"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
else
    log_error "Could not fetch latest release information"
    rm -rf "$TEMP_DIR"
    exit 1
fi

rm -rf "$TEMP_DIR"

# Make scripts executable
chmod +x "$WLAN_INSTALL_DIR/install.sh" 2>/dev/null || true
chmod +x "$WLAN_INSTALL_DIR/uninstall.sh" 2>/dev/null || true
chmod +x "$WLAN_INSTALL_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$WLAN_INSTALL_DIR/scripts/"*.py 2>/dev/null || true

# Setup Python environment for WebUI
log "Setting up Python environment..."
cd "$WLAN_INSTALL_DIR/webui"
python3 -m venv venv
# shellcheck disable=SC1091
source venv/bin/activate
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt
deactivate
log "✓ Python environment ready"

# Install systemd services
log "Installing systemd services..."
cp "$WLAN_INSTALL_DIR/services/"*.service /etc/systemd/system/ 2>/dev/null || true
cp "$WLAN_INSTALL_DIR/services/"*.timer /etc/systemd/system/ 2>/dev/null || true

systemctl daemon-reload

# Enable and start network monitor
systemctl enable wlan-network-monitor.service || true
systemctl start wlan-network-monitor.service || true
log "✓ Network monitor service enabled"

# Enable WebUI
systemctl enable wlan-webui.service || true
systemctl start wlan-webui.service || true
log "✓ WebUI service enabled"

# Install MagicMirror module
log "Installing MagicMirror module..."

# Check if MagicMirror container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_warning "MagicMirror container is not running"
    log_warning "Module will be installed but may need manual configuration"
else
    # Copy module to MagicMirror modules directory
    if [ -d "$WLAN_INSTALL_DIR/MMM-WLANManager" ]; then
        cp -r "$WLAN_INSTALL_DIR/MMM-WLANManager" "$MM_MODULES_DIR/"
        log "✓ MagicMirror module installed to $MM_MODULES_DIR/MMM-WLANManager"
        
        # Check if module has dependencies
        if [ -f "$MM_MODULES_DIR/MMM-WLANManager/package.json" ]; then
            log "Installing module dependencies..."
            if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules/MMM-WLANManager && npm install --production" 2>&1 | grep -v "npm WARN"; then
                log "✓ Module dependencies installed"
            else
                log_warning "npm install had some warnings, but module should work"
            fi
        fi
    else
        log_warning "MMM-WLANManager module directory not found in release"
    fi
fi

# Create installation marker
touch "$WLAN_INSTALL_DIR/.installed"
echo "$RELEASE_TAG" > "$WLAN_INSTALL_DIR/.version"

# Configure sudoers for wlan scripts
if [ ! -f /etc/sudoers.d/mm-magicmirror-wlan ]; then
    cat > /etc/sudoers.d/mm-magicmirror-wlan <<EOF
# Allow user mm to run WLAN management scripts without password
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-wlan/scripts/start-hotspot.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-wlan/scripts/stop-hotspot.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-wlan/scripts/configure-wlan.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-wlan/scripts/network-monitor.py
mm ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart wlan-network-monitor.service
mm ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart wlan-webui.service
EOF
    chmod 440 /etc/sudoers.d/mm-magicmirror-wlan
    log "✓ Sudoers rules configured"
fi

echo ""
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo ""
echo "✅ MagicMirror WLAN Manager installed ($RELEASE_TAG)"
echo "✅ Network monitor service running"
echo "✅ WebUI accessible at: http://$(hostname -I | awk '{print $1}'):8765"
echo "✅ MagicMirror module: MMM-WLANManager"
echo ""
echo "📝 Configuration:"
echo "   - Config file: $WLAN_INSTALL_DIR/config/network-config.json"
echo "   - HotSpot SSID: MagicMirror-Setup (default)"
echo "   - HotSpot Password: magicmirror (default)"
echo ""
echo "🔧 Next steps:"
echo "   1. Add MMM-WLANManager to your MagicMirror config.js"
echo "   2. Configure WiFi via WebUI at port 8765"
echo "   3. Customize HotSpot settings if needed"
echo ""
echo "📖 Documentation: https://github.com/twicemind/magicmirror-wlan"
echo ""

log "MagicMirror WLAN Manager installation complete"

exit 0
