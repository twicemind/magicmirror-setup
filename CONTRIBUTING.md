# Contributing to MagicMirror Setup

Vielen Dank für Ihr Interesse, zu diesem Projekt beizutragen! 🎉

## 🤝 Wie kann ich beitragen?

Es gibt viele Wege, wie Sie helfen können:

- 🐛 Bugs melden
- 💡 Neue Features vorschlagen
- 📝 Dokumentation verbessern
- 🔧 Code beitragen
- 🧪 Tests schreiben
- 🌍 Übersetzungen hinzufügen

## 📋 Bevor Sie starten

1. Prüfen Sie die [Issues](https://github.com/twicemind/magicmirror-setup/issues), ob Ihr Anliegen bereits existiert
2. Stellen Sie sicher, dass Sie die [README.md](README.md) gelesen haben
3. Machen Sie sich mit dem [Code of Conduct](CODE_OF_CONDUCT.md) vertraut

## 🔧 Entwicklungsumgebung einrichten

```bash
# Repository forken und klonen
git clone https://github.com/YOUR-USERNAME/magicmirror-setup.git
cd magicmirror-setup

# Development Branch erstellen
git checkout -b feature/meine-neue-funktion

# WebUI Entwicklungsumgebung
cd webui
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Tests ausführen (siehe TESTING.md)
```

## 📝 Pull Request Prozess

1. **Fork** des Repositories erstellen
2. **Branch** für Ihre Änderung erstellen
   ```bash
   git checkout -b feature/beschreibung
   ```
3. **Änderungen** committen mit aussagekräftigen Commit-Messages
   ```bash
   git commit -m "feat: Add new feature"
   ```
4. **Tests** hinzufügen oder aktualisieren
5. **Dokumentation** aktualisieren falls nötig
6. **Push** zu Ihrem Fork
   ```bash
   git push origin feature/beschreibung
   ```
7. **Pull Request** erstellen mit:
   - Beschreibung der Änderungen
   - Referenz zu Related Issues
   - Screenshots (falls UI-Änderungen)

## 📐 Code-Stil

### Shell Scripts
- Verwenden Sie ShellCheck
- 2 Spaces für Einrückung
- Funktionen dokumentieren
- Fehlerbehandlung mit `set -e`

```bash
#!/bin/bash
set -e

# Function description
function my_function() {
    local param="$1"
    # Implementation
}
```

### Python
- Folgen Sie PEP 8
- Verwenden Sie Black für Formatierung
- Docstrings für Funktionen
- Type hints wo möglich

```python
def my_function(param: str) -> bool:
    """
    Function description.
    
    Args:
        param: Description
    
    Returns:
        Description
    """
    pass
```

### Commit Messages

Folgen Sie [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: Neue Funktion
- `fix`: Bugfix
- `docs`: Dokumentation
- `style`: Formatierung
- `refactor`: Code-Refactoring
- `test`: Tests
- `chore`: Wartung

Beispiele:
```
feat(webui): Add module search functionality
fix(scripts): Correct update-modules.sh error handling
docs: Update installation guide with new steps
```

## 🧪 Tests

Alle Beiträge sollten Tests beinhalten:

```bash
# Shell-Script Tests
shellcheck scripts/*.sh

# Python Tests
cd webui
pytest tests/

# Integration Tests
cd test
docker-compose up -d
# Test durchführen
docker-compose down
```

## 📚 Dokumentation

- Alle neuen Features müssen dokumentiert werden
- README.md aktualisieren falls nötig
- Inline-Kommentare für komplexe Logik
- Beispiele hinzufügen

## 🐛 Bug Reports

Ein guter Bug Report sollte enthalten:

```markdown
**Beschreibung**
Eine klare Beschreibung des Bugs.

**Schritte zur Reproduktion**
1. Gehe zu '...'
2. Klicke auf '...'
3. Scrolle zu '...'
4. Fehler erscheint

**Erwartetes Verhalten**
Was sollte passieren?

**Tatsächliches Verhalten**
Was passiert stattdessen?

**Screenshots**
Falls zutreffend.

**Umgebung:**
- Raspberry Pi Modell:
- OS Version:
- Docker Version:
- Projekt Version:

**Zusätzlicher Kontext**
Logs, Konfiguration, etc.
```

## 💡 Feature Requests

Feature Requests sollten enthalten:

```markdown
**Ist Ihr Feature Request mit einem Problem verbunden?**
Beschreibung des Problems.

**Lösung**
Was Sie sich wünschen.

**Alternativen**
Andere Lösungsansätze.

**Zusätzlicher Kontext**
Screenshots, Mockups, etc.
```

## 🔍 Code Review Prozess

1. Mindestens ein Maintainer muss den PR reviewen
2. CI-Tests müssen durchlaufen
3. Keine Merge-Konflikte
4. Dokumentation ist aktualisiert
5. Tests sind hinzugefügt/aktualisiert

## 🎯 Entwicklungs-Roadmap

Siehe [GitHub Projects](https://github.com/twicemind/magicmirror-setup/projects) für geplante Features.

## 📞 Fragen?

- Öffnen Sie ein [Issue](https://github.com/twicemind/magicmirror-setup/issues)
- Diskutieren Sie in [Discussions](https://github.com/twicemind/magicmirror-setup/discussions)

## 🙏 Danksagung

Alle Contributors werden in der [README.md](README.md) erwähnt.

---

**Danke, dass Sie zu MagicMirror Setup beitragen! 🪞✨**
