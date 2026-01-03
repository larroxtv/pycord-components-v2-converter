# Discord Components v1 zu v2 Konvertierungs-Guide

## Schnellstart

### PowerShell-Skript ausführen:
```powershell
cd C:\Pfad\zu\deinem\Projekt
.\convert_components_v2.ps1
```

## Was das Skript automatisch macht:

✅ Installiert/Aktualisiert py-cord auf Version 2.7.0
✅ Konvertiert `DesignerView` zu `discord.ui.View`
✅ Entfernt veraltete Imports (Container, TextDisplay, ActionRow)
✅ Korrigiert ButtonStyle-Verwendung
✅ Erstellt automatisch Backups (.backup Dateien)

## Was manuell gemacht werden muss:

### 1. Container + TextDisplay zu Embed konvertieren

#### ALT (v1):
```python
class MyView(DesignerView):
    def __init__(self):
        super().__init__()
        container = Container(
            TextDisplay("## Titel"),
            TextDisplay("Hier ist eine Beschreibung mit wichtigen Informationen.")
        )
        self.add_item(container)
```

#### NEU (v2):
```python
class MyView(discord.ui.View):
    def __init__(self):
        super().__init__()
        
# Erstelle stattdessen ein Embed und sende es direkt:
embed = discord.Embed(
    title="Titel",
    description="Hier ist eine Beschreibung mit wichtigen Informationen.",
    color=discord.Color.blue()
)

embed.add_field(
    name="📌 Kategorie 1",
    value="Inhalt für Kategorie 1",
    inline=False
)

embed.add_field(
    name="🔧 Kategorie 2",
    value="Inhalt für Kategorie 2",
    inline=False
)

await interaction.response.send_message(embed=embed, ephemeral=True)
```

### 2. Buttons direkt zur View hinzufügen

#### ALT (v1):
```python
container.add_item(ActionRow(button))
```

#### NEU (v2):
```python
# Methode 1: Buttons als Decorator in der View-Klasse:
class MyView(discord.ui.View):
    @discord.ui.button(label="Klick mich", style=discord.ButtonStyle.primary)
    async def button_callback(self, button, interaction):
        await interaction.response.send_message("Button wurde geklickt!", ephemeral=True)

# Methode 2: Button manuell hinzufügen:
class MyView(discord.ui.View):
    def __init__(self):
        super().__init__()
        
        button = discord.ui.Button(label="Klick mich", style=discord.ButtonStyle.primary)
        button.callback = self.my_callback
        self.add_item(button)
    
    async def my_callback(self, interaction):
        await interaction.response.send_message("Button wurde geklickt!", ephemeral=True)
```

## Wichtige Änderungen in py-cord 2.7.0:

1. **DesignerView wurde entfernt** - Nutze `discord.ui.View`
2. **Container/TextDisplay wurden entfernt** - Nutze `discord.Embed`
3. **ActionRow ist nicht mehr nötig** - Discord handhabt das automatisch
4. **ButtonStyle.gray** → **ButtonStyle.grey** (britisches Englisch)

## Backup wiederherstellen:

Falls etwas schief geht:

```powershell
# Einzelne Datei:
Move-Item "meine_datei.py.backup" "meine_datei.py" -Force

# Alle Backups wiederherstellen:
Get-ChildItem -Filter "*.backup" -Recurse | ForEach-Object { 
    Move-Item $_.FullName ($_.FullName -replace '\.backup$','') -Force 
}
```

## Beispiel: Vollständige View-Konvertierung

### Vorher (v1):
```python
from discord.ui import DesignerView, Container, TextDisplay, ActionRow

class ServerInfoView(DesignerView):
    def __init__(self):
        super().__init__()
        container = Container(
            TextDisplay("## 🎮 Server Informationen"),
            TextDisplay(
                "**Willkommen auf unserem Server!**\n\n"
                "Hier findest du alle wichtigen Informationen."
            ),
            TextDisplay(
                "📋 **Befehle:**\n"
                "- /help - Zeigt diese Hilfe\n"
                "- /info - Server-Informationen\n"
                "- /rules - Serverregeln"
            )
        )
        
        # Button hinzufügen
        button = discord.ui.Button(label="Mehr erfahren", style=discord.ButtonStyle.primary)
        button.callback = self.button_clicked
        container.add_item(ActionRow(button))
        
        self.add_item(container)
    
    async def button_clicked(self, interaction):
        await interaction.response.send_message("Weitere Informationen...", ephemeral=True)
```

### Nachher (v2):
```python
import discord

class ServerInfoView(discord.ui.View):
    def __init__(self):
        super().__init__()
    
    @discord.ui.button(label="Mehr erfahren", style=discord.ButtonStyle.primary)
    async def button_clicked(self, button, interaction):
        await interaction.response.send_message("Weitere Informationen...", ephemeral=True)

# Embed separat erstellen und mit View senden:
embed = discord.Embed(
    title="🎮 Server Informationen",
    description="**Willkommen auf unserem Server!**\n\nHier findest du alle wichtigen Informationen.",
    color=discord.Color.blue()
)

embed.add_field(
    name="📋 Befehle",
    value=(
        "`/help` - Zeigt diese Hilfe\n"
        "`/info` - Server-Informationen\n"
        "`/rules` - Serverregeln"
    ),
    inline=False
)

view = ServerInfoView()
await ctx.send(embed=embed, view=view)
```

## Troubleshooting:

### "Components displayable text size exceeds maximum size of 4000"
➡️ Dein Text ist zu lang! Nutze Embeds mit mehreren Fields statt Container, oder teile die Informationen auf mehrere Nachrichten auf.

### "ButtonStyle type error"
➡️ Nutze `discord.ButtonStyle.grey` statt `discord.ButtonStyle.gray`

### "DesignerView not found"
➡️ DesignerView existiert nicht mehr in v2. Nutze `discord.ui.View`

### "Container/TextDisplay not found"
➡️ Diese Komponenten existieren nicht mehr. Nutze `discord.Embed` für formatierte Texte.

## Weitere Hilfe:

- [py-cord Documentation](https://docs.pycord.dev/)
- [Discord UI Kit Guide](https://docs.pycord.dev/en/stable/api/ui_kit.html)
- [Discord Embed Guide](https://docs.pycord.dev/en/stable/api/models.html#discord.Embed)

