# 🧪 MagicMirror Setup - Testing Guide

Anleitung zum lokalen Testen des MagicMirror Setup Projekts ohne Raspberry Pi Hardware.

## 🎯 Überblick

Diese Sandbox-Umgebung ermöglicht es Ihnen:
- Das Setup lokal zu testen
- Änderungen zu validieren, bevor sie auf dem Raspberry Pi deployed werden
- Die WebUI zu entwickeln und zu testen
- Scripts zu testen

## 📋 Voraussetzungen

- Docker und Docker Compose installiert
- Git
- Python 3.9 oder neuer
- Ein Unix-basiertes System (Linux, macOS) oder WSL2 auf Windows

## 🚀 Quick Start

### 1. Repository klonen

```bash
git clone https://github.com/twicemind/magicmirror-setup.git
cd magicmirror-setup
```

### 2. Test-Umgebung starten

```bash
cd test
docker-compose up -d
```

Dies startet:
- Einen simulierten MagicMirror-Container
- Die WebUI
- Ein Test-Netzwerk

### 3. WebUI zugreifen

Öffnen Sie in Ihrem Browser:
```
http://localhost:8080
```

## 🔧 Detaillierte Testszenarien

### Test 1: WebUI Entwicklung

```bash
cd webui

# Virtual Environment erstellen
python3 -m venv venv
source venv/bin/activate  # Auf Windows: venv\Scripts\activate

# Dependencies installieren
pip install -r requirements.txt

# WebUI starten
python app.py
```

Die WebUI läuft nun auf http://localhost:8080

**Änderungen testen:**
1. Editieren Sie `app.py` oder Templates
2. Starten Sie die App neu (Strg+C und dann `python app.py`)
3. Aktualisieren Sie den Browser

### Test 2: Script-Validierung

```bash
# Syntax-Prüfung aller Shell-Scripts
for script in scripts/*.sh install.sh; do
    echo "Checking $script"
    bash -n "$script"
done

# ShellCheck (erweiterte Prüfung)
shellcheck scripts/*.sh install.sh
```

### Test 3: JSON-Validierung

```bash
# config.json validieren
jq empty initial-config/config.json && echo "Valid JSON"

# Alle JSON-Dateien prüfen
find . -name "*.json" -exec sh -c 'jq empty "{}" && echo "✓ {}"' \;
```

### Test 4: Docker Container Tests

```bash
cd test

# Container starten
docker-compose up -d

# Container-Logs ansehen
docker-compose logs -f

# In Container einsteigen
docker exec -it test-mm bash

# Container stoppen
docker-compose down
```

### Test 5: Module Installation Test (Mock)

```bash
# Erstellen Sie einen Mock-Module-Test
cd test

# Simulieren Sie ein Modul im test/modules Verzeichnis
mkdir -p mock-modules/MMM-TestModule
cd mock-modules/MMM-TestModule

# Erstellen Sie ein einfaches Test-Modul
cat > package.json << 'EOF'
{
  "name": "MMM-TestModule",
  "version": "1.0.0",
  "description": "Test module"
}
EOF

# Testen Sie die Modul-Management-Scripts (angepasst für lokale Umgebung)
```

## 🐳 Docker Compose Setup

### Struktur

Die Test-Umgebung verwendet folgende Container:

```yaml
test-mm:       # Simulierter MagicMirror Container
test-webui:    # WebUI für Testing
```

### Container starten

```bash
cd test
docker-compose up -d
```

### Container logs

```bash
docker-compose logs -f test-webui
```

### Container neu starten

```bash
docker-compose restart
```

### Container stoppen

```bash
docker-compose down
```

## 🔍 Spezifische Tests

### WebUI API Tests

```bash
cd webui

# Status-Endpoint testen
curl http://localhost:8080/api/status

# Module-Endpoint testen
curl http://localhost:8080/api/modules

# Config-Endpoint testen
curl http://localhost:8080/api/config
```

### Python Code Quality

```bash
cd webui
source venv/bin/activate

# Code formatieren mit Black
black app.py

# Linting mit flake8
flake8 app.py --max-line-length=120

# Type checking mit mypy (optional)
pip install mypy
mypy app.py --ignore-missing-imports
```

### Shell Script Tests

```bash
# Syntax-Check
bash -n scripts/update-os.sh

# ShellCheck für Best Practices
shellcheck scripts/update-os.sh

# Mit spezifischen Optionen
shellcheck -s bash -e SC2086,SC2181 scripts/*.sh
```

## 📊 Automatisierte Tests

### GitHub Actions lokal ausführen

Mit [act](https://github.com/nektos/act):

```bash
# act installieren
brew install act  # macOS
# oder siehe: https://github.com/nektos/act#installation

# Tests ausführen
act -j shellcheck
act -j python-validation
act -j json-validation
```

### Pre-commit Hooks

```bash
# Pre-commit installieren
pip install pre-commit

# Hook-Konfiguration erstellen
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: check-json
      - id: check-yaml
      - id: end-of-file-fixer
      - id: trailing-whitespace
  
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
  
  - repo: https://github.com/psf/black
    rev: 23.12.0
    hooks:
      - id: black
        language_version: python3.11
EOF

# Hooks installieren
pre-commit install

# Manuell ausführen
pre-commit run --all-files
```

## 🧪 Integrationstests

### Test-Szenario 1: Vollständige Installation (simuliert)

```bash
# Test-Verzeichnis erstellen
mkdir -p /tmp/magicmirror-test
cd /tmp/magicmirror-test

# Setup klonen
git clone https://github.com/twicemind/magicmirror-setup.git
cd magicmirror-setup

# Dry-run des Installations-Scripts (ohne tatsächliche Installation)
# Dies erfordert Anpassungen im Script für Test-Modus
```

### Test-Szenario 2: WebUI Funktionalität

```python
# test/test_webui.py
import requests

def test_webui_status():
    response = requests.get('http://localhost:8080/api/status')
    assert response.status_code == 200
    data = response.json()
    assert 'timestamp' in data

def test_webui_modules():
    response = requests.get('http://localhost:8080/api/modules')
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

Ausführen:
```bash
pip install pytest requests
pytest test/test_webui.py
```

## 📝 Test-Checkliste

Vor einem Release sollten folgende Tests durchgeführt werden:

### Code Quality
- [ ] ShellCheck für alle Shell-Scripts
- [ ] Python Linting (flake8/black)
- [ ] JSON-Validierung

### Funktionalität
- [ ] WebUI startet ohne Fehler
- [ ] Alle API-Endpoints antworten
- [ ] Frontend lädt korrekt
- [ ] Scripts haben korrekte Syntax

### Integration
- [ ] Docker Compose Setup funktioniert
- [ ] GitHub Actions laufen durch
- [ ] Release-Workflow funktioniert

### Dokumentation
- [ ] README ist aktuell
- [ ] INSTALLATION ist vollständig
- [ ] Beispiel-Konfigurationen sind gültig

## 🐛 Troubleshooting

### WebUI startet nicht

```bash
cd webui
source venv/bin/activate
python app.py
# Fehler werden in der Konsole angezeigt
```

### Docker Container starten nicht

```bash
cd test
docker-compose logs
# Prüfen Sie die Logs auf Fehler
```

### Port-Konflikte

```bash
# Prüfen Sie, ob Port 8080 bereits verwendet wird
lsof -i :8080

# Ändern Sie den Port in docker-compose.yml
```

## 🔄 Continuous Testing

### Watch Mode für Entwicklung

```bash
# WebUI mit Auto-Reload
cd webui
export FLASK_ENV=development
export FLASK_DEBUG=1
python app.py
```

### File Watcher für Scripts

```bash
# Mit entr (installieren Sie es zuerst)
ls scripts/*.sh | entr -r shellcheck /_
```

## 📚 Weitere Ressourcen

- [Docker Compose Dokumentation](https://docs.docker.com/compose/)
- [Flask Testing](https://flask.palletsprojects.com/en/2.3.x/testing/)
- [ShellCheck](https://www.shellcheck.net/)
- [pytest Dokumentation](https://docs.pytest.org/)

---

## ✅ Best Practices

1. **Testen Sie lokal vor dem Push**
   ```bash
   ./scripts/run-all-tests.sh  # Wenn vorhanden
   ```

2. **Verwenden Sie Feature Branches**
   ```bash
   git checkout -b feature/neue-funktion
   ```

3. **Schreiben Sie aussagekräftige Commit-Messages**
   ```bash
   git commit -m "feat: Add module auto-update feature"
   ```

4. **Dokumentieren Sie Änderungen**
   - README.md aktualisieren
   - INSTALLATION.md bei Bedarf anpassen
   - Kommentare in Code hinzufügen

---

**Viel Erfolg beim Testen! 🧪✨**
