#!/bin/bash
# Script to update sudoers on Raspberry Pi
# Run this on the Pi with: curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/update-sudoers.sh | sudo bash

if [ "$EUID" -ne 0 ]; then
   echo "Please run as root (use sudo)"
   exit 1
fi

cat > /etc/sudoers.d/mm-magicmirror-setup <<'SUDOEOF'
# Allow user mm to run management scripts without password
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-setup.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-os.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-docker.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/update-modules.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/restart-mm.sh
mm ALL=(ALL) NOPASSWD: /opt/magicmirror-setup/scripts/reboot-system.sh
mm ALL=(ALL) NOPASSWD: /usr/bin/bash /opt/magicmirror-setup/scripts/*
mm ALL=(ALL) NOPASSWD: /usr/bin/bash /opt/magicmirror-setup/initial-modules/*
# Allow WebUI to restart itself after config changes
mm ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart mm-webui.service
SUDOEOF

chmod 440 /etc/sudoers.d/mm-magicmirror-setup
echo "✓ Sudoers rules updated successfully"
echo "WLAN Manager installation from WebUI is now enabled"
