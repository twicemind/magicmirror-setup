#!/bin/bash
# Example: Install MMM-PIR-Sensor module
#
# To use this script:
# 1. Rename this file to remove .example (e.g., cp install-pir-sensor.example.sh install-pir-sensor.sh)
# 2. Make sure the MagicMirror Docker container is running
# 3. Run: sudo bash install.sh
#
# Or run manually after installation:
#   sudo bash scripts/install-module.sh https://github.com/paviro/MMM-PIR-Sensor.git

# Check if MM container is running
if ! docker ps --format '{{.Names}}' | grep -q "^mm$"; then
    echo "ERROR: MagicMirror container 'mm' is not running"
    echo "Please start the container first with: docker compose up -d"
    exit 1
fi

echo "Installing MMM-PIR-Sensor module..."
docker exec mm bash -c "cd /opt/magic_mirror/modules && git clone https://github.com/paviro/MMM-PIR-Sensor.git"
docker exec mm bash -c "cd /opt/magic_mirror/modules/MMM-PIR-Sensor && npm install"

echo "✓ MMM-PIR-Sensor installed. Remember to add it to your MagicMirror config!"
