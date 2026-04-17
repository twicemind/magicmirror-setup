#!/bin/bash

set -e

# MagicMirror Setup Installation Script
# Version: 1.0.0
# This script automates the setup of MagicMirror on Raspberry Pi with MagicMirrorOS

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "========================================="
    echo "ERROR: This script must be run as root"
    echo "========================================="
    echo ""
    echo "Please run with sudo:"
    echo "  curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/install.sh | sudo bash"
    echo ""
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/magicmirror-setup.log"
INSTALL_DIR="/opt/magicmirror-setup"
MM_MOUNTS="/opt/mm/mounts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if running on MagicMirrorOS
check_environment() {
    log "Checking environment..."
    
    if [ ! -d "/opt/mm" ]; then
        log_error "MagicMirror installation not found at /opt/mm"
        log_error "This script is designed for MagicMirrorOS"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    log "Environment check passed"
}

# Initial system update
initial_update() {
    log "Starting initial system update..."
    
    apt-get update
    apt-get upgrade -y
    apt-get install -y \
        git \
        curl \
        python3 \
        python3-pip \
        python3-venv \
        jq \
        psmisc \
        fbi
    
    log "Initial system update completed"
}

# Copy files to installation directory
install_files() {
    log "Installing files to $INSTALL_DIR..."
    
    mkdir -p "$INSTALL_DIR"
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR"/scripts/*.sh 2>/dev/null || true
    
    log "Files installed"
}

# Install systemd services
install_services() {
    log "Installing systemd services..."
    
    # Install service files
    cp "$INSTALL_DIR/services/"*.service /etc/systemd/system/ 2>/dev/null || true
    cp "$INSTALL_DIR/services/"*.timer /etc/systemd/system/ 2>/dev/null || true
    
    # Reload systemd
    systemctl daemon-reload
    
    # Enable timers
    systemctl enable mm-os-update.timer || true
    systemctl enable mm-docker-update.timer || true
    systemctl enable mm-modules-update.timer || true
    systemctl enable mm-setup-update.timer || true
    
    # Start timers
    systemctl start mm-os-update.timer || true
    systemctl start mm-docker-update.timer || true
    systemctl start mm-modules-update.timer || true
    systemctl start mm-setup-update.timer || true
    
    log "Systemd services installed and enabled"
}

# Setup WebUI
setup_webui() {
    log "Setting up WebUI..."
    
    cd "$INSTALL_DIR/webui"
    
    # Create virtual environment
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    
    # Install dependencies
    pip install --upgrade pip
    pip install -r requirements.txt
    
    deactivate
    
    # Install and enable WebUI service
    cp "$INSTALL_DIR/services/mm-webui.service" /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable mm-webui.service
    systemctl start mm-webui.service
    
    log "WebUI installed and started on port 8080"
}

# Setup initial configuration
setup_initial_config() {
    log "Setting up initial configuration..."
    
    # Create config directories if they don't exist
    mkdir -p "$MM_MOUNTS/config"
    mkdir -p "$MM_MOUNTS/modules"
    
    # Copy initial config if provided
    if [ -f "$INSTALL_DIR/initial-config/config.json" ]; then
        cp "$INSTALL_DIR/initial-config/config.json" "$MM_MOUNTS/config/"
        log "Initial config.json installed"
    fi
    
    if [ -f "$INSTALL_DIR/initial-config/custom.css" ]; then
        cp "$INSTALL_DIR/initial-config/custom.css" "$MM_MOUNTS/config/"
        log "Initial custom.css installed"
    fi
    
    # Install initial modules
    if [ -d "$INSTALL_DIR/initial-modules" ] && [ "$(ls -A $INSTALL_DIR/initial-modules)" ]; then
        log "Installing initial modules..."
        for module_file in "$INSTALL_DIR/initial-modules"/*.sh; do
            if [ -f "$module_file" ]; then
                bash "$module_file"
            fi
        done
    fi
}

# Setup boot splash screen
setup_splash_screen() {
    log "Setting up boot splash screen..."
    
    if [ -f "$INSTALL_DIR/assets/splash.png" ]; then
        mkdir -p /opt/splash
        cp "$INSTALL_DIR/assets/splash.png" /opt/splash/
        
        # Install splash service
        cp "$INSTALL_DIR/services/mm-splash.service" /etc/systemd/system/ 2>/dev/null || true
        systemctl daemon-reload
        systemctl enable mm-splash.service || true
        
        log "Splash screen configured"
    else
        log_warning "Splash screen image not found, skipping"
    fi
}

# Display installation summary
show_summary() {
    echo ""
    echo "======================================"
    echo "  MagicMirror Setup Installation Complete"
    echo "======================================"
    echo ""
    echo "✅ System updated"
    echo "✅ Automatic update services installed:"
    echo "   - OS updates (daily at 02:00)"
    echo "   - Docker container updates (daily at 02:00)"
    echo "   - Module updates (daily at 02:00)"
    echo "   - Setup self-updates (daily at 02:00)"
    echo ""
    echo "✅ WebUI installed and running"
    echo "   Access at: http://$(hostname -I | awk '{print $1}'):8080"
    echo "   Dashboard displays: $(hostname)"
    echo ""
    echo "📝 Configuration location: $MM_MOUNTS/config/"
    echo "📦 Modules location: $MM_MOUNTS/modules/"
    echo ""
    echo "🔧 Useful commands:"
    echo "   systemctl status mm-webui.service   - Check WebUI status"
    echo "   systemctl list-timers               - View scheduled updates"
    echo "   docker exec -it mm bash             - Enter MagicMirror container"
    echo ""
    echo "📖 For more information, see: $INSTALL_DIR/README.md"
    echo ""
}

# Main installation flow
main() {
    log "========================================="
    log "MagicMirror Setup Installation Starting"
    log "========================================="
    
    check_root
    check_environment
    initial_update
    install_files
    install_services
    setup_webui
    setup_initial_config
    setup_splash_screen
    
    show_summary
    
    log "Installation completed successfully!"
    log "========================================="
}

# Run main function
main "$@"
