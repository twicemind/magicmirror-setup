# 🪞 MagicMirror Setup - Project Overview

## 📋 Projekt-Zusammenfassung

MagicMirror Setup ist eine vollständige Automatisierungslösung für die Installation, Konfiguration und Wartung von MagicMirror² auf Raspberry Pi mit **MagicMirrorOS**.

**Version:** 1.15.0  
**Lizenz:** MIT  
**Repository:** https://github.com/twicemind/magicmirror-setup

## 🏗️ Architektur

### Basis-System: MagicMirrorOS
Dieses Setup baut auf **MagicMirrorOS** auf, einem Debian-basierten Betriebssystem-Image, das MagicMirror bereits vorinstalliert enthält:

- **MagicMirror-Installation:** `/opt/mm`
- **Docker Compose Setup:** MagicMirror läuft als Docker-Container (`mm`)
- **Start-Befehl:** `cd /opt/mm/run && docker compose up -d`
- **Mounts:**
  - `/opt/mm/mounts/config` → MagicMirror-Konfiguration
  - `/opt/mm/mounts/modules` → Zusätzliche Module
  - `/opt/mm/mounts/css` → Custom CSS

**Wichtig:** Das MagicMirror Setup ergänzt die MagicMirrorOS-Installation um automatische Wartung, WebUI und Management-Tools. Es ersetzt NICHT die Basis-Installation.

## 🎯 Hauptfunktionen

### 1. **Automatisierte Installation**
- Ein-Befehl Setup via curl
- **Automatische MagicMirror-Initialisierung**: Führt `/opt/mm/install/install.sh electron` automatisch aus (nur beim ersten Mal)
- Marker-basierte Erkennung: Verhindert Doppel-Initialisierung via `/opt/mm/.magicmirror-initialized`
- Vollautomatische Konfiguration aller Services
- Initiale Konfigurationsunterstützung

### 2. **Automatische Updates**
- **OS-Updates**: Täglich um 02:00 Uhr mit Auto-Reboot
- **Docker-Container-Updates**: Automatische Image-Aktualisierung (nutzt Standard `docker compose`)
- **Modul-Updates**: Git-basierte Module werden automatisch aktualisiert
- **Setup-Self-Updates**: Setup aktualisiert sich selbst aus GitHub

### 3. **WebUI Management**
- Modern gestaltetes Web-Interface auf Port 8080
- Echtzeit-System-Status
- Modul-Management (Installation/Deinstallation)
- Live-Konfigurationseditor
- Display-Orientierung
- Log-Viewer

### 5. **Scripts & Tools**
- Modular aufgebaute Shell-Scripts
- Python-basierte WebUI mit Flask
- Systemd-Integration für Services

### 6agicMirror-Modul**: QR-Code für mobilen Zugriff auf WebUI
- **Automatische Wiederverbindung**: Wenn konfiguriertes Netzwerk verfügbar wird
- **Dokumentation**: https://github.com/twicemind/magicmirror-wlan

### 5. **Scripts & Tools**
- Modular aufgebaute Shell-Scripts
- Python-basierte WebUI mit Flask
- Systemd-Integration für Services

### 5. **Developer Experience**
- Lokale Test-Umgebung mit Docker Compose
- GitHub Actions CI/CD
- Umfassende Dokumentation
- Contribution Guidelines

## 📁 Projektstruktur

```
magicmirror-setup/
│
├── 📄 install.sh                    # Haupt-Installationsskript
├── 📄 VERSION                       # Versionsnummer
├── 📄 CHANGELOG.md                  # Versions-Historie
│
├── 📚 Dokumentation/
│   ├── README.md                    # Haupt-Dokumentation
│   ├── INSTALLATION.md              # Schritt-für-Schritt-Anleitung
│   ├── QUICKSTART.md               # Schnellstart-Guide
│   ├── TESTING.md                  # Test-Anleitung
│   └── CONTRIBUTING.md             # Contribution Guidelines
│
├── 🔧 scripts/                     # Management-Scripts
│   ├── update-os.sh                # OS-Update-Automation
│   ├── update-docker.sh            # Docker-Container-Updates
│   ├── update-modules.sh           # Modul-Update-Automation
│   ├── install-module.sh           # Modul-Installation
│   ├── remove-module.sh            # Modul-Deinstallation
│   ├── restart-mm.sh               # Container-Neustart
│   └── set-orientation.sh          # Display-Orientierung
│
├── ⚙️ services/                    # Systemd Service-Definitionen
│   ├── mm-os-update.service        # OS-Update Service
│   ├── mm-os-update.timer          # OS-Update Timer
│   ├── mm-docker-update.service    # Docker-Update Service
│   ├── mm-docker-update.timer      # Docker-Update Timer
│   ├── mm-modules-update.service   # Modul-Update Service
│   ├── mm-modules-update.timer     # Modul-Update Timer
│   ├── mm-webui.service           # WebUI Service
│   └── mm-splash.service          # Boot-Splash Service
│
├── 🌐 webui/                       # Flask WebUI
│   ├── app.py                      # Haupt-Application
│   ├── requirements.txt            # Python-Dependencies
│   ├── Dockerfile.test             # Test-Container
│   └── templates/                  # HTML-Templates
│       ├── base.html              # Basis-Template
│       └── index.html             # Dashboard
│
├── 📦 initial-config/              # Initiale Konfiguration
│   ├── config.json                 # Beispiel MagicMirror-Config
│   └── custom.css                  # Beispiel Custom-CSS
│
├── 🧩 initial-modules/             # Initiale Module (optional)
│   ├── install-standard-modules.sh # Standard MagicMirror Module
│   ├── install-magicmirror-wlan.sh # WiFi Management System
│   └── install-pir-sensor.example.sh
│
├── 🎨 assets/                      # Assets
│   └── README.md                   # Splash-Screen-Anleitung
│
├── 🧪 test/                        # Test-Umgebung
│   ├── docker-compose.yml          # Docker Compose Setup
│   ├── README.md                   # Test-Dokumentation
│   ├── mock-config/                # Mock-Konfiguration
│   └── mock-modules/               # Mock-Module
│
└── 🤖 .github/workflows/           # GitHub Actions
    ├── release.yml                 # Release-Automation
    └── test.yml                    # CI-Tests

```

## 🚀 Schnellstart für Entwickler

### 1. Repository Setup

```bash
# Repository klonen
git clone https://github.com/twicemind/magicmirror-setup.git
cd magicmirror-setup

# Git-Historie initialisieren (falls neu)
git init
git add .
git commit -m "Initial commit: MagicMirror Setup v1.0.0"
```

### 2. Lokale Entwicklung

**WebUI entwickeln:**
```bash
cd webui
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

**Scripts testen:**
```bash
# Syntax-Check
bash -n scripts/update-os.sh

# ShellCheck
shellcheck scripts/*.sh
```

**Integration-Test:**
```bash
cd test
docker-compose up -d
# WebUI: http://localhost:8080
docker-compose down
```

### 3. GitHub Repository erstellen

```bash
# Repository auf GitHub erstellen (via Web oder gh CLI)
gh repo create twicemind/magicmirror-setup --public

# Origin setzen
git remote add origin https://github.com/twicemind/magicmirror-setup.git

# Push
git branch -M main
git push -u origin main

# Tag für ersten Release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## 🔄 Workflow

### Normaler Entwicklungs-Workflow

```bash
# Feature Branch erstellen
git checkout -b feature/neue-funktion

# Entwickeln und testen
# ... Code ändern ...
python webui/app.py  # WebUI testen

# Committen
git add .
git commit -m "feat: Beschreibung der Änderung"

# Push und PR erstellen
git push origin feature/neue-funktion
# -> GitHub PR erstellen
```

### Release-Workflow

```bash
# Version in VERSION Datei aktualisieren
echo "1.1.0" > VERSION

# CHANGELOG.md aktualisieren
# ... Änderungen dokumentieren ...

# Committen
git add VERSION CHANGELOG.md
git commit -m "chore: Bump version to 1.1.0"

# Tag erstellen
git tag -a v1.1.0 -m "Release version 1.1.0"

# Push
git push origin main
git push origin v1.1.0

# GitHub Actions erstellt automatisch Release
```

## 🧪 Testing Strategy

### 1. Lokale Tests
- Shell-Script Syntax (`bash -n`)
- ShellCheck für Best Practices
- Python Linting (flake8, black)
- JSON-Validierung

### 2. Integration Tests
- Docker Compose Umgebung
- WebUI Funktionstests
- API-Endpoint Tests

### 3. CI/CD Tests
- GitHub Actions bei jedem Push/PR
- Automatische Syntax-Checks
- Code-Quality-Checks

## 📦 Deployment

### Raspberry Pi Installation

**Methode 1: Curl (empfohlen)**
```bash
curl -fsSL https://raw.githubusercontent.com/twicemind/magicmirror-setup/main/install.sh | sudo bash
```

**Methode 2: Git**
```bash
git clone https://github.com/twicemind/magicmirror-setup.git
cd magicmirror-setup
sudo bash install.sh
```

**Methode 3: Release Archive**
```bash
wget https://github.com/twicemind/magicmirror-setup/releases/download/v1.0.0/magicmirror-setup-1.0.0.tar.gz
tar -xzf magicmirror-setup-1.0.0.tar.gz
cd magicmirror-setup-1.0.0
sudo bash install.sh
```

## 🔐 Sicherheit

### Best Practices
- Minimale Berechtigungen für Services
- Konfiguration-Backups vor Änderungen
- Logging aller Operationen
- WebUI standardmäßig nur localhost

### Empfehlungen für Produktion
- SSH-Key-Authentifizierung
- Firewall-Konfiguration (ufw)
- Reverse-Proxy mit HTTPS für WebUI
- Regelmäßige Backups

## 🐛 Bekannte Einschränkungen

1. **MagicMirrorOS spezifisch**: Designed für MagicMirrorOS, nicht für Standard Raspberry Pi OS
2. **Docker erforderlich**: Setzt Docker-Installation voraus
3. **Update-Zeit fest**: Update-Zeit (02:00) kann nur via Systemd-Timer-Editierung geändert werden
4. **WebUI ohne Auth**: Keine eingebaute Authentifizierung (sollte nur im lokalen Netzwerk verwendet werden)

## 🔮 Zukünftige Features

- [ ] MagicMirror-WLAN Projekt-Integration
- [ ] Backup/Restore Funktionalität
- [ ] Konfigurierbares Update-Zeitfenster via WebUI
- [ ] Multi-MagicMirror-Management
- [ ] Authentifizierung für WebUI
- [ ] Mobile App
- [ ] Erweiterte Monitoring-Features
- [ ] Modul-Marketplace-Integration
- [ ] Automatische Modul-Empfehlungen

## 📊 Technologie-Stack

- **Backend**: Python 3.11+ (Flask)
- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Automation**: Bash Shell Scripts
- **System Integration**: Systemd
- **Container**: Docker, Docker Compose
- **CI/CD**: GitHub Actions
- **Version Control**: Git

## 🤝 Contributing

Wir freuen uns über Contributions! Siehe [CONTRIBUTING.md](CONTRIBUTING.md) für Details.

### Hilfe benötigt bei:
- 🌍 Übersetzungen (EN, FR, ES)
- 📝 Dokumentations-Verbesserungen
- 🧪 Mehr Tests
- 🎨 WebUI Design-Verbesserungen
- 🐛 Bug-Reports und Fixes

## 📞 Support & Community

- **Issues**: https://github.com/twicemind/magicmirror-setup/issues
- **Discussions**: https://github.com/twicemind/magicmirror-setup/discussions
- **Wiki**: https://github.com/twicemind/magicmirror-setup/wiki

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE)

## 🙏 Danksagungen

- **MagicMirror²**: https://magicmirror.builders/
- **MagicMirrorOS**: https://github.com/guysoft/MagicMirrorOS
- Alle Contributors und Tester

## 📈 Projekt-Status

- ✅ **v1.0.0**: Stabil und produktionsbereit
- 🚧 **Aktiv entwickelt**: Regelmäßige Updates
- 🤝 **Open for Contributions**: PRs willkommen

---

**Entwickelt mit ❤️ für die MagicMirror Community**

**Fragen? Öffnen Sie ein Issue oder starten Sie eine Discussion!**

---

*Letzte Aktualisierung: 17. April 2026*
