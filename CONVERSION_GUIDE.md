# Discord Components v1 to v2 Conversion Guide

## Quick Start

### Run the PowerShell script:
```powershell
cd C:\Path\to\your\Project
.\convert_components_v2.ps1
```

## What the script does automatically:

- ✅ Installs/updates py-cord to version 2.7.0 or newer
- ✅ Converts `discord.ui.View` to `DesignerView`
- ✅ Adds required imports (`Container`, `TextDisplay`, `ActionRow`)
- ✅ Converts `discord.Embed` to `Container(TextDisplay())`
- ✅ Fixes `ButtonStyle` usage (grey → gray)
- ✅ Automatically creates backups (`.backup` files)

## What must be done manually:

### 1. Convert Embed to Container + TextDisplay

#### OLD (v1):

```python
class MyView(discord.ui.View):
    def __init__(self):
        super().__init__()

# Create an embed and send it:
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

#### NEW (v2):

```python
from discord.ui import DesignerView, Container, TextDisplay, ActionRow

class MyView(DesignerView):
    def __init__(self):
        super().__init__()
        container = Container(
            TextDisplay("## Title"),
            TextDisplay("Here is a description with important information."),
            TextDisplay("📌 **Category 1**\nContent for category 1"),
            TextDisplay("🔧 **Category 2**\nContent for category 2")
        )
        self.add_item(container)
```

### 2. Add buttons using ActionRow

#### OLD (v1):

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

#### NEW (v2):

```python
from discord.ui import DesignerView, Container, ActionRow

class MyView(DesignerView):
    def __init__(self):
        super().__init__()
        
        container = Container(
            TextDisplay("Click the button below!")
        )
        
        button = discord.ui.Button(label="Click me", style=discord.ButtonStyle.primary)
        button.callback = self.my_callback
        container.add_item(ActionRow(button))
        
        self.add_item(container)
    
    async def my_callback(self, interaction):
        await interaction.response.send_message("Button was clicked!", ephemeral=True)
```

## Important changes in py-cord 2.7.0:

1. **DesignerView is available** – use `DesignerView` instead of `discord.ui.View`
2. **Container/TextDisplay are available** – use these instead of `discord.Embed`
3. **ActionRow is required** – wrap buttons in `ActionRow()` for proper layout
4. **ButtonStyle.grey** → **ButtonStyle.gray** (American spelling)

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

### After (v2):

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

# Send the view directly:
view = ServerInfoView()
await ctx.send(view=view)
```

## Troubleshooting:

### "Components displayable text size exceeds maximum size of 4000"

➡️ Your text is too long! Split the information into multiple `TextDisplay()` elements or use multiple containers/messages.

### "ButtonStyle type error"

➡️ Use `discord.ButtonStyle.gray` instead of `discord.ButtonStyle.grey`

### "DesignerView not found"

➡️ Make sure py-cord 2.7.0 is installed:
```powershell
python -m pip install --upgrade py-cord==2.7.0
```

### "Container/TextDisplay not found"

➡️ Check your imports:
```python
from discord.ui import Container, TextDisplay, ActionRow
```

### "Embed still showing instead of Container"

➡️ Make sure you're sending the `view` directly, not an embed:
```python
await ctx.send(view=view)  # Correct
await ctx.send(embed=embed, view=view)  # Wrong for Components v2
```

## Further help:

* [py-cord Documentation](https://docs.pycord.dev/)
* [Discord UI Kit Guide](https://docs.pycord.dev/en/stable/api/ui_kit.html)
* [DesignerView Documentation](https://docs.pycord.dev/en/stable/api/ui_kit.html#discord.ui.DesignerView)
