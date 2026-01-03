# Py-Cord Components v2 Converter

A PowerShell tool for automatically converting py-cord bot code from Components v1 to v2.

## 🎯 What does this tool do?

This tool helps you migrate your Discord bot from the deprecated DesignerView API to the new standard Discord Components.

### ✅ Automatic conversions:
- ✅ Installs/updates **py-cord to version 2.7.0**
- ✅ Converts `DesignerView` → `discord.ui.View`
- ✅ Removes deprecated imports (`Container`, `TextDisplay`, `ActionRow`)
- ✅ Fixes `ButtonStyle.gray` → `ButtonStyle.grey`
- ✅ Creates **automatic backups** (`.backup` files)

### ⚠️ Manual work required:
- `Container()` and `TextDisplay()` must be converted to `discord.Embed`
- See `CONVERSION_GUIDE.md` for detailed examples

## 🚀 Quick Start

### 1. Copy the script into your project
```powershell
# Copy convert_components_v2.ps1 and CONVERSION_GUIDE.md into your project directory
````

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

# 4. Review the logs and convert Containers manually
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

### DesignerView → discord.ui.View

```python
# OLD:
class MyView(DesignerView):
    pass

# NEW:
class MyView(discord.ui.View):
    pass
```

### Container/TextDisplay → Embed

```python
# OLD:
container = Container(
    TextDisplay("Title"),
    TextDisplay("Description")
)

# NEW:
embed = discord.Embed(
    title="Title",
    description="Description",
    color=discord.Color.blue()
)
```

### Buttons

```python
# OLD:
container.add_item(ActionRow(button))

# NEW:
self.add_item(button)  # or via @discord.ui.button decorator
```

## 🐛 Troubleshooting

### Error: "py-cord not found"

```powershell
python -m pip install py-cord
```

### Error: "DesignerView not found"

➡️ Good! That means the conversion was successful. Remove all `DesignerView` imports.

### Error: "Container not found"

➡️ Convert all `Container()` usages to `discord.Embed`. See `CONVERSION_GUIDE.md`.

### Error: "Components displayable text size exceeds maximum size of 4000"

➡️ Your text is too long. Split the information into multiple embed fields or use multiple messages.

## 🔗 Useful Links

* [py-cord Documentation](https://docs.pycord.dev/)
* [Discord Embed Documentation](https://docs.pycord.dev/en/stable/api/models.html#discord.Embed)
* [UI Components Guide](https://docs.pycord.dev/en/stable/api/ui_kit.html)
* [Migration Guide](https://docs.pycord.dev/en/stable/migrating.html)

## ⚡ Quick Reference

| v1 (Deprecated)     | v2 (Current)            |
| ------------------- | ----------------------- |
| `DesignerView`      | `discord.ui.View`       |
| `Container()`       | `discord.Embed()`       |
| `TextDisplay()`     | `embed.add_field()`     |
| `ActionRow(button)` | `self.add_item(button)` |
| `ButtonStyle.gray`  | `ButtonStyle.grey`      |

## 🤝 Support

If you have questions or issues:

1. Check [CONVERSION_GUIDE.md](https://github.com/larroxtv/pycord-components-v2-converter/blob/main/CONVERSION_GUIDE.md) for detailed examples
2. Search the [py-cord documentation](https://docs.pycord.dev/)
3. Make sure py-cord 2.7.0 is installed

## 📝 License

This tool is licensed under the [MIT License](https://github.com/larroxtv/pycord-components-v2-converter/blob/main/LICENSE).
