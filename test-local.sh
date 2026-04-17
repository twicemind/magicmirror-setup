#!/bin/bash

# Lokaler Test-Script für MagicMirror Setup
# Startet die WebUI im Test-Modus auf Ihrem Mac

set -e

echo "🧪 MagicMirror Setup - Lokaler Test"
echo ""

# Prüfe ob Python installiert ist
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 ist nicht installiert"
    exit 1
fi

# Wechsle ins Projektverzeichnis
cd "$(dirname "$0")"

echo "📦 Erstelle Test-Verzeichnisse..."
mkdir -p /tmp/mm-test/{config,modules}
echo '{"address":"localhost","port":8080,"language":"de","modules":[{"module":"clock","position":"top_left"}]}' > /tmp/mm-test/config/config.json

# Erstelle Mock-Module
mkdir -p /tmp/mm-test/modules/MMM-TestModule
cat > /tmp/mm-test/modules/MMM-TestModule/package.json << 'EOF'
{
  "name": "MMM-TestModule",
  "version": "1.0.0",
  "description": "Test module for local testing"
}
EOF

echo "✅ Test-Verzeichnisse erstellt"
echo ""

# Prüfe ob venv existiert
if [ ! -d "webui/venv" ]; then
    echo "📦 Installiere Python-Abhängigkeiten..."
    cd webui
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd ..
    echo "✅ Abhängigkeiten installiert"
    echo ""
fi

echo "🚀 Starte WebUI im Test-Modus..."
echo ""
echo "Die WebUI wird verfügbar sein unter:"
echo "👉 http://localhost:8080"
echo ""
echo "Drücken Sie Ctrl+C zum Beenden"
echo ""

cd webui
source venv/bin/activate
python test_app.py
