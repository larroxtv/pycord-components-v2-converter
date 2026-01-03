# Py-Cord Components v2 Converter

Ein PowerShell-Tool zur automatischen Konvertierung von Discord.py/py-cord Bot-Code von Components v1 zu v2.

## 🎯 Was macht dieses Tool?

Dieses Tool hilft dir dabei, deinen Discord-Bot von der veralteten DesignerView-API zu den neuen Standard-Discord-Components zu migrieren.

### ✅ Automatische Konvertierungen:
- ✅ Installiert/Aktualisiert **py-cord auf Version 2.7.0**
- ✅ Konvertiert `DesignerView` → `discord.ui.View`
- ✅ Entfernt veraltete Imports (`Container`, `TextDisplay`, `ActionRow`)
- ✅ Korrigiert `ButtonStyle.gray` → `ButtonStyle.grey`
- ✅ Erstellt **automatische Backups** (.backup Dateien)

### ⚠️ Manuelle Nacharbeit erforderlich:
- `Container()` und `TextDisplay()` müssen zu `discord.Embed` konvertiert werden
- Siehe `CONVERSION_GUIDE.md` für detaillierte Beispiele

## 🚀 Schnellstart

### 1. Skript in dein Projekt kopieren
```powershell
# Kopiere convert_components_v2.ps1 und CONVERSION_GUIDE.md in dein Projektverzeichnis
```

### 2. PowerShell öffnen und navigieren
```powershell
cd C:\Pfad\zu\deinem\Bot-Projekt
```

### 3. Skript ausführen
```powershell
.\convert_components_v2.ps1
```

### 4. Option wählen
```
[1] Alle Python-Dateien im aktuellen Verzeichnis konvertieren
[2] Eine spezifische Datei konvertieren
[3] Nur py-cord aktualisieren (keine Konvertierung)
```

## 📚 Dateien in diesem Package

- **`convert_components_v2.ps1`** - Haupt-Konvertierungsskript
- **`CONVERSION_GUIDE.md`** - Detaillierte Anleitung mit Code-Beispielen
- **`README_CONVERTER.md`** - Diese Datei (Übersicht)

## 💡 Beispiel-Workflow

```powershell
# 1. Navigiere zu deinem Bot-Projekt
cd C:\MeinBot

# 2. Führe das Skript aus
.\convert_components_v2.ps1

# 3. Wähle Option 1 für alle Dateien
Ihre Wahl (1/2/3): 1

# 4. Überprüfe die Logs und konvertiere Container manuell
# 5. Teste deinen Bot
python main.py

# 6. Lösche Backups wenn alles funktioniert
Remove-Item *.backup -Recurse
```

## 🔄 Backup wiederherstellen

Falls etwas schief geht:

```powershell
# Einzelne Datei wiederherstellen:
Move-Item "meine_datei.py.backup" "meine_datei.py" -Force

# ALLE Backups wiederherstellen:
Get-ChildItem -Filter "*.backup" -Recurse | ForEach-Object { 
    Move-Item $_.FullName ($_.FullName -replace '\.backup$','') -Force 
}
```

## 📖 Wichtige Code-Änderungen

### DesignerView → discord.ui.View
```python
# ALT:
class MyView(DesignerView):
    pass

# NEU:
class MyView(discord.ui.View):
    pass
```

### Container/TextDisplay → Embed
```python
# ALT:
container = Container(
    TextDisplay("Titel"),
    TextDisplay("Beschreibung")
)

# NEU:
embed = discord.Embed(
    title="Titel",
    description="Beschreibung",
    color=discord.Color.blue()
)
```

### Buttons
```python
# ALT:
container.add_item(ActionRow(button))

# NEU:
self.add_item(button)  # oder als @discord.ui.button Decorator
```

## 🐛 Troubleshooting

### Fehler: "py-cord not found"
```powershell
python -m pip install py-cord==2.7.0
```

### Fehler: "DesignerView not found"
➡️ Gut! Das bedeutet die Konvertierung war erfolgreich. Entferne alle `DesignerView` Imports.

### Fehler: "Container not found"
➡️ Konvertiere alle `Container()` Verwendungen zu `discord.Embed`. Siehe `CONVERSION_GUIDE.md`.

### Fehler: "Components displayable text size exceeds maximum size of 4000"
➡️ Dein Text ist zu lang. Teile Informationen auf mehrere Embed-Fields auf oder verwende mehrere Nachrichten.

## 🔗 Nützliche Links

- [py-cord Dokumentation](https://docs.pycord.dev/)
- [Discord Embed Dokumentation](https://docs.pycord.dev/en/stable/api/models.html#discord.Embed)
- [UI Components Guide](https://docs.pycord.dev/en/stable/api/ui_kit.html)
- [Migration Guide](https://docs.pycord.dev/en/stable/migrating.html)

## ⚡ Quick Reference

| v1 (Veraltet) | v2 (Aktuell) |
|---------------|--------------|
| `DesignerView` | `discord.ui.View` |
| `Container()` | `discord.Embed()` |
| `TextDisplay()` | `embed.add_field()` |
| `ActionRow(button)` | `self.add_item(button)` |
| `ButtonStyle.gray` | `ButtonStyle.grey` |

## 📝 Lizenz

Dieses Tool ist frei verwendbar für alle Discord-Bot-Projekte.

## 🤝 Support

Bei Fragen oder Problemen:
1. Überprüfe [CONVERSION_GUIDE.md](https://github.com/larroxtv/pycord-components-v2-converter/blob/main/CONVERSION_GUIDE.md) für detaillierte Beispiele
2. Suche in der [py-cord Dokumentation](https://docs.pycord.dev/)
3. Stelle sicher, dass py-cord 2.7.0 installiert ist

---

**Viel Erfolg bei der Migration! 🚀**

