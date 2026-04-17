# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in dieser Datei dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/),
und dieses Projekt folgt [Semantic Versioning](https://semver.org/lang/de/).

## [Unreleased]

## [1.15.0] - 2026-04-17

### Added
- **WiFi Management Integration**: MagicMirror WLAN Manager wird automatisch installiert
  - Neues Installations-Script: `initial-modules/install-magicmirror-wlan.sh`
  - Automatische Netzwerk-Überwachung (alle 30 Sekunden)
  - HotSpot-Fallback bei fehlender Internetverbindung
  - Web-basierte WiFi-Konfiguration (Port 8765)
  - WiFi-Scanner und Netzwerk-Auswahl
  - MagicMirror-Modul (MMM-WLANManager) mit QR-Code
  - Automatische Wiederverbindung wenn Netzwerk verfügbar
  - Integration mit https://github.com/twicemind/magicmirror-wlan
- **Dokumentation**: Umfassende WiFi-Management-Dokumentation in README.md und PROJECT_OVERVIEW.md
- **Services**: Automatische Installation von `wlan-network-monitor.service` und `wlan-webui.service`

### Changed
- Updated documentation to reflect WiFi management capabilities
- Removed "MagicMirror-WLAN Projekt-Integration" from future features (now implemented)

## [1.2.0] - 2026-04-17

### Added
- **Tab-Navigation**: WebUI jetzt mit 5 übersichtlichen Tabs organisiert
  - 📊 Dashboard (Updates & Container Control)
  - 🧩 Modules (Modul-Management)
  - ⚙️ Configuration (Config-Editor)
  - 🖥️ Settings (Display-Einstellungen)
  - 📋 Logs (System-Logs)
- **Horizontales Scrolling** für Tabs auf mobilen Geräten
- **Lazy Loading** für Tab-Content (Daten werden nur bei Bedarf geladen)

### Improved
- **Responsive Design** deutlich verbessert:
  - Single-Column Layout auf Mobile (< 480px)
  - Stack-Layout für Status-Cards auf Tablet/Mobile
  - Full-width Buttons auf kleinen Bildschirmen
  - Bessere Touch-Targets (größere Buttons)
- **Navigation** übersichtlicher und schneller
- **Performance** durch Lazy Loading verbessert
- **User Experience** fokussierter durch Tab-basierte Organisation

### Changed
- Grid von `minmax(400px, 1fr)` zu `minmax(350px, 100%)`
- Status-Bar nutzt jetzt `flex-direction: column` auf Mobile
- Tab-Content wird dynamisch geladen statt alles initial zu rendern

## [1.1.0] - 2026-04-17

### Added
- **Hostname-Anzeige im Dashboard**: Der Raspberry-Name wird nun im Header der WebUI angezeigt
- **Responsive Design**: WebUI ist jetzt vollständig responsive für Desktop, Tablet und Mobile
- **Setup Self-Updates**: Automatische Updates des Setups selbst aus GitHub
  - Neues Script `update-setup.sh` für automatische Updates
  - Neues Script `check-setup-update.sh` für Update-Prüfung
  - Neue Systemd-Services: `mm-setup-update.service` und `mm-setup-update.timer`
  - WebUI-Integration mit Update-Karte und Status-Anzeige
  - API-Endpoints: `/api/setup/check-update` und `/api/setup/update`
- **Update-Benachrichtigungen**: Visuelles Feedback in der WebUI bei verfügbaren Updates
- **Automatische Update-Prüfung**: Alle 5 Minuten prüft die WebUI auf Setup-Updates
- **Version-Anzeige**: Setup-Version wird in der Status-Bar angezeigt

### Changed
- Header zeigt jetzt Hostname statt statischem Text
- Grid-Layout nutzt responsive min-max()-Funktionen
- Buttons werden auf Mobile zu Full-Width
- Status-Bar zeigt nun auch Setup-Version

### Improved
- Bessere Mobile-Erfahrung mit Touch-optimierten Elementen
- Klarere Update-Workflows
- Erweiterte Dokumentation (WHATS_NEW.md)

## [1.0.0] - 2026-04-17

### Added
- Initial release
- Haupt-Installationsskript mit vollständiger Setup-Automatisierung
- Automatische OS-Updates via systemd Timer (täglich um 02:00)
- Automatische Docker-Container-Updates
- Automatische MagicMirror-Modul-Updates
- WebUI mit Flask für Management:
  - System-Status Dashboard
  - Manuelle Update-Trigger
  - Modul-Management (Installation/Deinstallation)
  - Konfigurationseditor für config.json
  - Display-Orientierung-Einstellungen
  - Log-Viewer
- Management-Scripts:
  - `install-module.sh` - Modul-Installation
  - `remove-module.sh` - Modul-Deinstallation
  - `update-os.sh` - OS-Updates
  - `update-docker.sh` - Docker-Updates
  - `update-modules.sh` - Modul-Updates
  - `restart-mm.sh` - Container-Neustart
  - `set-orientation.sh` - Display-Orientierung
- Systemd-Services und Timer:
  - mm-os-update.service/timer
  - mm-docker-update.service/timer
  - mm-modules-update.service/timer
  - mm-webui.service
  - mm-splash.service
- Boot-Splash-Screen-Support
- Initiale Konfigurations-Templates
- Vollständige Dokumentation:
  - README.md mit umfassender Übersicht
  - INSTALLATION.md mit Schritt-für-Schritt-Anleitung
  - TESTING.md für lokales Testing
  - QUICKSTART.md für schnelle Installation
  - CONTRIBUTING.md für Contributors
- GitHub Actions Workflows:
  - Automatische Releases
  - Code-Tests (ShellCheck, Python, JSON)
  - Integration-Tests
- Docker Compose Setup für lokales Testing
- Beispiel-Konfigurationen und Module

### Security
- WebUI läuft standardmäßig nur auf localhost
- Alle Scripts mit Fehlerbehandlung (set -e)
- Konfiguration-Backups vor Änderungen

[Unreleased]: https://github.com/twicemind/magicmirror-setup/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/twicemind/magicmirror-setup/releases/tag/v1.0.0
