
# Discord Components v1 to v2 Conversion Guide

## Quick Start

### Run the PowerShell script:
```powershell
cd C:\Path\to\your\Project
.\convert_components_v2.ps1

## What the script does automatically:

✅ Installs/updates py-cord to version 2.7.0
✅ Converts `DesignerView` to `discord.ui.View`
✅ Removes deprecated imports (`Container`, `TextDisplay`, `ActionRow`)
✅ Fixes `ButtonStyle` usage
✅ Automatically creates backups (`.backup` files)

## What must be done manually:

### 1. Convert Container + TextDisplay to Embed

#### OLD (v1):

```python
class MyView(DesignerView):
    def __init__(self):
        super().__init__()
        container = Container(
            TextDisplay("## Title"),
            TextDisplay("Here is a description with important information.")
        )
        self.add_item(container)
```

#### NEW (v2):

```python
class MyView(discord.ui.View):
    def __init__(self):
        super().__init__()

# Instead, create an embed and send it directly:
embed = discord.Embed(
    title="Title",
    description="Here is a description with important information.",
    color=discord.Color.blue()
)

embed.add_field(
    name="📌 Category 1",
    value="Content for category 1",
    inline=False
)

embed.add_field(
    name="🔧 Category 2",
    value="Content for category 2",
    inline=False
)

await interaction.response.send_message(embed=embed, ephemeral=True)
```

### 2. Add buttons directly to the View

#### OLD (v1):

```python
container.add_item(ActionRow(button))
```

#### NEW (v2):

```python
# Method 1: Buttons as decorators inside the View class:
class MyView(discord.ui.View):
    @discord.ui.button(label="Click me", style=discord.ButtonStyle.primary)
    async def button_callback(self, button, interaction):
        await interaction.response.send_message("Button was clicked!", ephemeral=True)

# Method 2: Add button manually:
class MyView(discord.ui.View):
    def __init__(self):
        super().__init__()
        
        button = discord.ui.Button(label="Click me", style=discord.ButtonStyle.primary)
        button.callback = self.my_callback
        self.add_item(button)
    
    async def my_callback(self, interaction):
        await interaction.response.send_message("Button was clicked!", ephemeral=True)
```

## Important changes in py-cord 2.7.0:

1. **DesignerView was removed** – use `discord.ui.View`
2. **Container/TextDisplay were removed** – use `discord.Embed`
3. **ActionRow is no longer required** – Discord handles layout automatically
4. **ButtonStyle.gray** → **ButtonStyle.grey** (British spelling)

## Restore backups:

If something goes wrong:

```powershell
# Single file:
Move-Item "my_file.py.backup" "my_file.py" -Force

# Restore all backups:
Get-ChildItem -Filter "*.backup" -Recurse | ForEach-Object { 
    Move-Item $_.FullName ($_.FullName -replace '\.backup$','') -Force 
}
```

## Example: Full View Conversion

### Before (v1):

```python
from discord.ui import DesignerView, Container, TextDisplay, ActionRow

class ServerInfoView(DesignerView):
    def __init__(self):
        super().__init__()
        container = Container(
            TextDisplay("## 🎮 Server Information"),
            TextDisplay(
                "**Welcome to our server!**\n\n"
                "Here you can find all important information."
            ),
            TextDisplay(
                "📋 **Commands:**\n"
                "- /help - Shows this help\n"
                "- /info - Server information\n"
                "- /rules - Server rules"
            )
        )
        
        # Add button
        button = discord.ui.Button(label="Learn more", style=discord.ButtonStyle.primary)
        button.callback = self.button_clicked
        container.add_item(ActionRow(button))
        
        self.add_item(container)
    
    async def button_clicked(self, interaction):
        await interaction.response.send_message("More information...", ephemeral=True)
```

### After (v2):

```python
import discord

class ServerInfoView(discord.ui.View):
    def __init__(self):
        super().__init__()
    
    @discord.ui.button(label="Learn more", style=discord.ButtonStyle.primary)
    async def button_clicked(self, button, interaction):
        await interaction.response.send_message("More information...", ephemeral=True)

# Create the embed separately and send it with the View:
embed = discord.Embed(
    title="🎮 Server Information",
    description="**Welcome to our server!**\n\nHere you can find all important information.",
    color=discord.Color.blue()
)

embed.add_field(
    name="📋 Commands",
    value=(
        "`/help` - Shows this help\n"
        "`/info` - Server information\n"
        "`/rules` - Server rules"
    ),
    inline=False
)

view = ServerInfoView()
await ctx.send(embed=embed, view=view)
```

## Troubleshooting:

### "Components displayable text size exceeds maximum size of 4000"

➡️ Your text is too long! Use embeds with multiple fields instead of containers, or split the information across multiple messages.

### "ButtonStyle type error"

➡️ Use `discord.ButtonStyle.grey` instead of `discord.ButtonStyle.gray`

### "DesignerView not found"

➡️ `DesignerView` no longer exists in v2. Use `discord.ui.View`

### "Container/TextDisplay not found"

➡️ These components no longer exist. Use `discord.Embed` for formatted text.

## Further help:

* [py-cord Documentation](https://docs.pycord.dev/)
* [Discord UI Kit Guide](https://docs.pycord.dev/en/stable/api/ui_kit.html)
* [Discord Embed Guide](https://docs.pycord.dev/en/stable/api/models.html#discord.Embed)

```
```
