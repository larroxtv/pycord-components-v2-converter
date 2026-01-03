# Discord Components v1 zu v2 Converter
# Dieses Skript konvertiert Discord UI Components von v1 zu v2
# und installiert/aktualisiert py-cord auf Version 2.7.0

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Discord Components v1 -> v2 Converter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Funktion zum Prüfen und Installieren von py-cord
function Update-PyCord {
    Write-Host "Pruefe py-cord Installation..." -ForegroundColor Yellow

    $pycordVersion = python -m pip show py-cord 2>$null | Select-String "Version:"

    if ($pycordVersion) {
        $currentVersion = ($pycordVersion -split ": ")[1].Trim()
        Write-Host "Aktuelle py-cord Version: $currentVersion" -ForegroundColor Green

        if ($currentVersion -ne "2.7.0") {
            Write-Host "Aktualisiere py-cord auf Version 2.7.0..." -ForegroundColor Yellow
            python -m pip install --upgrade py-cord==2.7.0
            Write-Host "py-cord wurde auf Version 2.7.0 aktualisiert!" -ForegroundColor Green
        } else {
            Write-Host "py-cord 2.7.0 ist bereits installiert!" -ForegroundColor Green
        }
    } else {
        Write-Host "py-cord ist nicht installiert. Installiere Version 2.7.0..." -ForegroundColor Yellow
        python -m pip install py-cord==2.7.0
        Write-Host "py-cord 2.7.0 wurde erfolgreich installiert!" -ForegroundColor Green
    }
    Write-Host ""
}

# Funktion zum Konvertieren einer Python-Datei
function Convert-ComponentsFile {
    param (
        [string]$FilePath
    )

    Write-Host "Konvertiere: $FilePath" -ForegroundColor Cyan

    # Erstelle Backup
    $backupPath = "$FilePath.backup"
    Copy-Item $FilePath $backupPath -Force
    Write-Host "  Backup erstellt: $backupPath" -ForegroundColor Gray

    # Lese Dateiinhalt
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $originalContent = $content
    $changes = 0

    # 1. Konvertiere DesignerView zu discord.ui.View
    if ($content -match "DesignerView") {
        $content = $content -replace "class\s+(\w+)\(DesignerView\)", "class `$1(discord.ui.View)"
        $content = $content -replace "from discord\.ui import.*DesignerView.*", ""
        $changes++
        Write-Host "  ✓ DesignerView -> discord.ui.View" -ForegroundColor Green
    }

    # 2. Entferne Container und TextDisplay Imports
    if ($content -match "Container|TextDisplay|ActionRow") {
        $content = $content -replace ",\s*Container\s*,\s*TextDisplay\s*,\s*ActionRow", ""
        $content = $content -replace "from discord\.ui import\s*$", ""
        $changes++
        Write-Host "  ✓ Container, TextDisplay, ActionRow entfernt" -ForegroundColor Green
    }

    # 3. Konvertiere Container mit TextDisplay zu Embeds
    # Dies ist komplex und wird am besten manuell gemacht, aber wir fügen einen Hinweis hinzu
    if ($content -match "Container\(") {
        Write-Host "  ⚠ WARNUNG: Container()-Verwendung gefunden!" -ForegroundColor Yellow
        Write-Host "    Diese müssen manuell zu discord.Embed konvertiert werden." -ForegroundColor Yellow
        Write-Host "    Siehe CONVERSION_GUIDE.md für Beispiele." -ForegroundColor Yellow
    }

    # 4. Korrigiere ButtonStyle
    if ($content -match "ButtonStyle\.\w+") {
        $content = $content -replace "discord\.ButtonStyle\.primary", "discord.ButtonStyle.primary"
        $content = $content -replace "discord\.ButtonStyle\.secondary", "discord.ButtonStyle.secondary"
        $content = $content -replace "discord\.ButtonStyle\.success", "discord.ButtonStyle.success"
        $content = $content -replace "discord\.ButtonStyle\.danger", "discord.ButtonStyle.danger"
        $content = $content -replace "discord\.ButtonStyle\.gray", "discord.ButtonStyle.grey"
        Write-Host "  ✓ ButtonStyle aktualisiert" -ForegroundColor Green
    }

    # 5. Füge fehlende Imports hinzu, falls benötigt
    if ($content -notmatch "import discord" -and $content -match "discord\.") {
        $content = "import discord`n" + $content
        $changes++
        Write-Host "  ✓ 'import discord' hinzugefügt" -ForegroundColor Green
    }

    # Speichere nur, wenn Änderungen vorgenommen wurden
    if ($content -ne $originalContent) {
        Set-Content $FilePath -Value $content -Encoding UTF8
        Write-Host "  ✓ Datei wurde aktualisiert! ($changes Änderung(en))" -ForegroundColor Green
    } else {
        Write-Host "  ○ Keine Änderungen erforderlich" -ForegroundColor Gray
        Remove-Item $backupPath -Force
    }

    Write-Host ""
}

# Funktion zum Scannen und Konvertieren aller Python-Dateien
function Convert-AllPythonFiles {
    param (
        [string]$Directory
    )

    Write-Host "Scanne Verzeichnis: $Directory" -ForegroundColor Yellow
    Write-Host ""

    $pythonFiles = Get-ChildItem -Path $Directory -Filter "*.py" -Recurse -File

    if ($pythonFiles.Count -eq 0) {
        Write-Host "Keine Python-Dateien gefunden!" -ForegroundColor Red
        return
    }

    Write-Host "Gefunden: $($pythonFiles.Count) Python-Datei(en)" -ForegroundColor Green
    Write-Host ""

    foreach ($file in $pythonFiles) {
        # Überspringe __pycache__ Verzeichnisse
        if ($file.FullName -match "__pycache__") {
            continue
        }

        Convert-ComponentsFile -FilePath $file.FullName
    }
}

# Hauptskript
Write-Host "Starte Konvertierung..." -ForegroundColor Cyan
Write-Host ""

# 1. Aktualisiere py-cord
Update-PyCord

# 2. Hole aktuelles Verzeichnis
$currentDir = Get-Location

# Frage Benutzer, ob alle Dateien oder nur eine spezifische konvertiert werden soll
Write-Host "Moechten Sie:" -ForegroundColor Cyan
Write-Host "  [1] Alle Python-Dateien im aktuellen Verzeichnis konvertieren" -ForegroundColor White
Write-Host "  [2] Eine spezifische Datei konvertieren" -ForegroundColor White
Write-Host "  [3] Nur py-cord aktualisieren (keine Konvertierung)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Ihre Wahl (1/2/3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Convert-AllPythonFiles -Directory $currentDir
    }
    "2" {
        Write-Host ""
        $filePath = Read-Host "Geben Sie den Pfad zur Datei ein"
        if (Test-Path $filePath) {
            Convert-ComponentsFile -FilePath $filePath
        } else {
            Write-Host "Datei nicht gefunden: $filePath" -ForegroundColor Red
        }
    }
    "3" {
        Write-Host "Konvertierung uebersprungen." -ForegroundColor Yellow
    }
    default {
        Write-Host "Ungueltige Auswahl. Konvertierung abgebrochen." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Konvertierung abgeschlossen!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "WICHTIGE HINWEISE:" -ForegroundColor Yellow
Write-Host "1. Backup-Dateien wurden mit .backup Extension erstellt" -ForegroundColor White
Write-Host "2. Container/TextDisplay müssen manuell zu Embeds konvertiert werden" -ForegroundColor White
Write-Host "3. Teste deinen Bot, bevor du die Backups loeschst!" -ForegroundColor White
Write-Host "4. Bei Problemen: Stelle Backups wieder her mit:" -ForegroundColor White
Write-Host "   Get-ChildItem -Filter '*.backup' -Recurse | ForEach-Object { Move-Item `$_.FullName (`$_.FullName -replace '\.backup$','') -Force }" -ForegroundColor Gray
Write-Host ""

