#!/usr/bin/env python3
"""
MagicMirror Setup WebUI
A web interface for managing MagicMirror installation
"""

from flask import Flask, render_template, request, jsonify, send_file
from flask_cors import CORS
import subprocess
import os
import json
import logging
import socket
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Configuration
SCRIPTS_DIR = "/opt/magicmirror-setup/scripts"
CONFIG_DIR = "/opt/mm/mounts/config"
MODULES_DIR = "/opt/mm/mounts/modules"
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.js")
LOG_FILE = "/var/log/magicmirror-setup.log"

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def run_script(script_name, *args, use_sudo=False):
    """Run a script and return the result"""
    script_path = os.path.join(SCRIPTS_DIR, script_name)
    
    if not os.path.exists(script_path):
        return {"success": False, "message": f"Script not found: {script_name}"}
    
    try:
        # Use sudo for scripts that require root permissions
        if use_sudo:
            cmd = ["sudo", "bash", script_path] + list(args)
        else:
            cmd = ["bash", script_path] + list(args)
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300
        )
        
        return {
            "success": result.returncode == 0,
            "message": result.stdout if result.returncode == 0 else result.stderr,
            "output": result.stdout,
            "error": result.stderr
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "message": "Script execution timeout"}
    except Exception as e:
        logger.error(f"Error running script {script_name}: {e}")
        return {"success": False, "message": str(e)}


def get_hostname():
    """Get system hostname"""
    try:
        return socket.gethostname()
    except:
        return "MagicMirror"


def get_system_status():
    """Get system and MagicMirror status"""
    status = {
        "timestamp": datetime.now().isoformat(),
        "hostname": get_hostname(),
        "container_running": False,
        "webui_version": "1.0.0"
    }
    
    # Check if Docker container is running
    try:
        result = subprocess.run(
            ["docker", "ps", "--filter", "name=mm", "--format", "{{.Names}}"],
            capture_output=True,
            text=True
        )
        status["container_running"] = "mm" in result.stdout
    except Exception as e:
        logger.error(f"Error checking container status: {e}")
    
    # Get system uptime
    try:
        with open("/proc/uptime", "r") as f:
            uptime_seconds = float(f.readline().split()[0])
            status["uptime_hours"] = round(uptime_seconds / 3600, 2)
    except Exception as e:
        logger.error(f"Error getting uptime: {e}")
    
    # Check update timers
    try:
        result = subprocess.run(
            ["systemctl", "list-timers", "--no-pager"],
            capture_output=True,
            text=True
        )
        status["timers_active"] = "mm-" in result.stdout
    except Exception as e:
        logger.error(f"Error checking timers: {e}")
    
    return status


def get_installed_modules():
    """Get list of installed modules"""
    modules = []
    
    if not os.path.exists(MODULES_DIR):
        return modules
    
    try:
        for item in os.listdir(MODULES_DIR):
            module_path = os.path.join(MODULES_DIR, item)
            if os.path.isdir(module_path) and item.startswith("MMM-"):
                module_info = {
                    "name": item,
                    "path": module_path,
                    "is_git": os.path.exists(os.path.join(module_path, ".git")),
                    "has_package_json": os.path.exists(os.path.join(module_path, "package.json"))
                }
                
                # Get git remote URL if available
                if module_info["is_git"]:
                    try:
                        result = subprocess.run(
                            ["git", "-C", module_path, "config", "--get", "remote.origin.url"],
                            capture_output=True,
                            text=True
                        )
                        module_info["git_url"] = result.stdout.strip()
                    except:
                        pass
                
                modules.append(module_info)
    except Exception as e:
        logger.error(f"Error getting modules: {e}")
    
    return modules


@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html')


@app.route('/api/status')
def api_status():
    """Get system status"""
    return jsonify(get_system_status())


@app.route('/api/modules')
def api_modules():
    """Get installed modules"""
    return jsonify(get_installed_modules())


@app.route('/api/modules/install', methods=['POST'])
def api_install_module():
    """Install a new module"""
    data = request.get_json()
    git_url = data.get('git_url')
    module_name = data.get('module_name', '')
    
    if not git_url:
        return jsonify({"success": False, "message": "Git URL is required"}), 400
    
    result = run_script("install-module.sh", git_url, module_name)
    return jsonify(result)


@app.route('/api/modules/<module_name>', methods=['DELETE'])
def api_remove_module(module_name):
    """Remove a module"""
    result = run_script("remove-module.sh", module_name)
    return jsonify(result)


@app.route('/api/modules/update', methods=['POST'])
def api_update_modules():
    """Update all modules"""
    result = run_script("update-modules.sh", use_sudo=True)
    return jsonify(result)


@app.route('/api/updates/os', methods=['POST'])
def api_update_os():
    """Trigger OS update"""
    result = run_script("update-os.sh", use_sudo=True)
    return jsonify(result)


@app.route('/api/updates/docker', methods=['POST'])
def api_update_docker():
    """Trigger Docker update"""
    result = run_script("update-docker.sh", use_sudo=True)
    return jsonify(result)


@app.route('/api/container/restart', methods=['POST'])
def api_restart_container():
    """Restart MagicMirror container"""
    result = run_script("restart-mm.sh", use_sudo=True)
    return jsonify(result)


@app.route('/api/system/reboot', methods=['POST'])
def api_reboot_system():
    """Reboot the Raspberry Pi system"""
    result = run_script("reboot-system.sh", use_sudo=True)
    return jsonify(result)


@app.route('/api/config', methods=['GET'])
def api_get_config():
    """Get MagicMirror configuration"""
    try:
        logger.info(f"Reading config from: {CONFIG_FILE}")
        logger.info(f"Config file exists: {os.path.exists(CONFIG_FILE)}")
        
        if os.path.exists(CONFIG_FILE):
            # Read config.js file
            with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                config_js = f.read()
            
            logger.info(f"Config file size: {len(config_js)} bytes")
            logger.info(f"Config starts with: {config_js[:100] if len(config_js) > 100 else config_js}")
            
            # Return as text for now - frontend can display it as code editor
            response = jsonify({
                "success": True,
                "config": config_js,
                "format": "javascript",
                "path": CONFIG_FILE,
                "size": len(config_js),
                "timestamp": datetime.now().isoformat()
            })
            # Add cache-control headers to prevent stale data
            response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
            response.headers['Pragma'] = 'no-cache'
            response.headers['Expires'] = '0'
            return response
        else:
            # Check if config.json exists (old format)
            old_config = os.path.join(CONFIG_DIR, "config.json")
            if os.path.exists(old_config):
                logger.warning(f"config.js not found, but config.json exists at {old_config}")
                return jsonify({
                    "success": False, 
                    "message": f"Config file not found at {CONFIG_FILE}. Found old config.json instead. Please migrate to config.js"
                }), 404
            
            logger.error(f"Config file not found at {CONFIG_FILE}")
            return jsonify({"success": False, "message": f"Config file not found at {CONFIG_FILE}"}), 404
    except Exception as e:
        logger.error(f"Error reading config: {e}", exc_info=True)
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/config', methods=['POST'])
def api_save_config():
    """Save MagicMirror configuration"""
    try:
        data = request.get_json()
        config = data.get('config')
        
        if not config:
            return jsonify({"success": False, "message": "Config data is required"}), 400
        
        # Backup existing config
        if os.path.exists(CONFIG_FILE):
            backup_file = f"{CONFIG_FILE}.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            import shutil
            shutil.copy2(CONFIG_FILE, backup_file)
            logger.info(f"Config backup created: {backup_file}")
        
        # Save new config.js
        with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
            f.write(config)
        
        logger.info("Config saved successfully, restarting MagicMirror container...")
        
        # Restart MagicMirror container to apply changes
        try:
            result = subprocess.run(
                ["docker", "restart", "mm"],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode == 0:
                logger.info("Container restarted successfully")
                
                # Note: We don't restart the WebUI service here because it would
                # kill the current request before the response is sent.
                # The frontend will reload the page after 8 seconds anyway.
                
                return jsonify({
                    "success": True,
                    "message": "Configuration saved and MagicMirror restarted successfully"
                })
            else:
                logger.error(f"Container restart failed: {result.stderr}")
                return jsonify({
                    "success": True,
                    "message": "Configuration saved but container restart failed. Please restart manually.",
                    "warning": result.stderr
                })
        except Exception as restart_error:
            logger.error(f"Error restarting container: {restart_error}")
            return jsonify({
                "success": True,
                "message": "Configuration saved but container restart failed. Please restart manually."
            })
            
    except Exception as e:
        logger.error(f"Error saving config: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/orientation', methods=['POST'])
def api_set_orientation():
    """Set display orientation"""
    data = request.get_json()
    orientation = data.get('orientation')
    
    if orientation not in ['landscape', 'portrait', 'inverted-landscape', 'inverted-portrait']:
        return jsonify({"success": False, "message": "Invalid orientation"}), 400
    
    result = run_script("set-orientation.sh", orientation)
    return jsonify(result)


@app.route('/api/logs')
def api_get_logs():
    """Get recent log entries"""
    try:
        if os.path.exists(LOG_FILE):
            with open(LOG_FILE, 'r') as f:
                lines = f.readlines()
                # Return last 100 lines
                recent_lines = lines[-100:]
            return jsonify({"success": True, "logs": ''.join(recent_lines)})
        else:
            return jsonify({"success": False, "message": "Log file not found"}), 404
    except Exception as e:
        logger.error(f"Error reading logs: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/setup/check-update')
def api_check_setup_update():
    """Check for setup updates"""
    try:
        result = subprocess.run(
            ["bash", os.path.join(SCRIPTS_DIR, "check-setup-update.sh")],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            update_info = json.loads(result.stdout)
            return jsonify({"success": True, **update_info})
        else:
            return jsonify({"success": False, "message": "Failed to check for updates"})
    except Exception as e:
        logger.error(f"Error checking setup updates: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/setup/update', methods=['POST'])
def api_update_setup():
    """Update the setup itself (runs asynchronously)"""
    # Run with sudo (passwordless sudo configured in /etc/sudoers.d/mm-magicmirror-setup)
    script_path = os.path.join(SCRIPTS_DIR, "update-setup.sh")
    
    if not os.path.exists(script_path):
        logger.error(f"Script not found: {script_path}")
        return jsonify({"success": False, "message": "Script not found"})
    
    try:
        cmd = ["sudo", "bash", script_path]
        logger.info(f"Running update command (async): {' '.join(cmd)}")
        
        # Start the update script asynchronously
        # This allows the HTTP response to be sent immediately
        # The script will restart the WebUI when done
        subprocess.Popen(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True  # Detach from parent process
        )
        
        logger.info("Update script started in background")
        
        return jsonify({
            "success": True,
            "message": "Update started. The WebUI will restart automatically in about 30 seconds. Please reload the page after waiting.",
            "async": True
        })
    except Exception as e:
        logger.error("Update timeout after 300 seconds")
        return jsonify({"success": False, "message": "Update timeout"})
    except Exception as e:
        logger.error(f"Error updating setup: {e}", exc_info=True)
        return jsonify({"success": False, "message": str(e)})


@app.route('/api/update-settings', methods=['GET'])
def api_get_update_settings():
    """Get current update settings"""
    try:
        result = subprocess.run(
            ["bash", os.path.join(SCRIPTS_DIR, "get-update-settings.sh")],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            settings = json.loads(result.stdout)
            return jsonify({"success": True, "settings": settings})
        else:
            return jsonify({"success": False, "message": "Failed to get update settings"})
    except Exception as e:
        logger.error(f"Error getting update settings: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/update-settings', methods=['POST'])
def api_save_update_settings():
    """Save update settings"""
    try:
        data = request.get_json()
        update_type = data.get('type')
        enabled = data.get('enabled')
        schedule = data.get('schedule')
        
        if not update_type:
            return jsonify({"success": False, "message": "Update type is required"}), 400
        
        # Build command arguments
        args = ["--type", update_type]
        
        if enabled is not None:
            args.extend(["--enabled", str(enabled).lower()])
        
        if schedule:
            args.extend(["--schedule", schedule])
        
        result = run_script("configure-updates.sh", *args)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error saving update settings: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/fan-settings')
def api_get_fan_settings():
    """Get current fan configuration"""
    try:
        result = subprocess.run(
            ["bash", os.path.join(SCRIPTS_DIR, "get-fan-settings.sh")],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode == 0:
            fan_info = json.loads(result.stdout)
            return jsonify(fan_info)
        else:
            return jsonify({"success": False, "message": "Failed to get fan settings"})
    except Exception as e:
        logger.error(f"Error getting fan settings: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/fan-settings', methods=['POST'])
def api_save_fan_settings():
    """Save fan configuration"""
    try:
        data = request.get_json()
        enabled = data.get('enabled')
        gpio_pin = data.get('gpio_pin')
        temp_start = data.get('temp_start')
        
        if enabled is None:
            return jsonify({"success": False, "message": "Enabled status is required"}), 400
        
        # Build command arguments
        args = ["--enabled", str(enabled).lower()]
        
        if enabled and gpio_pin:
            args.extend(["--gpio", str(gpio_pin)])
        
        if enabled and temp_start:
            args.extend(["--temp-start", str(temp_start)])
        
        result = run_script("configure-fan.sh", *args)
        return jsonify(result)
    except Exception as e:
        logger.error(f"Error saving fan settings: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081, debug=False)
