# Discord Components v1 to v2 Converter
# This script converts Discord UI Components from v1 to v2
# and installs/updates py-cord to the LATEST version from PyPI

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Discord Components v1 -> v2 Converter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# Function: Install / Update py-cord to latest PyPI version
# ------------------------------------------------------------
function Update-PyCord {
    Write-Host "Checking py-cord installation..." -ForegroundColor Yellow

    $pycordInfo = python -m pip show py-cord 2>$null
    $versionLine = $pycordInfo | Select-String "Version:"

    if ($versionLine) {
        $currentVersion = ($versionLine -split ": ")[1].Trim()
        Write-Host "Current py-cord version: $currentVersion" -ForegroundColor Green

        Write-Host "Updating py-cord to the latest version from PyPI..." -ForegroundColor Yellow
        python -m pip install --upgrade py-cord
        Write-Host "py-cord update completed!" -ForegroundColor Green
    } else {
        Write-Host "py-cord is not installed. Installing latest version from PyPI..." -ForegroundColor Yellow
        python -m pip install py-cord
        Write-Host "py-cord installed successfully!" -ForegroundColor Green
    }

    # Show installed version after update
    $newVersionLine = python -m pip show py-cord 2>$null | Select-String "Version:"
    if ($newVersionLine) {
        $installedVersion = ($newVersionLine -split ": ")[1].Trim()
        Write-Host "Installed py-cord version: $installedVersion" -ForegroundColor Cyan
    }

    Write-Host ""
}

# ------------------------------------------------------------
# Function: Convert a single Python file
# ------------------------------------------------------------
function Convert-ComponentsFile {
    param (
        [string]$FilePath
    )

    Write-Host "Converting: $FilePath" -ForegroundColor Cyan

    # Create backup
    $backupPath = "$FilePath.backup"
    Copy-Item $FilePath $backupPath -Force
    Write-Host "  Backup created: $backupPath" -ForegroundColor Gray

    # Read file content
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    $changes = 0

    # 1. Convert DesignerView -> discord.ui.View
    if ($content -match "DesignerView") {
        $content = $content -replace "class\s+(\w+)\(DesignerView\)", "class `$1(discord.ui.View)"
        $content = $content -replace "from discord\.ui import.*DesignerView.*", ""
        $changes++
        Write-Host "  ✓ DesignerView -> discord.ui.View" -ForegroundColor Green
    }

    # 2. Remove deprecated imports
    if ($content -match "Container|TextDisplay|ActionRow") {
        $content = $content -replace ",\s*Container\s*,\s*TextDisplay\s*,\s*ActionRow", ""
        $content = $content -replace "from discord\.ui import\s*$", ""
        $changes++
        Write-Host "  ✓ Removed Container, TextDisplay, ActionRow imports" -ForegroundColor Green
    }

    # 3. Warn about Container usage
    if ($content -match "Container\(") {
        Write-Host "  ⚠ WARNING: Container() usage detected!" -ForegroundColor Yellow
        Write-Host "    These must be manually converted to discord.Embed." -ForegroundColor Yellow
        Write-Host "    See CONVERSION_GUIDE.md for examples." -ForegroundColor Yellow
    }

    # 4. Fix ButtonStyle usage
    if ($content -match "ButtonStyle\.") {
        $content = $content -replace "discord\.ButtonStyle\.primary", "discord.ButtonStyle.primary"
        $content = $content -replace "discord\.ButtonStyle\.secondary", "discord.ButtonStyle.secondary"
        $content = $content -replace "discord\.ButtonStyle\.success", "discord.ButtonStyle.success"
        $content = $content -replace "discord\.ButtonStyle\.danger", "discord.ButtonStyle.danger"
        $content = $content -replace "discord\.ButtonStyle\.gray", "discord.ButtonStyle.grey"
        Write-Host "  ✓ ButtonStyle updated" -ForegroundColor Green
    }

    # 5. Add missing discord import
    if ($content -notmatch "import discord" -and $content -match "discord\.") {
        $content = "import discord`n" + $content
        $changes++
        Write-Host "  ✓ Added 'import discord'" -ForegroundColor Green
    }

    # Save file only if changes were made
    if ($content -ne $originalContent) {
        Set-Content $FilePath -Value $content -Encoding UTF8
        Write-Host "  ✓ File updated! ($changes change(s))" -ForegroundColor Green
    } else {
        Write-Host "  ○ No changes required" -ForegroundColor Gray
        Remove-Item $backupPath -Force
    }

    Write-Host ""
}

# ------------------------------------------------------------
# Function: Convert all Python files in a directory
# ------------------------------------------------------------
function Convert-AllPythonFiles {
    param (
        [string]$Directory
    )

    Write-Host "Scanning directory: $Directory" -ForegroundColor Yellow
    Write-Host ""

    $pythonFiles = Get-ChildItem -Path $Directory -Filter "*.py" -Recurse -File

    if ($pythonFiles.Count -eq 0) {
        Write-Host "No Python files found!" -ForegroundColor Red
        return
    }

    Write-Host "Found: $($pythonFiles.Count) Python file(s)" -ForegroundColor Green
    Write-Host ""

    foreach ($file in $pythonFiles) {
        if ($file.FullName -match "__pycache__") {
            continue
        }
        Convert-ComponentsFile -FilePath $file.FullName
    }
}

# ------------------------------------------------------------
# Main Script
# ------------------------------------------------------------
Write-Host "Starting conversion..." -ForegroundColor Cyan
Write-Host ""

# Update py-cord first
Update-PyCord

# Get current directory
$currentDir = Get-Location

Write-Host "Would you like to:" -ForegroundColor Cyan
Write-Host "  [1] Convert all Python files in the current directory" -ForegroundColor White
Write-Host "  [2] Convert a specific file" -ForegroundColor White
Write-Host "  [3] Only update py-cord (no conversion)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Your choice (1/2/3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Convert-AllPythonFiles -Directory $currentDir
    }
    "2" {
        Write-Host ""
        $filePath = Read-Host "Enter the file path"
        if (Test-Path $filePath) {
            Convert-ComponentsFile -FilePath $filePath
        } else {
            Write-Host "File not found: $filePath" -ForegroundColor Red
        }
    }
    "3" {
        Write-Host "Conversion skipped. Only py-cord was updated." -ForegroundColor Yellow
    }
    default {
        Write-Host "Invalid selection. Conversion aborted." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Conversion completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Yellow
Write-Host "1. Backup files were created with the .backup extension" -ForegroundColor White
Write-Host "2. Container/TextDisplay must be manually converted to Embeds" -ForegroundColor White
Write-Host "3. Test your bot before deleting backups!" -ForegroundColor White
Write-Host "4. Restore backups with:" -ForegroundColor White
Write-Host "   Get-ChildItem -Filter '*.backup' -Recurse | ForEach-Object { Move-Item `$_.FullName (`$_.FullName -replace '\.backup$','') -Force }" -ForegroundColor Gray
Write-Host ""
