#!/bin/bash
# Install standard MagicMirror modules
# These modules are installed by default during setup

set -e

CONTAINER_NAME="mm"

# Module definitions: URL|ModuleName
MODULES_TO_INSTALL=(
    "https://github.com/b-reich/MMM-PirateSkyForecast.git|MMM-PirateSkyForecast"
    "https://github.com/KristjanESPERANTO/MMM-SystemTemperature.git|MMM-SystemTemperature"
    "https://github.com/Jopyth/MMM-Remote-Control.git|MMM-Remote-Control"
)

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if MM container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "ERROR: MagicMirror container '${CONTAINER_NAME}' is not running"
    exit 1
fi

log "Installing standard modules..."

INSTALLED_COUNT=0
SKIPPED_COUNT=0

for module_entry in "${MODULES_TO_INSTALL[@]}"; do
    # Use pipe as delimiter to avoid issues with : in https://
    IFS='|' read -r GIT_URL MODULE_NAME <<< "$module_entry"
    
    log "Checking module: $MODULE_NAME"
    
    # Check if module already exists
    if [ -d "/opt/mm/mounts/modules/$MODULE_NAME" ]; then
        log "  ⏭️  Module already installed, skipping"
        ((SKIPPED_COUNT++))
        continue
    fi
    
    log "  📦 Installing $MODULE_NAME..."
    
    # Clone module
    if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules && git clone $GIT_URL $MODULE_NAME"; then
        log "  ✅ Cloned successfully"
        
        # Check if package.json exists and run npm install
        if [ -f "/opt/mm/mounts/modules/$MODULE_NAME/package.json" ]; then
            log "  📦 Running npm install..."
            if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules/$MODULE_NAME && npm install --production"; then
                log "  ✅ Dependencies installed"
            else
                log "  ⚠️  npm install failed, but module may still work"
            fi
        fi
        
        ((INSTALLED_COUNT++))
    else
        log "  ❌ Failed to clone $MODULE_NAME"
    fi
done

log "========================================="
log "Standard modules installation complete:"
log "  Installed: $INSTALLED_COUNT"
log "  Skipped (already installed): $SKIPPED_COUNT"
log "========================================="

exit 0
