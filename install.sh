#!/bin/bash

# Ensure script runs with bash (not sh/dash)
if [ -z "$BASH_VERSION" ]; then
    # Re-execute with bash
    exec bash "$0" "$@"
    exit 1
fi

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

# Ensure required tools are installed
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update
    apt-get install -y git curl
elif ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    apt-get update
    apt-get install -y curl
fi

# Determine script directory or download from GitHub
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ] || [ "${BASH_SOURCE[0]}" = "/dev/stdin" ]; then
    # Script is being piped from curl, need to download files
    GITHUB_REPO="twicemind/magicmirror-setup"
    GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
    TEMP_DIR="/tmp/magicmirror-setup-install"
    
    echo "========================================="
    echo "Downloading MagicMirror Setup..."
    echo "========================================="
    
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Try to get latest release
    echo "Checking for latest release..."
    if RELEASE_DATA=$(curl -s "$GITHUB_API" 2>/dev/null) && echo "$RELEASE_DATA" | grep -q "tag_name"; then
        RELEASE_TAG=$(echo "$RELEASE_DATA" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')
        RELEASE_URL=$(echo "$RELEASE_DATA" | grep '"browser_download_url":.*\.tar\.gz"' | sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')
        
        if [ -n "$RELEASE_URL" ]; then
            echo "Downloading release $RELEASE_TAG..."
            if curl -L -o "$TEMP_DIR/release.tar.gz" "$RELEASE_URL" 2>/dev/null; then
                echo "Extracting release archive..."
                tar -xzf "$TEMP_DIR/release.tar.gz" -C "$TEMP_DIR" --strip-components=1 2>/dev/null || {
                    # Fallback: try without strip-components
                    tar -xzf "$TEMP_DIR/release.tar.gz" -C "$TEMP_DIR" 2>/dev/null
                }
                rm -f "$TEMP_DIR/release.tar.gz"
                SCRIPT_DIR="$TEMP_DIR"
                echo "✓ Using release $RELEASE_TAG"
            else
                echo "Failed to download release, falling back to git clone..."
                RELEASE_URL=""
            fi
        fi
    fi
    
    # Fallback to git clone if release download failed
    if [ -z "$RELEASE_URL" ] || [ ! -d "$SCRIPT_DIR" ]; then
        echo "Cloning repository (fallback)..."
        git clone --depth 1 "https://github.com/$GITHUB_REPO.git" "$TEMP_DIR" || {
            echo "ERROR: Failed to download MagicMirror Setup"
            exit 1
        }
        SCRIPT_DIR="$TEMP_DIR"
        echo "✓ Using latest main branch"
    fi
    
    echo "========================================="
else
    # Script is running locally
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

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
    
    # Add Git safe.directory to prevent ownership warnings
    git config --global --add safe.directory /opt/mm 2>/dev/null || true
    git config --global --add safe.directory /opt/mm/magicmirror-setup 2>/dev/null || true
    
    log "Environment check passed"
}

# Initialize MagicMirror if not already done
initialize_magicmirror() {
    local marker_file="/opt/mm/.magicmirror-initialized"
    
    # Check if MagicMirror was already initialized
    if [ -f "$marker_file" ]; then
        log "MagicMirror already initialized (found marker file)"
        return 0
    fi
    
    # Check if install script exists
    if [ ! -f "/opt/mm/install/install.sh" ]; then
        log_warning "MagicMirror install script not found at /opt/mm/install/install.sh"
        log_warning "Skipping automatic MagicMirror initialization"
        return 0
    fi
    
    log "========================================="
    log "Initializing MagicMirror with Electron"
    log "========================================="
    log "This will install MagicMirror Docker container and Electron."
    log "This may take 5-10 minutes..."
    
    # Fix Git ownership issue that occurs when running with sudo
    if [ -d "/opt/mm/.git" ]; then
        log "Configuring Git safe directory for /opt/mm..."
        git config --global --add safe.directory /opt/mm || true
    fi
    
    # Run MagicMirror installation
    cd /opt/mm/install || exit 1
    if bash install.sh electron; then
        # Create marker file to prevent re-initialization
        touch "$marker_file"
        log "✓ MagicMirror initialized successfully"
        
        # Start container with docker compose (install.sh might not leave it running)
        cd /opt/mm/run || exit 1
        log "Starting MagicMirror container..."
        if docker compose up -d 2>&1 | tee -a "$LOG_FILE"; then
            log "✓ Container started successfully"
        else
            log_warning "Failed to start container - you may need to start it manually"
        fi
    else
        log_error "MagicMirror initialization failed"
        log_error "You may need to run manually: cd /opt/mm/install && sudo bash install.sh electron"
        # Don't exit, continue with rest of setup
    fi
    
    cd - > /dev/null || exit 1
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

# Setup installation directory with git repository
install_files() {
    log "Setting up installation directory: $INSTALL_DIR..."
    
    local REPO_URL="https://github.com/twicemind/magicmirror-setup.git"
    
    # Configure git safe.directory for this repo
    git config --global --add safe.directory "$INSTALL_DIR" 2>/dev/null || true
    
    if [ -d "$INSTALL_DIR/.git" ]; then
        # Already a git repository, just pull latest changes
        log "Git repository exists, pulling latest changes..."
        cd "$INSTALL_DIR" || exit 1
        
        # Stash any local changes
        git stash || true
        
        # Pull latest changes
        if git pull origin main; then
            log "Successfully updated to latest version"
        else
            log_warning "Git pull failed, but continuing..."
        fi
        
        cd - > /dev/null || exit 1
        
    elif [ -d "$INSTALL_DIR" ] && [ "$(ls -A $INSTALL_DIR)" ]; then
        # Directory exists but is not a git repo - backup and clone
        log_warning "Directory exists but is not a git repository"
        local BACKUP_DIR
        BACKUP_DIR="/opt/magicmirror-setup-backup-$(date +%Y%m%d_%H%M%S)"
        log "Creating backup: $BACKUP_DIR"
        mv "$INSTALL_DIR" "$BACKUP_DIR"
        
        log "Cloning repository to $INSTALL_DIR..."
        if git clone "$REPO_URL" "$INSTALL_DIR"; then
            log "Repository cloned successfully"
        else
            log_error "Failed to clone repository, restoring backup"
            mv "$BACKUP_DIR" "$INSTALL_DIR"
            exit 1
        fi
        
    else
        # Directory doesn't exist or is empty - clone directly
        log "Cloning repository to $INSTALL_DIR..."
        mkdir -p "$(dirname "$INSTALL_DIR")"
        if git clone "$REPO_URL" "$INSTALL_DIR"; then
            log "Repository cloned successfully"
        else
            log_error "Failed to clone repository"
            exit 1
        fi
    fi
    
    # Make scripts executable
    chmod +x "$INSTALL_DIR/install.sh" 2>/dev/null || true
    chmod +x "$INSTALL_DIR"/scripts/*.sh 2>/dev/null || true
    
    # Fix permissions for WebUI service (runs as user 'mm')
    chmod 755 "$INSTALL_DIR"
    chmod -R 755 "$INSTALL_DIR/webui" 2>/dev/null || true
    chown -R mm:mm "$INSTALL_DIR" 2>/dev/null || true
    
    log "Installation directory ready"
}

# Install systemd services
install_services() {
    log "Installing systemd services..."
    
    # Create log file with correct permissions for user mm
    touch "$LOG_FILE"
    chown mm:mm "$LOG_FILE"
    chmod 664 "$LOG_FILE"
    log "Log file configured: $LOG_FILE"
    
    # Setup sudoers for update-setup.sh (passwordless sudo for user mm)
    if [ ! -f /etc/sudoers.d/mm-magicmirror-setup ]; then
        cat > /etc/sudoers.d/mm-magicmirror-setup <<EOF
# Allow user mm to run management scripts without password
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-setup.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-os.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-docker.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-modules.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/restart-mm.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/reboot-system.sh
mm ALL=(ALL) NOPASSWD: /usr/bin/bash /opt/magicmirror-setup/scripts/*
# Allow WebUI to restart itself after config changes
mm ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart mm-webui.service
EOF
        chmod 440 /etc/sudoers.d/mm-magicmirror-setup
        log "Sudoers rules configured for all management scripts"
    fi
    
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
    
    log "WebUI installed and started on port 8081"
}

# Setup initial configuration
setup_initial_config() {
    log "Setting up initial configuration..."
    
    # Create config directories if they don't exist
    mkdir -p "$MM_MOUNTS/config"
    mkdir -p "$MM_MOUNTS/modules"
    
    # Migrate config.json to config.js if needed
    if [ -f "$INSTALL_DIR/scripts/migrate-config-to-js.sh" ]; then
        log "Checking configuration format..."
        if bash "$INSTALL_DIR/scripts/migrate-config-to-js.sh"; then
            log "Configuration format verified"
        else
            log_warning "Configuration migration had warnings"
        fi
    fi
    
    # Copy custom.css if provided
    if [ -f "$INSTALL_DIR/initial-config/custom.css" ]; then
        cp "$INSTALL_DIR/initial-config/custom.css" "$MM_MOUNTS/config/"
        log "Initial custom.css installed"
    fi
}

# Install initial modules (must be called after container is running)
install_initial_modules() {
    log "Installing initial modules..."
    echo "   Checking for modules to install..."
    
    # Count existing modules in container
    local existing_modules=0
    if [ -d "/opt/mm/mounts/modules" ]; then
        existing_modules=$(find /opt/mm/mounts/modules -maxdepth 1 -type d -name "MMM-*" 2>/dev/null | wc -l)
        if [ "$existing_modules" -gt 0 ]; then
            echo "   📦 Found $existing_modules existing module(s) in /opt/mm/mounts/modules"
        fi
    fi
    
    echo "   🔍 Looking for installation scripts in $INSTALL_DIR/initial-modules..."
    
    if [ -d "$INSTALL_DIR/initial-modules" ] && [ "$(ls -A $INSTALL_DIR/initial-modules 2>/dev/null)" ]; then
        # Check if MM container is running
        if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^mm$"; then
            log_error "MagicMirror container 'mm' is not running. Cannot install modules."
            echo "   ❌ Container not running"
            return 1
        fi
        
        local installed_count=0
        local found_modules=0
        echo "   📂 Scanning for .sh files..."
        
        for module_file in "$INSTALL_DIR/initial-modules"/*.sh; do
            # Skip example files
            if [ -f "$module_file" ] && [[ ! "$module_file" =~ \.example\.sh$ ]]; then
                ((found_modules++))
                log "Running $(basename "$module_file")..."
                echo "   🚀 Executing $(basename "$module_file")..."
                if bash "$module_file" 2>&1; then
                    ((installed_count++))
                    echo "      ✅ Script completed successfully"
                else
                    log_warning "Module installation script failed: $(basename "$module_file")"
                    echo "      ⚠️  Script execution failed"
                fi
            fi
        done
        
        if [ $found_modules -eq 0 ]; then
            log "No module installation scripts found (only .example.sh files)"
            echo "   ℹ️  No new modules to install from initial-modules directory"
            if [ "$existing_modules" -gt 0 ]; then
                echo "   ✅ Your $existing_modules existing module(s) remain installed"
            fi
            echo "   💡 Tip: Copy and customize .example.sh files to auto-install more modules"
            return 0
        fi
        
        if [ $installed_count -gt 0 ]; then
            log "Successfully installed $installed_count module(s)"
            echo "   ✅ Successfully installed $installed_count module(s)"
            
            # Ensure module configurations exist in config.js
            if [ -f "$INSTALL_DIR/scripts/ensure-module-configs.sh" ]; then
                log "Ensuring module configurations in config.js..."
                echo "   📝 Updating config.js with module configurations..."
                if bash "$INSTALL_DIR/scripts/ensure-module-configs.sh"; then
                    echo "   ✅ Module configurations updated"
                else
                    echo "   ⚠️  Config update had warnings (check log)"
                fi
            fi
            
            # Restart container to load new modules
            log "Restarting MagicMirror container to load new modules..."
            echo "   🔄 Restarting container to load new modules..."
            if docker restart mm 2>&1 | tee -a "$LOG_FILE"; then
                log "Container restarted successfully"
                echo "   ✅ Container restarted"
                # Wait for container to be ready
                sleep 5
            else
                log_warning "Failed to restart container, please restart manually"
                echo "   ⚠️  Failed to restart container"
            fi
        else
            log "No modules were installed"
            echo "   ⚠️  No modules were successfully installed"
        fi
    else
        log "No initial modules found to install"
        echo "   ℹ️  No initial-modules directory or it's empty"
    fi
}

# Setup boot splash screen
setup_splash_screen() {
    log "Setting up boot splash screen..."
    
    if [ -f "$INSTALL_DIR/assets/splash.png" ]; then
        mkdir -p /opt/splash
        cp "$INSTALL_DIR/assets/splash.png" /opt/splash/
        
        # Install splash services
        cp "$INSTALL_DIR/services/mm-splash.service" /etc/systemd/system/ 2>/dev/null || true
        cp "$INSTALL_DIR/services/mm-splash-stop.service" /etc/systemd/system/ 2>/dev/null || true
        systemctl daemon-reload
        systemctl enable mm-splash.service || true
        systemctl enable mm-splash-stop.service || true
        
        # Configure boot parameters for silent boot
        local CMDLINE_FILE="/boot/firmware/cmdline.txt"
        if [ -f "$CMDLINE_FILE" ]; then
            # Backup original cmdline.txt
            if [ ! -f "$CMDLINE_FILE.backup" ]; then
                cp "$CMDLINE_FILE" "$CMDLINE_FILE.backup"
                log "Backed up original cmdline.txt"
            fi
            
            # Read current cmdline
            local CMDLINE
            CMDLINE=$(cat "$CMDLINE_FILE")
            
            # Add silent boot parameters if not already present
            local NEEDS_UPDATE=false
            
            if [[ ! "$CMDLINE" =~ quiet ]]; then
                CMDLINE="$CMDLINE quiet"
                NEEDS_UPDATE=true
            fi
            
            if [[ ! "$CMDLINE" =~ splash ]]; then
                CMDLINE="$CMDLINE splash"
                NEEDS_UPDATE=true
            fi
            
            if [[ ! "$CMDLINE" =~ loglevel ]]; then
                CMDLINE="$CMDLINE loglevel=0"
                NEEDS_UPDATE=true
            fi
            
            if [[ ! "$CMDLINE" =~ logo.nologo ]]; then
                CMDLINE="$CMDLINE logo.nologo"
                NEEDS_UPDATE=true
            fi
            
            if [[ ! "$CMDLINE" =~ vt.global_cursor_default ]]; then
                CMDLINE="$CMDLINE vt.global_cursor_default=0"
                NEEDS_UPDATE=true
            fi
            
            if [[ ! "$CMDLINE" =~ console=tty3 ]]; then
                # Redirect console to tty3 (invisible)
                CMDLINE="$CMDLINE console=tty3"
                NEEDS_UPDATE=true
            fi
            
            if [ "$NEEDS_UPDATE" = true ]; then
                echo "$CMDLINE" > "$CMDLINE_FILE"
                log "Updated boot parameters for silent boot"
                log_info "Changes will take effect after reboot"
            else
                log "Boot parameters already configured"
            fi
        else
            log_warning "cmdline.txt not found at $CMDLINE_FILE"
        fi
        
        # Disable getty on tty1 to prevent login prompt
        systemctl disable getty@tty1.service 2>/dev/null || true
        log "Disabled getty on tty1 (no login prompt)"
        
        # Disable cursor blinking on all ttys
        if [ ! -f /etc/systemd/system/nocursor.service ]; then
            cat > /etc/systemd/system/nocursor.service <<'EOF'
[Unit]
Description=Disable cursor blinking
DefaultDependencies=no
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 0 > /sys/class/graphics/fbcon/cursor_blink'
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF
            systemctl daemon-reload
            systemctl enable nocursor.service || true
            log "Configured cursor hiding"
        fi
        
        log "Splash screen configured for silent boot"
        log_info "Reboot to see the silent boot experience"
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
    echo "   - Setup self-updates (daily at 02:30)"
    echo "   - Docker container updates (daily at 03:00)"
    echo "   - Module updates (daily at 04:00)"
    echo ""
    echo "✅ WebUI installed and running"
    echo "   Access at: http://$(hostname -I | awk '{print $1}'):8081"
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
    
    # Check if MagicMirror container is running and start if needed
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^mm$"; then
        echo "✅ MagicMirror container is running"
        
        # Container is already running, check if we need to install modules
        if [ -d "$INSTALL_DIR/initial-modules" ] && [ "$(ls -A $INSTALL_DIR/initial-modules 2>/dev/null)" ]; then
            echo ""
            echo "📦 Installing initial modules..."
            install_initial_modules
        fi
    else
        echo "⚠️  MagicMirror container is NOT running"
        echo ""
        
        # Try to start the container
        if [ -f "/opt/mm/run/compose.yaml" ]; then
            echo "🔄 Attempting to start MagicMirror container..."
            cd /opt/mm/run || exit 1
            if docker compose up -d 2>&1 | tee -a "$LOG_FILE"; then
                echo "✅ MagicMirror container started successfully"
                echo ""
                
                # Wait a moment for container to be fully ready
                echo "⏳ Waiting for container to be ready..."
                sleep 3
                
                # Install initial modules now that container is running
                if [ -d "$INSTALL_DIR/initial-modules" ] && [ "$(ls -A $INSTALL_DIR/initial-modules 2>/dev/null)" ]; then
                    echo "📦 Installing initial modules..."
                    install_initial_modules
                fi
            else
                echo "❌ Failed to start container"
                echo ""
                echo "To start MagicMirror manually:"
                echo "   cd /opt/mm/run"
                echo "   docker compose up -d"
            fi
            cd - > /dev/null || exit 1
        else
            echo "To start MagicMirror:"
            echo "   cd /opt/mm/run"
            echo "   docker compose up -d"
        fi
    fi
    
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
    initialize_magicmirror
    initial_update
    install_files
    install_services
    setup_webui
    setup_initial_config
    setup_splash_screen
    
    show_summary
    
    # Cleanup temporary files if we cloned from GitHub
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        log "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
    
    log "Installation completed successfully!"
    log "========================================="
}

# Run main function
main "$@"
