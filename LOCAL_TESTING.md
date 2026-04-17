# 🧪 Lokales Testen auf dem Mac

Sie können das MagicMirror Setup-Projekt vollständig lokal auf Ihrem Mac testen, ohne einen Raspberry Pi zu benötigen!

## 🚀 Schnellstart

### Option 1: Test-Script verwenden (empfohlen)

```bash
./test-local.sh
```

Das Script:
- ✅ Erstellt automatisch Test-Verzeichnisse
- ✅ Installiert Python-Abhängigkeiten (beim ersten Mal)
- ✅ Startet die WebUI im Test-Modus
- ✅ Öffnet automatisch auf Port 8080

### Option 2: Manuelle Einrichtung

```bash
# 1. Python Virtual Environment erstellen
cd webui
python3 -m venv venv
source venv/bin/activate

# 2. Abhängigkeiten installieren
pip install -r requirements.txt

# 3. Test-WebUI starten
python test_app.py
```

## 🌐 WebUI öffnen

Nach dem Start öffnen Sie in Ihrem Browser:

```
http://localhost:8080
```

## ✨ Was können Sie testen?

### 1. **Dashboard & Status**
- System-Status-Anzeige
- Container-Status (Mock)
- Timer-Status (Mock)

### 2. **Modul-Management**
- Module anzeigen (Test-Module)
- "Neue Module installieren" (simuliert)
- Module entfernen (simuliert)

### 3. **Konfiguration**
- Config.json bearbeiten
- Änderungen speichern (lokal in `/tmp/mm-test/config/`)
- JSON-Syntax-Validierung

### 4. **System-Updates**
- OS-Update triggern (simuliert)
- Docker-Update triggern (simuliert)
- Module-Update triggern (simuliert)

### 5. **Display-Einstellungen**
- Orientierung ändern (simuliert)

### 6. **Logs**
- Log-Viewer testen

## 📁 Test-Verzeichnisse

Alle Test-Daten werden in `/tmp/mm-test/` gespeichert:

```
/tmp/mm-test/
├── config/
│   └── config.json          # Test-Konfiguration
├── modules/
│   └── MMM-TestModule/      # Test-Modul
└── setup.log                # Test-Logs
```

## ⚠️ Wichtig: Test-Modus

Die WebUI läuft im **TEST-MODUS**:
- ✅ Alle API-Endpoints funktionieren
- ✅ Konfiguration kann bearbeitet werden
- ⚠️ System-Operationen werden **simuliert** (nicht ausgeführt)
- ⚠️ Änderungen betreffen **nicht** Ihr System

Sie werden folgende Hinweise sehen:
- `[TEST MODE]` in Erfolgsbenachrichtigungen
- Status zeigt `test_mode: true`
- Scripts werden geloggt aber nicht ausgeführt

## 🧩 Test-Module hinzufügen

Sie können eigene Test-Module erstellen:

```bash
# Erstellen Sie ein Mock-Modul
mkdir -p /tmp/mm-test/modules/MMM-MeinModul
cat > /tmp/mm-test/modules/MMM-MeinModul/package.json << 'EOF'
{
  "name": "MMM-MeinModul",
  "version": "1.0.0",
  "description": "Mein Test-Modul"
}
EOF

# Die WebUI wird es automatisch anzeigen (nach Reload)
```

## 🐋 Docker-basiertes Testing

Für ein vollständiges Test-Setup mit Docker:

```bash
cd test
docker-compose up -d
```

Dann öffnen: `http://localhost:8080`

Zum Stoppen:
```bash
docker-compose down
```

## 🔧 Entwicklung & Debugging

### Live-Reload während Entwicklung

Die Test-WebUI läuft im Debug-Modus:
- Auto-reload bei Code-Änderungen
- Detaillierte Fehler-Ausgaben
- Debugger-PIN wird angezeigt

### Logs ansehen

```bash
# Terminal-Ausgabe zeigt alle API-Calls
# Beispiel:
# INFO - Would run: update-os.sh
# INFO - Would install module from: https://...
```

### Frontend-Änderungen testen

1. Editieren Sie `webui/templates/*.html`
2. Browser aktualisieren (F5)
3. Änderungen sind sofort sichtbar

### Backend-Änderungen testen

1. Editieren Sie `webui/test_app.py`
2. Flask lädt automatisch neu
3. API-Änderungen sind sofort verfügbar

## 📊 Was wird getestet?

✅ **Frontend**
- UI-Layout und Design
- Formular-Validierung
- API-Integration
- Fehlerbehandlung

✅ **Backend**
- API-Endpoints
- JSON-Verarbeitung
- Fehlerbehandlung
- Logging

✅ **Integration**
- Frontend ↔ Backend Kommunikation
- Datenfluss
- User Experience

❌ **Nicht getestet (Raspberry Pi spezifisch)**
- Tatsächliche System-Updates
- Docker-Container-Management
- Systemd-Services
- Raspberry Pi Hardware

## 🛠️ Troubleshooting

### Port bereits belegt

Wenn Port 8080 belegt ist, ändern Sie in `webui/test_app.py`:

```python
app.run(host='0.0.0.0', port=8082, debug=True)
```

### Python-Module fehlen

```bash
cd webui
source venv/bin/activate
pip install -r requirements.txt
```

### Virtual Environment Probleme

```bash
cd webui
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 🎯 Nächste Schritte

Nach erfolgreichem lokalem Test:

1. ✅ Code auf GitHub pushen
2. ✅ Auf Raspberry Pi mit echtem MagicMirrorOS testen
3. ✅ Feedback sammeln und verbessern

## 💡 Tipps

- **Browser-Developer-Tools** (F12) nutzen für Debugging
- **Network-Tab** zeigt alle API-Calls
- **Console** zeigt JavaScript-Fehler
- **Mehrere Browser** testen (Chrome, Firefox, Safari)

## 🔗 Weitere Ressourcen

- Vollständige Tests: [TESTING.md](TESTING.md)
- Docker-Tests: [test/README.md](test/README.md)
- Projekt-Dokumentation: [README.md](README.md)

---

**Viel Spaß beim lokalen Testen! 🧪✨**

*Das lokale Testing ermöglicht schnelle Iterationen ohne Raspberry Pi Hardware!*
