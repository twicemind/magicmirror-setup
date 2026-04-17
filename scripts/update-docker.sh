#!/bin/bash

# MagicMirror Docker Update Script
# Updates Docker containers to latest versions

set -e

LOG_FILE="/var/log/magicmirror-setup.log"
CONTAINER_NAME="mm"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

log "========================================="
log "Starting Docker update process"
log "========================================="

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    log_error "Docker service is not running"
    exit 1
fi

# Check if MM container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_error "MagicMirror container '${CONTAINER_NAME}' not found"
    exit 1
fi

# Get current image
CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME")
log "Current image: $CURRENT_IMAGE"

# Pull latest image
log "Pulling latest Docker image..."
docker pull "$CURRENT_IMAGE"

# Check if image was updated
NEW_IMAGE_ID=$(docker images -q "$CURRENT_IMAGE")
CURRENT_IMAGE_ID=$(docker inspect --format='{{.Image}}' "$CONTAINER_NAME" | cut -d':' -f2)

if [ "$NEW_IMAGE_ID" != "$CURRENT_IMAGE_ID" ]; then
    log "New image available. Updating container..."
    
    # Stop container
    log "Stopping MagicMirror container..."
    docker stop "$CONTAINER_NAME"
    
    # Remove old container
    log "Removing old container..."
    docker rm "$CONTAINER_NAME"
    
    # Recreate container (using docker compose or original run command)
    # This assumes MagicMirrorOS uses docker-compose
    if [ -f "/opt/mm/docker-compose.yml" ]; then
        log "Recreating container with docker-compose..."
        cd /opt/mm/run
        docker-compose up -d
    else
        log_error "docker-compose.yml not found. Container needs manual recreation."
        exit 1
    fi
    
    log "Container updated and restarted successfully"
else
    log "Container is already up to date"
fi

# Clean up unused images
log "Cleaning up unused Docker images..."
docker image prune -f

log "Docker update completed successfully"
log "========================================="
