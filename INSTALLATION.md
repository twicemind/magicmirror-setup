# 📖 MagicMirror Setup - Installationsanleitung

Diese Anleitung führt Sie Schritt für Schritt durch die Installation von MagicMirror Setup auf Ihrem Raspberry Pi.

## 📋 Inhaltsverzeichnis

1. [Vorbereitung](#vorbereitung)
2. [MagicMirrorOS Installation](#magicmirroros-installation)
3. [Erste Schritte nach dem Boot](#erste-schritte-nach-dem-boot)
4. [Nach der Installation](#nach-der-installation)
5. [Erstkonfiguration über WebUI](#erstkonfiguration-über-webui)
6. [Verifizierung](#verifizierung)
7. [Nächste Schritte](#nächste-schritte)

---

## 1. Vorbereitung

### Benötigte Hardware

- Raspberry Pi 3 oder neuer (empfohlen: Raspberry Pi 4 mit 4GB RAM)
- MicroSD-Karte (mindestens 16GB, empfohlen: 32GB)
- Display mit HDMI-Anschluss
- Netzteil für Raspberry Pi
- Tastatur (für initiale Konfiguration)
- (Optional) Gehäuse und Kühlung

### Benötigte Software

- [Raspberry Pi Imager](https://www.raspberrypi.com/software/) oder [balenaEtcher](https://www.balena.io/etcher/)
- [MagicMirrorOS Image](https://github.com/guysoft/MagicMirrorOS/releases)
- SSH-Client (z.B. Terminal auf Mac/Linux, PuTTY auf Windows)

---

## 2. MagicMirrorOS Installation

### Schritt 2.1: Image herunterladen

1. Laden Sie das neueste MagicMirrorOS Image herunter:
   - Besuchen Sie: https://github.com/guysoft/MagicMirrorOS/releases
   - Laden Sie die `.zip` Datei herunter (z.B. `magicmirroros-1.0.0.zip`)

### Schritt 2.2: Image flashen

**Mit Raspberry Pi Imager:**

1. Öffnen Sie Raspberry Pi Imager
2. Klicken Sie auf "Choose OS" → "Use custom"
3. Wählen Sie das heruntergeladene MagicMirrorOS Image
4. Klicken Sie auf "Choose Storage" und wählen Sie Ihre MicroSD-Karte
5. Klicken Sie auf das Zahnrad-Symbol (⚙️) für erweiterte Optionen

**Erweiterte Optionen konfigurieren:**

```
✅ Set hostname: magicmirror (oder beliebiger Name)
✅ Enable SSH: Ja, mit Passwort-Authentifizierung
✅ Set username and password:
   - Username: mm
   - Password: [Ihr gewünschtes Passwort]
✅ Configure wireless LAN:
   - SSID: [Ihr WLAN-Name]
   - Password: [Ihr WLAN-Passwort]
   - Wireless LAN country: DE (oder Ihr Land)
✅ Set locale settings:
   - Time zone: Europe/Berlin
   - Keyboard layout: de
```

6. Klicken Sie auf "Save"
7. Klicken Sie auf "Write" und bestätigen Sie

### Schritt 2.3: Erste Boot

1. Entfernen Sie die MicroSD-Karte aus Ihrem Computer
2. Stecken Sie die MicroSD-Karte in den Raspberry Pi
3. Schließen Sie Display, Tastatur und Stromversorgung an
4. Der Raspberry Pi bootet automatisch

**⏱️ Der erste Boot dauert ca. 2-5 Minuten**

---

## 3. Erste Schritte nach dem Boot

### Schritt 3.1: IP-Adresse ermitteln

**Option A: Am Display ablesen**
- Die IP-Adresse wird normalerweise beim Boot angezeigt

**Option B: Router-Admin-Panel**
- Loggen Sie sich in Ihren Router ein
- Suchen Sie nach dem Gerät "magicmirror" (oder dem von Ihnen gewählten Hostnamen)

**Option C: Netzwerk scannen**
```bash
# Auf Mac/Linux
arp -a | grep -i raspberry
# oder
nmap -sn 192.168.1.0/24
```

### Schritt 3.2: SSH-Verbindung herstellen

```bash
ssh mm@<raspberry-pi-ip>
# Beispiel: ssh mm@192.168.1.100
```

Beim ersten Login:
- Bestätigen Sie den Fingerprint mit "yes"
- Geben Sie Ihr Passwort ein

### Schritt 3.3: MagicMirror Setup installieren

**Das MagicMirror Setup übernimmt die MagicMirror-Initialisierung automatisch!**

Führen Sie einfach aus:

```bash
curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/install.sh | sudo bash
```

**Was passiert dabei?**

1. **Prüft** ob MagicMirror bereits initialisiert wurde (Marker-Datei `/opt/mm/.magicmirror-initialized`)
2. **Falls nicht:** Führt automatisch `bash /opt/mm/install/install.sh electron` aus
3. Installiert das MagicMirror Setup (WebUI, Timer, Scripts)
4. Setzt Marker-Datei, damit die initiale Installation nicht wiederholt wird

**⏱️ Die erste Installation dauert ca. 10-15 Minuten** (inkl. MagicMirror-Initialisierung)

**Alternative: Manuelle Installation**

Wenn Sie MagicMirror manuell initialisieren möchten:

```bash
# 1. Manuell MagicMirror installieren
cd /opt/mm/install/
sudo bash install.sh electron

# 2. Dann MagicMirror Setup installieren
curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/install.sh | sudo bash
```

**Wichtig:** Bei Updates oder Restarts nutzt MagicMirror die Standard-Wege:
- Start: `cd /opt/mm && docker compose up -d`
- Stop: `docker compose down`
- Restart: `docker compose restart`

---

## 4. Nach der Installation

### Schritt 4.1: Installation verifizieren

Nach erfolgreicher Installation (ca. 10-15 Minuten) sollten Sie folgende Ausgabe sehen:

```
======================================
  MagicMirror Setup Installation Complete
======================================

✅ System updated
✅ MagicMirror initialized with Electron
✅ Automatic update services installed:
   - OS updates (daily at 02:00)
   - Docker container updates (daily at 03:00)
   - Module updates (daily at 04:00)

✅ WebUI installed and running
   Access at: http://192.168.1.100:8080

📝 Configuration location: /opt/mm/mounts/config/
📦 Modules location: /opt/mm/mounts/modules/
```

---

## 5. Erstkonfiguration über WebUI

### Schritt 5.1: WebUI öffnen

Öffnen Sie in Ihrem Browser:

```
http://<raspberry-pi-ip>:8080
```

Sie sollten das Dashboard sehen mit:
- System-Status
- Container-Status
- Update-Timer-Status

### Schritt 5.2: Konfiguration anpassen

**Via WebUI:**
1. Scrollen Sie zum "Configuration Editor"
2. Bearbeiten Sie die `config.json`
3. Passen Sie folgende Werte an:
   - `language`: Ihre Sprache (z.B. "de")
   - `timezone`: Ihre Zeitzone (z.B. "Europe/Berlin")
   - Weather-API-Key (siehe unten)
4. Klicken Sie auf "Save Configuration"
5. Scrollen Sie zu "Container Control"
6. Klicken Sie auf "Restart Container"

**Weather API Key besorgen:**
1. Registrieren Sie sich bei [OpenWeatherMap](https://openweathermap.org/api)
2. Erstellen Sie einen kostenlosen API-Key
3. Fügen Sie den Key in beide Weather-Module in der config.json ein

### Schritt 5.3: Module installieren (optional)

**Beispiel: MMM-PIR-Sensor für automatisches Display Ein/Aus**

Via WebUI:
1. Scrollen Sie zu "Installed Modules"
2. Git Repository URL: `https://github.com/paviro/MMM-PIR-Sensor`
3. Klicken Sie auf "Install Module"

Via SSH:
```bash
sudo /opt/magicmirror-setup/scripts/install-module.sh https://github.com/paviro/MMM-PIR-Sensor
```

**Weitere beliebte Module:**
- [MMM-GoogleCalendar](https://github.com/randomBrainstormer/MMM-GoogleCalendar)
- [MMM-Spotify](https://github.com/skuethe/MMM-Spotify)
- [MMM-Remote-Control](https://github.com/Jopyth/MMM-Remote-Control)

Siehe auch: [MagicMirror Module Wiki](https://github.com/MichMich/MagicMirror/wiki/3rd-Party-Modules)

---

## 6. Verifizierung

### Schritt 6.1: Services überprüfen

```bash
# WebUI-Status
systemctl status mm-webui.service

# Update-Timer anzeigen
systemctl list-timers

# Container-Status
docker ps

# Logs ansehen
tail -f /var/log/magicmirror-setup.log
```

### Schritt 6.2: Display-Test

Am angeschlossenen Display sollten Sie den MagicMirror sehen mit:
- Uhrzeit (oben links)
- Kalender (oben links)
- Wetter (oben rechts)
- Nachrichtenfeed (unten)

### Schritt 6.3: Funktionstest

**Test 1: Manuelle Updates**
1. Öffnen Sie die WebUI
2. Klicken Sie auf "Update Modules"
3. Prüfen Sie die Logs

**Test 2: Container-Neustart**
1. Klicken Sie auf "Restart Container"
2. Beobachten Sie den Display
3. MagicMirror sollte neu laden

**Test 3: Konfiguration ändern**
1. Bearbeiten Sie die config.json
2. Ändern Sie z.B. `displaySeconds: false` zu `true` im Clock-Modul
3. Speichern und Container neu starten
4. Prüfen Sie, ob Sekunden angezeigt werden

---

## 7. Nächste Schritte

### Display-Orientierung anpassen

Wenn Sie ein Display im Hochformat verwenden:

```bash
sudo /opt/magicmirror-setup/scripts/set-orientation.sh portrait
sudo reboot
```

### Boot-Splash-Screen hinzufügen

1. Erstellen Sie ein PNG-Bild (1920x1080 oder 1080x1920 für Portrait)
2. Kopieren Sie es auf den Raspberry Pi:
   ```bash
   scp splash.png mm@<raspberry-pi-ip>:/tmp/
   ssh mm@<raspberry-pi-ip>
   sudo cp /tmp/splash.png /opt/splash/splash.png
   sudo systemctl enable mm-splash.service
   ```

### Automatische Updates konfigurieren

Die Updates sind bereits konfiguriert für täglich um 02:00 Uhr.

**Zeitplan ändern:**
```bash
sudo nano /etc/systemd/system/mm-os-update.timer
# Ändern Sie die OnCalendar-Zeile
# Beispiel: OnCalendar=*-*-* 03:00:00 für 03:00 Uhr
sudo systemctl daemon-reload
sudo systemctl restart mm-os-update.timer
```

### Sicherheit erhöhen

**SSH-Key-Authentifizierung:**
```bash
# Auf Ihrem lokalen Computer
ssh-keygen -t ed25519 -C "magicmirror"
ssh-copy-id mm@<raspberry-pi-ip>

# Auf dem Raspberry Pi
sudo nano /etc/ssh/sshd_config
# Ändern Sie: PasswordAuthentication no
sudo systemctl restart sshd
```

**Firewall einrichten:**
```bash
sudo apt-get install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8080/tcp  # WebUI
sudo ufw enable
```

### Monitoring einrichten

**Systemd-Benachrichtigungen bei Fehlern:**
```bash
# E-Mail-Benachrichtigungen konfigurieren
sudo apt-get install postfix mailutils
# Konfigurieren Sie Postfix für Ihre E-Mail-Einstellungen
```

---

## 🆘 Hilfe und Support

### Häufige Probleme

**Problem: WebUI nicht erreichbar**
```bash
sudo systemctl status mm-webui.service
sudo systemctl restart mm-webui.service
journalctl -u mm-webui.service -n 50
```

**Problem: Container startet nicht**
```bash
docker ps -a
docker logs mm
cd /opt/mm
docker-compose up -d
```

**Problem: Display zeigt nichts**
```bash
# HDMI-Ausgabe forcieren
sudo nano /boot/config.txt
# Fügen Sie hinzu:
hdmi_force_hotplug=1
hdmi_drive=2
```

### Logs und Debugging

Alle wichtigen Logs:
```bash
# Setup-Logs
tail -f /var/log/magicmirror-setup.log

# Docker-Logs
docker logs mm -f

# System-Logs
journalctl -f

# Spezifischer Service
journalctl -u mm-webui.service -f
```

### Community und Links

- [MagicMirror Forum](https://forum.magicmirror.builders/)
- [MagicMirror Discord](https://discord.gg/magicmirror)
- [GitHub Issues](https://github.com/twicemind/magicmirror-setup/issues)

---

## ✅ Installation abgeschlossen!

Ihr MagicMirror sollte jetzt vollständig eingerichtet sein mit:

✅ Funktionierender MagicMirror-Anzeige
✅ WebUI für Verwaltung
✅ Automatischen Updates
✅ Modul-Management
✅ Konfigurationsmöglichkeiten

**Viel Spaß mit Ihrem MagicMirror! 🪞✨**
