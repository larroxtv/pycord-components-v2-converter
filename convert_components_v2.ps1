# Discord Components v2 -> v1 Converter (Embed → Container)
# Updates py-cord to latest PyPI version
# Auto-converts simple discord.Embed() instances into Container(TextDisplay(...))

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Discord Components v2 -> v1 Converter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# Update py-cord to latest
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

    $newVersionLine = python -m pip show py-cord 2>$null | Select-String "Version:"
    if ($newVersionLine) {
        $installedVersion = ($newVersionLine -split ": ")[1].Trim()
        Write-Host "Installed py-cord version: $installedVersion" -ForegroundColor Cyan
    }

    Write-Host ""
}

# ------------------------------------------------------------
# Convert a single Python file
# ------------------------------------------------------------
function Convert-ComponentsFile {
    param (
        [string]$FilePath
    )

    Write-Host "Converting: $FilePath" -ForegroundColor Cyan

    # Backup
    $backupPath = "$FilePath.backup"
    Copy-Item $FilePath $backupPath -Force
    Write-Host "  Backup created: $backupPath" -ForegroundColor Gray

    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    $changes = 0

    # --------------------------------------------------------
    # Embed -> Container(TextDisplay(...))
    # --------------------------------------------------------
    $embedPattern = 'discord\.Embed\(\s*((?:.|\n)*?)\s*\)'
    if ($content -match $embedPattern) {
        $content = [regex]::Replace($content, $embedPattern, {
            param($match)

            $inner = $match.Groups[1].Value

            # Extract title and description
            $titleMatch = [regex]::Match($inner, 'title\s*=\s*["\']([^"\']*)["\']')
            $descMatch  = [regex]::Match($inner, 'description\s*=\s*["\']([^"\']*)["\']')

            $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { "" }
            $desc  = if ($descMatch.Success)  { $descMatch.Groups[1].Value } else { "" }

            $textDisplays = @()
            if ($title -ne "") { $textDisplays += "TextDisplay(`"$title`")" }
            if ($desc -ne "")  { $textDisplays += "TextDisplay(`"$desc`")" }

            $containerString = "Container(" + ($textDisplays -join ", ") + ")"
            return $containerString
        })

        Write-Host "  ✓ discord.Embed auto-converted to Container(TextDisplay(...))" -ForegroundColor Green
        $changes++
    }

    # Save only if changed
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
# Convert all Python files recursively
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
        if ($file.FullName -match "__pycache__") { continue }
        Convert-ComponentsFile -FilePath $file.FullName
    }
}

# ------------------------------------------------------------
# Main Script
# ------------------------------------------------------------
Write-Host "Starting conversion..." -ForegroundColor Cyan
Write-Host ""

Update-PyCord

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
Write-Host "2. Only simple discord.Embed instances were auto-converted" -ForegroundColor White
Write-Host "3. Complex embeds with fields, authors, footers, or images must be converted manually" -ForegroundColor White
Write-Host "4. Test your bot before deleting backups!" -ForegroundColor White
Write-Host "5. Restore backups with:" -ForegroundColor White
Write-Host "   Get-ChildItem -Filter '*.backup' -Recurse | ForEach-Object { Move-Item `$_.FullName (`$_.FullName -replace '\.backup$','') -Force }" -ForegroundColor Gray
Write-Host ""
