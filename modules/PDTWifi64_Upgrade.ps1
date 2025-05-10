# PDTWifi64_Upgrade.ps1 - Version 1.19
# This script checks for and installs the latest version of PDTWifi64.exe.
#
# Define variables
$currentVersionPath = "C:\Program Files (x86)\StationMaster\PDTWifi64.exe"
$newVersionURL = "https://files.stationmaster.info/files/PDTWifi64.exe" # IMPORTANT: Replace with the actual URL
$backupPath = "C:\winsm" # Path to move the old executable

# Function to check for administrative privileges
function Is-Admin {
    $elevated = $false
    if ($PSBoundParameters.ContainsKey('Credential')) {
        $credential = $Credential
    } else {
        $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
        $elevated = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return $elevated
}

# Function to get the SHA-256 hash of a file
function Get-FileHashSHA256 {
    param(
        [Parameter(Mandatory = $true)]
        [string] $filePath
    )
    if (Test-Path $filePath) {
        try {
            Get-FileHash -Path $filePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        } catch {
            Write-Host "Error: Failed to get hash of file: $($_.Exception.Message)" -ForegroundColor Red
            return $null
        }
    } else {
        return $null
    }
}

# 1.0 - Check Administrative Privileges
$adminRights = Is-Admin
if (-not $adminRights) {
    Write-Host "Error: This script must be run as an administrator." -ForegroundColor Red
    exit 1
}

# 1.1 - Check Current Version Existence
if (-not (Test-Path $currentVersionPath)) {
    Write-Host "PDTWifi64.exe not found. Downloading the latest version." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $newVersionURL -OutFile $currentVersionPath
        Write-Host "PDTWifi64.exe downloaded successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to download PDTWifi64.exe: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please check the URL and your internet connection." -ForegroundColor Red
        exit 1
    }
}

# 1.2 - Get Current Version Hash
$currentVersionHash = Get-FileHashSHA256 -filePath $currentVersionPath
if ($currentVersionHash -eq $null) {
     Write-Host "Error: Failed to get hash of current version. Skipping upgrade." -ForegroundColor Red
     exit 1
}

# 1.3 - Get New Version (for hash comparison)
$newVersionPath = Join-Path $env:TEMP "PDTWifi64_new.exe"
try {
    Invoke-WebRequest -Uri $newVersionURL -OutFile $newVersionPath
} catch {
    Write-Host "Error: Failed to download new version for comparison: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please check the URL and your internet connection." -ForegroundColor Red
    exit 1
}
$newVersionHash = Get-FileHashSHA256 -filePath $newVersionPath

if ($newVersionHash -eq $null) {
    Write-Host "Error: Failed to get hash of new version. Skipping upgrade." -ForegroundColor Red
    exit 1
}

# 1.4 - Compare Version Hashes
if ($currentVersionHash -eq $newVersionHash) {
    Write-Host "No upgrade needed.  Current version is up to date." -ForegroundColor Green
    Remove-Item -Path $newVersionPath -Force
    exit 0
} else {
    Write-Host "Upgrading to the new version..." -ForegroundColor Yellow
}

# 1.5 - Stop PDTWifi64.exe Process
try {
    $process = Get-Process -Name "PDTWifi64" -ErrorAction SilentlyContinue
    if ($process) {
        Stop-Process -Name "PDTWifi64" -Force
    }
} catch {
    Write-Host "Warning: Failed to stop PDTWifi64.exe.  May be in use.  Attempting to continue." -ForegroundColor Yellow
    # Continue even if stopping fails.
}

# 1.6 - Move Current Version to a Backup Folder
try {
    # Create the backup directory if it doesn't exist
    if (-not (Test-Path $backupPath -PathType Container)) {
        New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $newFileName = "PDTWifi64_$timestamp.exe"
    $destinationPath = Join-Path $backupPath $newFileName
    Move-Item -Path $currentVersionPath -Destination $destinationPath -Force
    Write-Host "Original PDTWifi64.exe moved to $destinationPath" -ForegroundColor Green
} catch {
    Write-Host "Error: Failed to move original version.  Upgrade may fail." -ForegroundColor Red
    exit 1 # Stop if move to backup fails
}

# 1.7 - Download New Version
try {
    # Download already done in 1.3,  we just move it.
    Move-Item -Path $newVersionPath -Destination $currentVersionPath -Force
} catch {
    Write-Host "Error: Failed to move new version into place.  Upgrade failed." -ForegroundColor Red
    exit 1
}

# 1.8 - Launch New Version
try {
    Start-Process -FilePath $currentVersionPath
} catch {
    Write-Host "Error: Failed to launch new version.  Please launch it manually." -ForegroundColor Red
    exit 1 # Exit.
}

Write-Host "Upgrade process completed." -ForegroundColor Green
