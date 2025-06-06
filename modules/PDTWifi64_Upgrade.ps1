# PDTWifi64_Upgrade.ps1 - Version 1.23
# This script checks for and installs the latest version of PDTWifi64.exe.

# PartVersion: 1.3
#LOCK=OFF
# Define variables
$scriptName = "PDTWifi64_Upgrade.ps1"
$scriptVersion = "1.23"
$currentVersionPath = "C:\Program Files (x86)\StationMaster\PDTWifi64.exe"
$newVersionURL = "https://files.stationmaster.info/files/PDTWifi64.exe"
$backupPath = "C:\winsm"
$tempDownloadPath = Join-Path $env:TEMP "PDTWifi64_new.exe" # Temporary path for the downloaded new version for comparison

# Announce script name and version at startup
Write-Host "$scriptName - Version $scriptVersion" -ForegroundColor Cyan
Write-Host "---" -ForegroundColor DarkGray

# PartVersion: 1.3
#LOCK=OFF
# Function to check for administrative privileges
function Is-Admin {
    # Check if the script is running with elevated (administrator) privileges.
    # Returns $true if elevated, $false otherwise.
    [CmdletBinding()]
    param(
        [System.Management.Automation.PSCredential]$Credential
    )

    $elevated = $false
    if ($PSBoundParameters.ContainsKey('Credential')) {
        Write-Host "Warning: 'Credential' parameter is not typically used for 'Is-Admin' checks. Checking current user." -ForegroundColor Yellow
    }
    
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    $elevated = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    
    return $elevated
}

# PartVersion: 1.3
#LOCK=OFF
# Function to get the SHA-256 hash of a file
function Get-FileHashSHA256 {
    # Calculates the SHA-256 hash for a given file.
    # Returns the hash string or $null if the file doesn't exist or an error occurs.
    param(
        [Parameter(Mandatory = $true)]
        [string] $filePath
    )
    
    if (Test-Path $filePath -PathType Leaf) { # Ensure it's a file
        try {
            # Use Get-FileHash cmdlet to compute the SHA256 hash
            (Get-FileHash -Path $filePath -Algorithm SHA256).Hash
        } catch {
            Write-Host "Error: Failed to get hash of file '$filePath': $($_.Exception.Message)" -ForegroundColor Red
            return $null
        }
    } else {
        # Return $null if file doesn't exist, indicating no hash could be obtained.
        return $null
    }
}

# PartVersion: 1.3
#LOCK=OFF
# Main function to perform the upgrade logic
function Invoke-PDTWifi64Upgrade {
    # This function encapsulates the entire upgrade logic for PDTWifi64.exe.
    # It returns $true on successful completion and $false if any critical error occurs
    # or the upgrade cannot proceed. This allows it to be called from another script
    # without terminating the entire PowerShell session.
    [CmdletBinding()]
    param()

    # Use a try/finally block to ensure temporary file cleanup on exit (successful or failed)
    try {
        # 1.0 - Initial Checks and Prepare for Comparison
        Write-Host "1.0 - Performing initial checks..." -ForegroundColor White

        # 1.0.1 - Check Administrative Privileges
        $adminRights = Is-Admin
        if (-not $adminRights) {
            Write-Host "Error: This script must be run as an administrator. Please restart with elevated privileges." -ForegroundColor Red
            # Return failure status instead of exiting the entire session
            return $false
        }
        Write-Host "Administrative privileges confirmed." -ForegroundColor Green

        # 1.0.2 - Clean up previous temporary download if it exists
        if (Test-Path $tempDownloadPath -PathType Leaf) {
            Write-Host "Cleaning up previous temporary download file: '$tempDownloadPath'." -ForegroundColor DarkGray
            Remove-Item -Path $tempDownloadPath -Force -ErrorAction SilentlyContinue
        }

        # 1.1 - Get Current Version Hash
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.1 - Getting SHA-256 hash of the current PDTWifi64.exe (if installed)..." -ForegroundColor White
        $currentVersionHash = Get-FileHashSHA256 -filePath $currentVersionPath

        if ($currentVersionHash -eq $null) {
            Write-Host "PDTWifi64.exe not found at '$currentVersionPath' or failed to get hash. It will be installed/upgraded." -ForegroundColor Yellow
        } else {
            Write-Host "Current PDTWifi64.exe hash: $currentVersionHash" -ForegroundColor Green
        }

        # 1.2 - Download New Version to Temporary Location for Hash Comparison
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.2 - Downloading the latest version to a temporary location for hash comparison..." -ForegroundColor White
        try {
            Invoke-WebRequest -Uri $newVersionURL -OutFile $tempDownloadPath -ErrorAction Stop
            Write-Host "Latest PDTWifi64.exe downloaded to temporary location: '$tempDownloadPath'." -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to download the latest PDTWifi64.exe from '$newVersionURL': $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Please check the URL and your internet connection." -ForegroundColor Red
            return $false # Return failure
        }

        # 1.3 - Get Latest Version Hash and Determine Upgrade Need
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.3 - Comparing current and latest version hashes..." -ForegroundColor White

        $latestVersionHash = Get-FileHashSHA256 -filePath $tempDownloadPath
        if ($latestVersionHash -eq $null) {
            Write-Host "Error: Failed to get hash of the newly downloaded version. Cannot proceed with comparison." -ForegroundColor Red
            return $false # Return failure
        }
        Write-Host "Latest PDTWifi64.exe hash (from temp download): $latestVersionHash" -ForegroundColor Green

        $upgradeNeeded = $false
        if ($currentVersionHash -eq $null) { # File not found initially
            $upgradeNeeded = $true
        } elseif ($currentVersionHash -ne $latestVersionHash) { # Hashes are different
            $upgradeNeeded = $true
        }

        if (-not $upgradeNeeded) {
            Write-Host "No upgrade needed. Your current PDTWifi64.exe is already up to date." -ForegroundColor Green
            Write-Host "---" -ForegroundColor DarkGray
            Write-Host "Script finished. No action taken as PDTWifi64.exe is already up to date." -ForegroundColor Green
            return $true # Return success
        } else {
            Write-Host "Upgrade required. A new version of PDTWifi64.exe is available." -ForegroundColor Yellow
            Write-Host "Starting upgrade process..." -ForegroundColor Yellow
        }

        # 1.4 - Perform Upgrade Steps
        # 1.4.1 - Stop PDTWifi64.exe Process
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.4.1 - Attempting to stop PDTWifi64.exe process..." -ForegroundColor White
        try {
            $process = Get-Process -Name "PDTWifi64" -ErrorAction SilentlyContinue
            if ($process) {
                Stop-Process -Name "PDTWifi64" -Force -ErrorAction Stop
                Write-Host "PDTWifi64.exe process stopped successfully." -ForegroundColor Green
            } else {
                Write-Host "PDTWifi64.exe process is not running. No need to stop." -ForegroundColor Green
            }
        } catch {
            Write-Host "Warning: Failed to stop PDTWifi64.exe: $($_.Exception.Message). It might be in use, attempting to continue." -ForegroundColor Yellow
            # Continue even if stopping fails, as the Move-Item might still work if the file isn't exclusively locked.
        }

        # 1.4.2 - Move Current Version to a Backup Folder (if it exists)
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.4.2 - Backing up current PDTWifi64.exe (if exists)..." -ForegroundColor White
        if (Test-Path $currentVersionPath -PathType Leaf) {
            try {
                # Create the backup directory if it doesn't exist
                if (-not (Test-Path $backupPath -PathType Container)) {
                    New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
                    Write-Host "Backup directory '$backupPath' created." -ForegroundColor DarkGray
                }
                $timestamp = Get-Date -Format "yyyyMMddHHmmss"
                $newFileName = "PDTWifi64_$timestamp.exe"
                $destinationPath = Join-Path $backupPath $newFileName
                
                Move-Item -Path $currentVersionPath -Destination $destinationPath -Force -ErrorAction Stop
                Write-Host "Original PDTWifi64.exe successfully moved to '$destinationPath'." -ForegroundColor Green
            } catch {
                Write-Host "Error: Failed to move original version to backup. Upgrade cannot proceed: $($_.Exception.Message)" -ForegroundColor Red
                return $false # Return failure
            }
        } else {
            Write-Host "No existing PDTWifi64.exe to backup." -ForegroundColor Yellow
        }

        # 1.4.3 - Deploy New Version
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.4.3 - Deploying the new version of PDTWifi64.exe..." -ForegroundColor White
        try {
            # The new version is already in $tempDownloadPath from step 1.2
            Move-Item -Path $tempDownloadPath -Destination $currentVersionPath -Force -ErrorAction Stop
            Write-Host "New PDTWifi64.exe successfully moved into place at '$currentVersionPath'." -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to move new version into place. Upgrade failed: $($_.Exception.Message)" -ForegroundColor Red
            return $false # Return failure
        }

        # 1.4.4 - Launch New Version
        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "1.4.4 - Launching the updated PDTWifi64.exe..." -ForegroundColor White
        try {
            Start-Process -FilePath $currentVersionPath -ErrorAction Stop
            Write-Host "PDTWifi64.exe launched successfully." -ForegroundColor Green
        } catch {
            Write-Host "Error: Failed to launch the new version of PDTWifi64.exe: $($_.Exception.Message). Please launch it manually." -ForegroundColor Red
            return $false # Return failure
        }

        Write-Host "---" -ForegroundColor DarkGray
        Write-Host "Upgrade process completed successfully." -ForegroundColor Green
        return $true # Return success for the entire operation

    } finally {
        # Ensure temporary file is cleaned up regardless of success or failure
        if (Test-Path $tempDownloadPath -PathType Leaf) {
            Write-Host "Cleaning up temporary download file: '$tempDownloadPath'." -ForegroundColor DarkGray
            Remove-Item -Path $tempDownloadPath -Force -ErrorAction SilentlyContinue
        }
    }
}

# PartVersion: 1.3
#LOCK=OFF
# Execute the main function and handle its return value
# This block ensures that the script, when run directly, still provides an
# overall status message, but crucially, it does NOT use 'exit' to terminate
# the PowerShell session, allowing it to be sourced by other scripts.
$upgradeStatus = Invoke-PDTWifi64Upgrade

if ($upgradeStatus) {
    Write-Host "Script execution completed successfully." -ForegroundColor Green
} else {
    Write-Host "Script execution completed with errors or upgrade was not performed successfully." -ForegroundColor Red
}
