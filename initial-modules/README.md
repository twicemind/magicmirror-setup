# Standard Modules

This directory contains installation scripts for standard MagicMirror modules that are automatically installed during setup.

## Standard Modules

The following modules are installed by default:

### 1. MMM-PirateSkyForecast
**Description:** Weather forecast module with detailed information  
**Repository:** https://github.com/b-reich/MMM-PirateSkyForecast  
**Configuration:** Automatically added to config.js (requires OpenWeatherMap API key)

### 2. MMM-SystemTemperature
**Description:** Display CPU/GPU temperature of your Raspberry Pi  
**Repository:** https://github.com/KristjanESPERANTO/MMM-SystemTemperature  
**Configuration:** Automatically added to config.js

### 3. MMM-Remote-Control
**Description:** Remote control interface for MagicMirror  
**Repository:** https://github.com/Jopyth/MMM-Remote-Control  
**Configuration:** Automatically added to config.js

## Optional: WiFi Management

### MagicMirror WLAN Manager
**Description:** Automatic WiFi management with HotSpot fallback and web configuration  
**Repository:** https://github.com/twicemind/magicmirror-wlan  
**Installation:** Automatically installed by `install-magicmirror-wlan.sh`  
**Features:**
- Automatic network monitoring (checks internet connection every 30 seconds)
- HotSpot fallback when WiFi disconnects
- Web-based WiFi configuration (port 8765)
- WiFi scanner and network selection
- MagicMirror module (MMM-WLANManager) with QR code for mobile access
- Automatic reconnection when configured network is available

**Services:**
- `wlan-network-monitor.service` - Background network monitoring
- `wlan-webui.service` - Configuration WebUI on port 8765

**Access:**
- WebUI: `http://<raspberry-pi-ip>:8765`
- When in HotSpot mode: Connect to WiFi "MagicMirror-Setup" (password: magicmirror)

This module is automatically installed during setup and provides seamless WiFi management for your MagicMirror.

## How it works

- `install-standard-modules.sh` - Installs all standard modules
- `../scripts/ensure-module-configs.sh` - Adds default configurations to config.js (if not already present)

These scripts are automatically executed during `install.sh` if the MagicMirror container is running.

## Customizing

If you don't want certain standard modules:
1. Remove them from `/opt/mm/mounts/modules/`
2. Remove their configuration from `/opt/mm/mounts/config/config.js`
3. Restart the container: `docker restart mm`

## Adding more standard modules

To add more modules to the default installation:

1. Edit `install-standard-modules.sh` and add the Git URL and module name
2. Edit `../scripts/ensure-module-configs.sh` and add the default configuration
3. Run `sudo bash install.sh` to install on existing setups

## Manual installation

You can also run the installation scripts manually:

```bash
# Install standard modules
sudo bash /opt/magicmirror-setup/initial-modules/install-standard-modules.sh

# Ensure module configurations
sudo bash /opt/magicmirror-setup/scripts/ensure-module-configs.sh
```
