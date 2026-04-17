# 🎉 WebUI Update - Neue Features

## Version 1.1.0 - Was ist neu?

### 1. 🏷️ Hostname im Dashboard

Der Header der WebUI zeigt jetzt den Namen Ihres Raspberry Pi an:

**Vorher:**
```
🪞 MagicMirror Setup Dashboard
```

**Jetzt:**
```
🪞 raspberry-mirror - MagicMirror Setup
```

- Automatische Erkennung des Hostnamens
- Bessere Übersicht bei mehreren MagicMirror-Installationen
- Wird dynamisch beim Laden aktualisiert

---

### 2. 📱 Responsive Design

Die WebUI ist jetzt vollständig responsive und funktioniert auf allen Geräten:

**Desktop (> 768px)**
- Volle Grid-Ansicht
- Alle Features nebeneinander
- Optimale Nutzung des Bildschirms

**Tablet (768px - 480px)**
- Angepasste Grid-Größen
- Größere Touch-Targets
- Optimierte Navigation

**Mobile (< 480px)**
- Vertikales Layout
- Full-width Buttons
- Touch-optimierte Bedienung

**Technische Details:**
- Breakpoints bei 768px und 480px
- Min-max Grid-Einstellungen für flexible Layouts
- Touch-freundliche Button-Größen

---

### 3. 🔄 Setup Self-Updates aus GitHub

Die WebUI kann sich jetzt selbst aktualisieren!

#### Features:

**Automatische Update-Prüfung:**
- Beim Laden der WebUI
- Alle 5 Minuten im Hintergrund
- Zeigt verfügbare Updates an

**Manuelle Update-Prüfung:**
- Button "Check for Updates"
- Zeigt aktuelle vs. neueste Version
- Visuelles Feedback mit Farben

**Update-Installation:**
- Ein-Klick-Update aus der WebUI
- Backup der aktuellen Version
- Automatischer Neustart der WebUI

**Automatische Updates:**
- Täglich um 02:00 Uhr zusammen mit anderen Updates
- Systemd-Timer: `mm-setup-update.timer`
- Logs werden geschrieben

#### Neue UI-Elemente:

**Status-Karte:**
```
┌─────────────────────────┐
│ Setup Version           │
│ 1.0.0                   │
└─────────────────────────┘
```

**Update-Karte:**
```
┌─────────────────────────────────────┐
│ 🔄 Setup Update                     │
│                                     │
│ 🆕 Update available!                │
│ Current: v1.0.0 → Latest: v1.1.0   │
│                                     │
│ [Check for Updates] [Update Setup] │
│                                     │
│ ⏰ Auto-updates with system updates │
└─────────────────────────────────────┘
```

#### Backend:

**Neue Scripts:**
- `scripts/update-setup.sh` - Führt Update durch
- `scripts/check-setup-update.sh` - Prüft GitHub Releases

**Neue API-Endpoints:**
- `GET /api/setup/check-update` - Prüft Updates
- `POST /api/setup/update` - Führt Update durch

**Neue Systemd-Services:**
- `mm-setup-update.service`
- `mm-setup-update.timer`

---

## 🚀 Wie verwenden?

### Setup-Update prüfen:

1. WebUI öffnen: `http://<raspberry-pi-ip>:8080`
2. Zur Karte "Setup Update" scrollen
3. Button "Check for Updates" klicken
4. Bei verfügbarem Update erscheint der Button "Update Setup"

### Setup aktualisieren:

1. Button "Update Setup" klicken
2. Bestätigen im Dialog
3. Update läuft automatisch (ca. 1-2 Minuten)
4. WebUI lädt automatisch neu
5. Fertig! ✅

### Automatische Updates konfigurieren:

Die automatischen Updates sind bereits aktiviert! Prüfen mit:

```bash
# Timer-Status anzeigen
systemctl list-timers | grep mm-setup

# Logs ansehen
journalctl -u mm-setup-update.service
```

---

## 📊 Technical Details

### Responsive CSS:

```css
/* Mobile Breakpoint */
@media (max-width: 768px) {
    .grid {
        gap: 15px;
    }
    .button-group {
        flex-direction: column;
    }
    .button {
        width: 100%;
    }
}
```

### Update-Check Flow:

```
WebUI Load
    ↓
Check GitHub API
    ↓
Compare Versions
    ↓
Show Update Badge (if available)
    ↓
User clicks "Update Setup"
    ↓
Download from GitHub
    ↓
Backup current version
    ↓
Install new version
    ↓
Restart WebUI
    ↓
Done!
```

### Version Comparison:

```bash
# Aktuell: /opt/magicmirror-setup/VERSION
# Neueste: GitHub API (releases/latest)
# Vergleich: String-basiert
```

---

## 🧪 Lokales Testen

Die neuen Features können auch lokal getestet werden:

```bash
./test-local.sh
# WebUI öffnen: http://localhost:8080
```

**Im Test-Modus:**
- Hostname wird von Ihrem Mac angezeigt
- Setup-Updates sind simuliert
- Responsive Design funktioniert voll

---

## 📝 Weitere Verbesserungen

- Bessere Fehlerbehandlung
- Verbesserte Benachrichtigungen
- Optimierte Performance
- Klarere Logging-Ausgaben

---

## 🔧 Installation der neuen Version

Wenn Sie bereits eine ältere Version installiert haben:

```bash
# Manuelles Update
sudo /opt/magicmirror-setup/scripts/update-setup.sh

# Oder warten Sie bis 02:00 Uhr (automatisch)

# Oder nutzen Sie die WebUI! 🎉
```

---

## 📖 Dokumentation

- [README.md](README.md) - Vollständige Dokumentation
- [LOCAL_TESTING.md](LOCAL_TESTING.md) - Lokales Testen
- [INSTALLATION.md](INSTALLATION.md) - Installationsanleitung

---

**Viel Spaß mit den neuen Features! 🎉✨**
