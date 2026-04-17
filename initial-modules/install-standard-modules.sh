#!/bin/bash
# Install standard MagicMirror modules
# These modules are installed by default during setup

# Don't exit on error - we want to try all modules
set +e

CONTAINER_NAME="mm"

# Module definitions: URL|ModuleName
MODULES_TO_INSTALL=(
    "https://github.com/b-reich/MMM-PirateSkyForecast.git|MMM-PirateSkyForecast"
    "https://github.com/KristjanESPERANTO/MMM-SystemTemperature.git|MMM-SystemTemperature"
    "https://github.com/Jopyth/MMM-Remote-Control.git|MMM-Remote-Control"
)

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >&2  # Also to stderr for visibility
}

# Check if MM container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log "ERROR: MagicMirror container '${CONTAINER_NAME}' is not running"
    exit 1
fi

log "Installing standard modules..."
echo "   🔍 Checking for modules to install..." >&2

INSTALLED_COUNT=0
SKIPPED_COUNT=0

for module_entry in "${MODULES_TO_INSTALL[@]}"; do
    # Use pipe as delimiter to avoid issues with : in https://
    IFS='|' read -r GIT_URL MODULE_NAME <<< "$module_entry"
    
    log "Checking module: $MODULE_NAME"
    echo "      🔍 Checking: $MODULE_NAME" >&2
    
    # Check if module already exists
    if [ -d "/opt/mm/mounts/modules/$MODULE_NAME" ]; then
        log "  ⏭️  Module already installed, skipping"
        echo "      ⏭️  Already installed, skipping" >&2
        ((SKIPPED_COUNT++))
        continue
    fi
    
    log "  📦 Installing $MODULE_NAME..."
    echo "      📦 Installing $MODULE_NAME..." >&2
    
    # Clone module
    if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules && git clone $GIT_URL $MODULE_NAME" 2>&1; then
        log "  ✅ Cloned successfully"
        echo "      ✅ Cloned successfully" >&2
        
        # Check if package.json exists and run npm install
        if [ -f "/opt/mm/mounts/modules/$MODULE_NAME/package.json" ]; then
            log "  📦 Running npm install..."
            echo "      📦 Running npm install..." >&2
            if docker exec "$CONTAINER_NAME" bash -c "cd /opt/magic_mirror/modules/$MODULE_NAME && npm install --production" 2>&1; then
                log "  ✅ Dependencies installed"
                echo "      ✅ Dependencies installed" >&2
            else
                log "  ⚠️  npm install failed, but module may still work"
                echo "      ⚠️  npm install failed" >&2
            fi
        fi
        
        ((INSTALLED_COUNT++))
    else
        log "  ❌ Failed to clone $MODULE_NAME"
        echo "      ❌ Failed to clone" >&2
    fi
done

log "========================================="
log "Standard modules installation complete:"
log "  Installed: $INSTALLED_COUNT"
log "  Skipped (already installed): $SKIPPED_COUNT"
log "========================================="

echo "   ✅ Module installation complete: $INSTALLED_COUNT new, $SKIPPED_COUNT skipped" >&2

exit 0
