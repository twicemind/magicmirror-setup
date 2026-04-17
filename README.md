# 🪞 MagicMirror Setup

Automatisierte Setup- und Verwaltungslösung für MagicMirror auf Raspberry Pi mit MagicMirrorOS.

## 🎯 Überblick

Dieses Projekt bietet eine vollständige Automatisierung für die Installation und Wartung einer MagicMirror-Installation auf einem Raspberry Pi. Es beinhaltet:

- ✅ Automatische System-Updates (täglich um 02:00 Uhr)
- ✅ Automatische System-Updates (täglich um 02:00 Uhr)
- ✅ Automatische Docker-Container-Updates
- ✅ Automatische MagicMirror-Modul-Updates
- ✅ Automatische Setup-Self-Updates (aus GitHub)
- ✅ WebUI für einfache Verwaltung (responsive Design)
- ✅ Hostname-Anzeige im Dashboard
- ✅ Modul-Management (Installation/Deinstallation)
- ✅ Konfigurationseditor
- ✅ Display-Orientierung (Hoch-/Querformat)
- ✅ Boot-Splash-Screen
- ✅ Vollständige Logging-Funktionalität
- ✅ Update-Benachrichtigungen in der WebUI

## 📋 Voraussetzungen

- Raspberry Pi (3 oder neuer empfohlen)
- **MagicMirrorOS** (Debian-basiertes OS mit vorinstalliertem MagicMirror in `/opt/mm`)
- MagicMirror-Container mit `docker compose up -d` gestartet (optional für erste Installation)
- SSH-Zugang aktiviert
- WLAN konfiguriert

**Hinweis:** MagicMirrorOS liefert MagicMirror bereits mit Docker Compose aus. Dieses Setup ergänzt die Installation um:
- Automatische Updates (OS, Docker, Setup, Module)
- WebUI zur Verwaltung
- Systemd-Timer für regelmäßige Wartung
- Logging und Monitoring

## 🚀 Quick Start

### Ein-Befehl-Installation (empfohlen)

```bash
curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/install.sh | sudo bash
```

**Das war's!** Das Script:
1. ✅ Prüft ob MagicMirror bereits initialisiert wurde
2. ✅ Führt automatisch `/opt/mm/install/install.sh electron` aus (falls nötig)
3. ✅ Installiert WebUI, Timer und alle Management-Tools
4. ✅ Startet die WebUI auf Port 8080

⏱️ **Erste Installation:** ca. 10-15 Minuten  
⏱️ **Update-Installation:** ca. 2-3 Minuten

### Alternative: Manuelle Installation

```bash
# MagicMirror manuell initialisieren (einmalig)
cd /opt/mm/install
sudo bash install.sh electron

# Dann MagicMirror Setup installieren
curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/install.sh | sudo bash
```

## � MagicMirror Verwaltung

### Container starten/stoppen/neustarten

Nach der ersten Installation nutzen Sie die Standard-MagicMirror-Befehle:

```bash
# Container starten
cd /opt/mm/run
docker compose up -d

# Container stoppen
cd /opt/mm/run
docker compose down

# Container neustarten
cd /opt/mm/run
docker compose restart

# Logs anzeigen
cd /opt/mm/run
docker compose logs -f
```

**Wichtig:** Die automatische Initialisierung (`/opt/mm/install/install.sh electron`) wird nur **einmal** beim ersten Setup ausgeführt. Eine Marker-Datei `/opt/mm/.magicmirror-initialized` verhindert eine erneute Initialisierung bei Updates.

## �📖 Vollständige Installationsanleitung

Siehe [INSTALLATION.md](INSTALLATION.md) für eine detaillierte Schritt-für-Schritt-Anleitung.

## 🎨 WebUI

Nach der Installation ist die WebUI unter folgender Adresse erreichbar:

```
http://<raspberry-pi-ip>:8081
```

**Hinweis:** Port 8081 wird verwendet, da MagicMirror selbst auf Port 8080 läuft.

### Features der WebUI

- **Dashboard**: Übersicht über den System-Status mit Hostname
- **Responsive Design**: Optimiert für Desktop, Tablet und Mobile
- **Setup-Updates**: Prüfen und Installieren von Setup-Updates aus GitHub
- **System-Updates**: Manuelle Trigger für OS-, Docker- und Modul-Updates
- **Container-Steuerung**: Neustart des MagicMirror-Containers
- **Modul-Management**: Hinzufügen, Entfernen und Aktualisieren von Modulen
- **Konfigurations-Editor**: Direktes Bearbeiten der config.json
- **Display-Einstellungen**: Orientierung des Displays ändern
- **System-Logs**: Einsicht in die Logs
- **Update-Benachrichtigungen**: Visuelles Feedback bei verfügbaren Updates

## 🔄 Automatische Updates

Das System richtet automatisch folgende Update-Services ein:

### Setup-Self-Updates
- **Zeitplan**: Täglich um 02:00 Uhr
- **Umfang**: MagicMirror Setup selbst aus GitHub
- **Auto-Restart**: Ja (WebUI wird neu gestartet)

### OS-Updates
- **Zeitplan**: Täglich um 02:00 Uhr
- **Umfang**: Betriebssystem-Patches und Sicherheitsupdates
- **Auto-Reboot**: Ja, falls erforderlich

### Docker-Updates
- **Zeitplan**: Täglich um 02:00 Uhr
- **Umfang**: Aktualisierung der Docker-Container-Images
- **Auto-Restart**: Ja, bei verfügbaren Updates

### Modul-Updates
- **Zeitplan**: Täglich um 02:00 Uhr
- **Umfang**: Alle installierten Git-Module
- **Auto-Restart**: Ja, nach erfolgreichen Updates

## 📦 Modul-Management

### Modul über WebUI installieren

1. WebUI öffnen
2. Zum Abschnitt "Installed Modules" scrollen
3. Git-Repository-URL eingeben
4. Optional: Modul-Namen angeben
5. "Install Module" klicken

### Modul über CLI installieren

```bash
sudo /opt/magicmirror-setup/scripts/install-module.sh https://github.com/user/MMM-ModuleName
```

### Modul entfernen

```bash
sudo /opt/magicmirror-setup/scripts/remove-module.sh MMM-ModuleName
```

## ⚙️ Konfiguration

### config.json bearbeiten

**Via WebUI:**
1. WebUI öffnen
2. Zum "Configuration Editor" scrollen
3. JSON bearbeiten
4. "Save Configuration" klicken
5. Container neu starten

**Via SSH:**
```bash
nano /opt/mm/mounts/config/config.json
# Nach dem Bearbeiten:
docker restart mm
```

### Initiale Konfiguration

Wenn Sie bei der Installation bereits eine Konfiguration bereitstellen möchten:

1. Fügen Sie Ihre `config.json` zu `initial-config/config.json` hinzu
2. Optional: Fügen Sie `custom.css` zu `initial-config/custom.css` hinzu
3. Führen Sie die Installation durch

## 🖥️ Display-Orientierung

### Via WebUI

1. WebUI öffnen
2. Zum Abschnitt "Display Settings" scrollen
3. Orientierung auswählen:
   - Landscape (Querformat)
   - Portrait (Hochformat)
   - Inverted Landscape (Umgekehrtes Querformat)
   - Inverted Portrait (Umgekehrtes Hochformat)
4. "Apply Orientation" klicken
5. System neu starten

### Via CLI

```bash
sudo /opt/magicmirror-setup/scripts/set-orientation.sh portrait
sudo reboot
```

## 🎨 Boot Splash Screen

Um einen benutzerdefinierten Splash Screen während des Bootvorgangs anzuzeigen:

1. Erstellen Sie ein PNG-Bild (empfohlen: 1920x1080 für Full HD)
2. Speichern Sie es als `assets/splash.png`
3. Führen Sie die Installation durch oder kopieren Sie es manuell:

```bash
sudo cp splash.png /opt/splash/splash.png
sudo systemctl enable mm-splash.service
```

## 🔧 Systemd Services

Das Setup installiert folgende Services:

### Timers (Automatische Ausführung)
- `mm-os-update.timer` - OS-Updates
- `mm-docker-update.timer` - Docker-Updates
- `mm-modules-update.timer` - Modul-Updates

### Services
- `mm-webui.service` - WebUI-Server
- `mm-splash.service` - Boot-Splash-Screen

### Nützliche Befehle

```bash
# Timer-Status anzeigen
systemctl list-timers

# Service-Status prüfen
systemctl status mm-webui.service

# Service neu starten
sudo systemctl restart mm-webui.service

# Logs ansehen
journalctl -u mm-os-update.service -f
```

## 📊 Logging

Alle Operationen werden geloggt nach:

```
/var/log/magicmirror-setup.log
```

Logs ansehen:
```bash
tail -f /var/log/magicmirror-setup.log
```

## 🐛 Troubleshooting

### WebUI ist nicht erreichbar

```bash
# Service-Status prüfen
sudo systemctl status mm-webui.service

# Service neu starten
sudo systemctl restart mm-webui.service

# Logs prüfen
journalctl -u mm-webui.service -n 50
```

### Container startet nicht

```bash
# Container-Status prüfen
docker ps -a

# Container-Logs ansehen
docker logs mm

# Container manuell starten
cd /opt/mm/run
docker compose up -d
```

### Module werden nicht aktualisiert

```bash
# Manuelle Aktualisierung
sudo /opt/magicmirror-setup/scripts/update-modules.sh

# Logs prüfen
tail -f /var/log/magicmirror-setup.log
```

## 🏗️ Projektstruktur

```
magicmirror-setup/
├── install.sh                  # Haupt-Installationsskript
├── scripts/                    # Verwaltungsskripte
│   ├── update-os.sh           # OS-Update-Script
│   ├── update-docker.sh       # Docker-Update-Script
│   ├── update-modules.sh      # Modul-Update-Script
│   ├── install-module.sh      # Modul-Installation
│   ├── remove-module.sh       # Modul-Deinstallation
│   ├── restart-mm.sh          # Container-Neustart
│   └── set-orientation.sh     # Display-Orientierung
├── services/                   # Systemd Service-Definitionen
│   ├── mm-os-update.service
│   ├── mm-os-update.timer
│   ├── mm-docker-update.service
│   ├── mm-docker-update.timer
│   ├── mm-modules-update.service
│   ├── mm-modules-update.timer
│   ├── mm-webui.service
│   └── mm-splash.service
├── webui/                      # Flask WebUI
│   ├── app.py                 # Haupt-Anwendung
│   ├── requirements.txt       # Python-Abhängigkeiten
│   └── templates/             # HTML-Templates
├── initial-config/            # Initiale Konfiguration
│   ├── config.json           # Beispiel-Konfiguration
│   └── custom.css            # Beispiel-CSS
├── initial-modules/           # Initiale Module (optional)
├── assets/                    # Assets (Splash-Screen, etc.)
└── README.md                  # Diese Datei
```

## 🧪 Lokales Testen (Sandbox)

Siehe [TESTING.md](TESTING.md) für Informationen zum lokalen Testen mit Docker.

## 🔐 Sicherheit

- Die WebUI läuft standardmäßig nur auf localhost
- Für externen Zugriff sollte eine Reverse-Proxy-Konfiguration mit HTTPS verwendet werden
- SSH-Zugang sollte mit einem starken Passwort oder Key-basiert gesichert werden

## 📝 Entwicklung und Beiträge

Contributions sind willkommen! Bitte erstellen Sie einen Pull Request oder öffnen Sie ein Issue.

### Entwicklungsumgebung

```bash
# Repository klonen
git clone https://github.com/twicemind/magicmirror-setup.git
cd magicmirror-setup

# WebUI lokal testen
cd webui
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

## 📜 Lizenz

MIT License - siehe [LICENSE](LICENSE) für Details.

## 👤 Autor

TwiceMind

## 🔗 Links

- [MagicMirror²](https://magicmirror.builders/)
- [MagicMirrorOS](https://github.com/guysoft/MagicMirrorOS)
- [MagicMirror Module](https://github.com/MichMich/MagicMirror/wiki/3rd-Party-Modules)

## 🙏 Danksagungen

- MagicMirror² Community
- MagicMirrorOS Entwickler
- Alle Contributors

---

**Hinweis**: Dieses Projekt ist in aktiver Entwicklung. Features können sich ändern.

## 🚧 Zukünftige Features

- [ ] MagicMirror-WLAN Projekt-Integration
- [ ] Backup und Restore Funktionalität
- [ ] Multi-MagicMirror-Management
- [ ] Mobile App
- [ ] Erweiterte Monitoring-Features
