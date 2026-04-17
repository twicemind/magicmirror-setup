#!/usr/bin/env python3
"""
MagicMirror Setup WebUI - Local Test Version
A web interface for testing locally without Raspberry Pi
"""

from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import subprocess
import os
import json
import logging
import socket
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Local test configuration
SCRIPTS_DIR = os.path.join(os.path.dirname(__file__), "..", "scripts")
CONFIG_DIR = "/tmp/mm-test/config"
MODULES_DIR = "/tmp/mm-test/modules"
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")
LOG_FILE = "/tmp/mm-test/setup.log"

# Ensure directories exist
os.makedirs(CONFIG_DIR, exist_ok=True)
os.makedirs(MODULES_DIR, exist_ok=True)

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def run_script(script_name, *args):
    """Run a script and return the result (mocked for local testing)"""
    logger.info(f"Would run: {script_name} {' '.join(args)}")
    return {
        "success": True,
        "message": f"[TEST MODE] Would execute: {script_name}",
        "output": f"Script {script_name} would be executed on real system",
        "error": ""
    }


def get_hostname():
    """Get system hostname"""
    try:
        return socket.gethostname()
    except:
        return "TestMirror"


def get_system_status():
    """Get system and MagicMirror status (mocked for local testing)"""
    status = {
        "timestamp": datetime.now().isoformat(),
        "hostname": get_hostname(),
        "container_running": True,  # Mock
        "webui_version": "1.0.0",
        "uptime_hours": 42.5,  # Mock
        "timers_active": True,  # Mock
        "test_mode": True
    }
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
    """Install a new module (mocked)"""
    data = request.get_json()
    git_url = data.get('git_url')
    module_name = data.get('module_name', '')
    
    if not git_url:
        return jsonify({"success": False, "message": "Git URL is required"}), 400
    
    logger.info(f"Would install module from: {git_url}")
    return jsonify({
        "success": True,
        "message": f"[TEST MODE] Would install module from {git_url}"
    })


@app.route('/api/modules/<module_name>', methods=['DELETE'])
def api_remove_module(module_name):
    """Remove a module (mocked)"""
    logger.info(f"Would remove module: {module_name}")
    return jsonify({
        "success": True,
        "message": f"[TEST MODE] Would remove module {module_name}"
    })


@app.route('/api/modules/update', methods=['POST'])
def api_update_modules():
    """Update all modules (mocked)"""
    result = run_script("update-modules.sh")
    return jsonify(result)


@app.route('/api/updates/os', methods=['POST'])
def api_update_os():
    """Trigger OS update (mocked)"""
    result = run_script("update-os.sh")
    return jsonify(result)


@app.route('/api/updates/docker', methods=['POST'])
def api_update_docker():
    """Trigger Docker update (mocked)"""
    result = run_script("update-docker.sh")
    return jsonify(result)


@app.route('/api/container/restart', methods=['POST'])
def api_restart_container():
    """Restart MagicMirror container (mocked)"""
    result = run_script("restart-mm.sh")
    return jsonify(result)


@app.route('/api/config', methods=['GET'])
def api_get_config():
    """Get MagicMirror configuration"""
    try:
        if os.path.exists(CONFIG_FILE):
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
            return jsonify({"success": True, "config": config})
        else:
            # Return example config
            example_config = {
                "address": "localhost",
                "port": 8081,
                "language": "de",
                "modules": [
                    {
                        "module": "clock",
                        "position": "top_left"
                    }
                ]
            }
            return jsonify({"success": True, "config": example_config})
    except Exception as e:
        logger.error(f"Error reading config: {e}")
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
            os.rename(CONFIG_FILE, backup_file)
        
        # Save new config
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)
        
        return jsonify({"success": True, "message": "Configuration saved successfully (TEST MODE)"})
    except Exception as e:
        logger.error(f"Error saving config: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/orientation', methods=['POST'])
def api_set_orientation():
    """Set display orientation (mocked)"""
    data = request.get_json()
    orientation = data.get('orientation')
    
    if orientation not in ['landscape', 'portrait', 'inverted-landscape', 'inverted-portrait']:
        return jsonify({"success": False, "message": "Invalid orientation"}), 400
    
    logger.info(f"Would set orientation to: {orientation}")
    return jsonify({
        "success": True,
        "message": f"[TEST MODE] Would set orientation to {orientation}"
    })


@app.route('/api/logs')
def api_get_logs():
    """Get recent log entries"""
    try:
        if os.path.exists(LOG_FILE):
            with open(LOG_FILE, 'r') as f:
                logs = f.read()
        else:
            logs = "[TEST MODE] No logs yet. This would show system logs on Raspberry Pi."
        
        return jsonify({"success": True, "logs": logs})
    except Exception as e:
        logger.error(f"Error reading logs: {e}")
        return jsonify({"success": False, "message": str(e)}), 500


@app.route('/api/setup/check-update')
def api_check_setup_update():
    """Check for setup updates (mocked)"""
    logger.info("Checking for setup updates (mocked)")
    return jsonify({
        "success": True,
        "current_version": "1.0.0",
        "latest_version": "1.0.0",
        "update_available": False
    })


@app.route('/api/setup/update', methods=['POST'])
def api_update_setup():
    """Update the setup itself (mocked)"""
    logger.info("Would update setup from GitHub")
    return jsonify({
        "success": True,
        "message": "[TEST MODE] Would update setup from GitHub repository"
    })


@app.route('/api/update-settings', methods=['GET'])
def api_get_update_settings():
    """Get current update settings (mocked)"""
    logger.info("Getting update settings (mocked)")
    return jsonify({
        "success": True,
        "settings": {
            "os_updates": {"enabled": True, "schedule": "02:00:00"},
            "docker_updates": {"enabled": True, "schedule": "03:00:00"},
            "module_updates": {"enabled": True, "schedule": "04:00:00"},
            "setup_updates": {"enabled": True, "schedule": "02:30:00"}
        }
    })


@app.route('/api/update-settings', methods=['POST'])
def api_save_update_settings():
    """Save update settings (mocked)"""
    data = request.get_json()
    logger.info(f"Would save update settings: {data}")
    return jsonify({
        "success": True,
        "message": f"[TEST MODE] Would configure {data.get('type')} updates"
    })


@app.route('/api/fan-settings')
def api_get_fan_settings():
    """Get current fan configuration (mocked)"""
    logger.info("Getting fan settings (mocked)")
    return jsonify({
        "success": True,
        "settings": {
            "enabled": False,
            "gpio_pin": "4",
            "temp_start": "60",
            "temp_stop": "50"
        }
    })


@app.route('/api/fan-settings', methods=['POST'])
def api_save_fan_settings():
    """Save fan configuration (mocked)"""
    data = request.get_json()
    logger.info(f"Would save fan settings: {data}")
    return jsonify({
        "success": True,
        "message": f"[TEST MODE] Would configure fan (GPIO{data.get('gpio_pin')}, {data.get('temp_start')}°C)"
    })


if __name__ == '__main__':
    print("\n" + "="*60)
    print("🧪 MagicMirror Setup WebUI - TEST MODE")
    print("="*60)
    print("\n✅ Running in local test mode")
    print(f"📁 Config directory: {CONFIG_DIR}")
    print(f"📦 Modules directory: {MODULES_DIR}")
    print("\n🌐 WebUI will be available at: http://localhost:8081")
    print("\n⚠️  Note: All operations are mocked and won't affect your system")
    print("="*60 + "\n")
    
    app.run(host='0.0.0.0', port=8081, debug=True)
