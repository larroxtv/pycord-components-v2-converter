# Py-Cord Components v2 Converter

A PowerShell tool for automatically converting py-cord bot code from standard Discord Components to the new Components v2 API.

## 🎯 What does this tool do?

This tool helps you migrate your Discord bot from the standard `discord.Embed` API to the new **Components v2** system with `Container` and `TextDisplay`.

### ✅ Automatic conversions:
- ✅ Installs/updates **py-cord to version 2.7.0**
- ✅ Converts `discord.ui.View` → `DesignerView`
- ✅ Adds required imports (`Container`, `TextDisplay`, `ActionRow`)
- ✅ Converts `discord.Embed` → `Container(TextDisplay(...))`
- ✅ Fixes `ButtonStyle.grey` → `ButtonStyle.gray`
- ✅ Creates **automatic backups** (`.backup` files)

### ⚠️ Manual work required:
- Complex embed structures may need manual adjustment
- Multiple embeds in one message require review
- See `CONVERSION_GUIDE.md` for detailed examples

## 🚀 Quick Start

### 1. Copy the script into your project
```powershell
# Copy convert_components_v2.ps1 and CONVERSION_GUIDE.md into your project directory
```

### 2. Open PowerShell and navigate to your project

```powershell
cd C:\Path\to\your\Bot-Project
```

### 3. Run the script

```powershell
.\convert_components_v2.ps1
```

### 4. Choose an option

```
[1] Convert all Python files in the current directory
[2] Convert a specific file
[3] Only update py-cord (no conversion)
```

## 📚 Files in this package

* **`convert_components_v2.ps1`** – Main conversion script
* **`CONVERSION_GUIDE.md`** – Detailed guide with code examples
* **`README_CONVERTER.md`** – This file (overview)

## 💡 Example Workflow

```powershell
# 1. Navigate to your bot project
cd C:\MyBot

# 2. Run the script
.\convert_components_v2.ps1

# 3. Choose option 1 to convert all files
Your choice (1/2/3): 1

# 4. Review the converted code and test
# 5. Test your bot
python main.py

# 6. Delete backups if everything works
Remove-Item *.backup -Recurse
```

## 🔄 Restore Backups

If something goes wrong:

```powershell
# Restore a single file:
Move-Item "my_file.py.backup" "my_file.py" -Force

# Restore ALL backups:
Get-ChildItem -Filter "*.backup" -Recurse | ForEach-Object { 
    Move-Item $_.FullName ($_.FullName -replace '\.backup$','') -Force 
}
```

## 📖 Important Code Changes

### discord.ui.View → DesignerView

```python
# OLD:
class MyView(discord.ui.View):
    pass

# NEW:
from discord.ui import DesignerView

class MyView(DesignerView):
    pass
```

### discord.Embed → Container/TextDisplay

```python
# OLD:
embed = discord.Embed(
    title="Title",
    description="Description",
    color=discord.Color.blue()
)

# NEW:
from discord.ui import Container, TextDisplay

container = Container(
    TextDisplay("Title"),
    TextDisplay("Description")
)
```

### Buttons with ActionRow

```python
# OLD:
view.add_item(button)

# NEW:
from discord.ui import ActionRow

container.add_item(ActionRow(button))
```

## 🐛 Troubleshooting

### Error: "py-cord not found"

```powershell
python -m pip install py-cord==2.7.0
```

### Error: "DesignerView not found"

➡️ Make sure py-cord 2.7.0 is installed:
```powershell
python -m pip install --upgrade py-cord==2.7.0
```

### Error: "Container not found"

➡️ Check your imports:
```python
from discord.ui import Container, TextDisplay, ActionRow
```

### Error: "Components displayable text size exceeds maximum size of 4000"

➡️ Your text is too long. Split the information into multiple TextDisplay elements or use multiple containers.

## 🔗 Useful Links

* [py-cord Documentation](https://docs.pycord.dev/)
* [Components v2 Documentation](https://docs.pycord.dev/en/stable/api/ui_kit.html)
* [DesignerView Guide](https://docs.pycord.dev/en/stable/api/ui_kit.html#discord.ui.DesignerView)
* [Migration Guide](https://docs.pycord.dev/en/stable/migrating.html)

## ⚡ Quick Reference

| v1 (Standard)       | v2 (Components v2)      |
| ------------------- | ----------------------- |
| `discord.ui.View`   | `DesignerView`          |
| `discord.Embed()`   | `Container()`           |
| `embed.add_field()` | `TextDisplay()`         |
| `view.add_item()`   | `ActionRow(button)`     |
| `ButtonStyle.grey`  | `ButtonStyle.gray`      |

## 🤝 Support

If you have questions or issues:

1. Check [CONVERSION_GUIDE.md](https://github.com/larroxtv/pycord-components-v2-converter/blob/main/CONVERSION_GUIDE.md) for detailed examples
2. Search the [py-cord documentation](https://docs.pycord.dev/)
3. Make sure py-cord 2.7.0 or newer is installed

## 📝 License

This tool is licensed under the [MIT License](https://github.com/larroxtv/pycord-components-v2-converter/blob/main/LICENSE).
