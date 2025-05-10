Write-Host "smt.ps1 - Version 1.22"
# Provides a menu of tasks to perform, shows details, and launches them.
# 
# Function to display menu and get user selection
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.22
    # -----
    Clear-Host
    Write-Host "SM Tools" -ForegroundColor Yellow
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "-------------------------" -ForegroundColor Cyan # Added line
    Write-Host "1. Smart Office Upgrade Assistant"
    Write-Host "2. Stationmaster Firebird Installer"
    Write-Host "3. PDTWifi64 Upgrade"
    Write-Host "4. Update winsm with latest (Testing)" # Tagged as Testing
    Write-Host "5. Windows 11 Debloat"
    Write-Host "6. Windows Setup Utility"
    Write-Host "7. Setup new PC (Testing)" # Tagged as Testing
    Write-Host "8. Exit"      # Changed exit option number
    Read-Host "Enter your choice"
}

# Function to display task details and launch option
function Show-Task-Details ($taskName, $taskDescription, $launchCommand) {
    # Part 2 - Display Task Details and Launch Option
    # PartVersion-1.22
    # -----
    Clear-Host
    Write-Host $taskName -ForegroundColor Yellow
    Write-Host "Description: $taskDescription" -ForegroundColor Cyan
    Write-Host " "
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "1. Launch"
    Write-Host "2. Back to Main Menu"
    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" {
            Write-Host "Launching $taskName..." -ForegroundColor Green
            # Use Start-Process to run in a new window and wait for it to finish.
            Start-Process powershell.exe -ArgumentList "-NoExit -Command ""$launchCommand"""
            # No need for the Read-Host "Press Enter..." here, the -NoExit parameter keeps the window open
        }
        "2" {
            # Do nothing, the script will return to the main menu
        }
        default {
            Write-Host "Invalid choice. Returning to main menu." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
}

# Part 3 - Main Script Logic
# PartVersion-1.22
# -----

# Define URLs for each task
$smartOfficeUpgradeUrl = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$stationmasterFirebirdUrl = "https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1"
$pdtWifi64UpgradeUrl = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1" # Updated URL for Task 3
$winsmUpdateUrl = "https://your-winsmupdate.com/update.ps1"
$windows11DebloatCommand = "& ([scriptblock]::Create((irm ""https://debloat.raphi.re/""))) -RunDefaults -Silent"
$windowsSetupUtilityUrl = "christitus.com/win"
$newPCSetupUrl = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1"

do {
    $menuChoice = Show-Menu

    switch ($menuChoice) {
        "1" {
            try {
                Show-Task-Details "Smart Office Upgrade Assistant" "This tool assists with the Pre and Post aspects of upgrading Smart Office." "irm $smartOfficeUpgradeUrl | iex"
            } catch {
                Write-Host "Failed to launch Smart Office Upgrade Assistant.  Error: $($_.Exception.Message)" -ForegroundColor Red
                Start-Sleep -Seconds 5
            }
        }
        "2" {
            try {
                Show-Task-Details "Stationmaster Firebird Installer" "Fully and automatically installs Firebird with our required settings." "irm $stationmasterFirebirdUrl | iex"
            } catch {
                Write-Host "Failed to launch Stationmaster Firebird Installer. Error: $($_.Exception.Message)" -ForegroundColor Red
                Start-Sleep -Seconds 5
            }
        }
        "3" {
            try {
                Show-Task-Details "PDTWifi64 Upgrade" "Pulls latest PDTWifi64.exe." "irm $pdtWifi64UpgradeUrl | iex"
            } catch {
                Write-Host "Failed to launch PDTWifi64 Upgrade. Error: $($_.Exception.Message)" -ForegroundColor Red
                Start-Sleep -Seconds 5
            }
        }
        "4" {
            try {
                Show-Task-Details "Update winsm with latest" "Pulls latest of various common winsm tools, Handheld APK's, PDTWifi's etc." "irm $winsmUpdateUrl | iex"
            } catch {
                Write-Host "Failed to launch Update winsm with latest. Error: $($_.Exception.Message)" -ForegroundColor Red
                Start-Sleep -Seconds 5
            }
        }
        "5" {
            Show-Task-Details "Windows 11 Debloat" "This tool removes unnecessary apps and services from Windows 11, improving system performance and reducing resource usage." "$windows11DebloatCommand"
        }
        "6" {
            try {
                Show-Task-Details "Windows Setup Utility" "This tool launches the Windows Setup Utility, allowing for customization of Windows installation options." "irm $windowsSetupUtilityUrl | iex"
            } catch {
                Write-Host "Failed to launch Windows Setup Utility. Error: $($_.Exception.Message)" -ForegroundColor Red
                Start-Sleep -Seconds 5
            }
        }
        "7" {
            try {
                Show-Task-Details "Setup new PC" "Assistant Script to help guide through new PC Setup." "irm $newPCSetupUrl | iex"
            } catch {
                Write-Host "Failed to launch Setup new PC. Error: $($_.Exception.Message)" -ForegroundColor Red
                Start-Sleep -Seconds 5
            }
        }
        "8" { # Changed from 7 to 8
            Write-Host "Exiting..." -ForegroundColor Yellow
            break # Exit the do-while loop
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
    }
} while ($menuChoice -ne "8") # Changed from 7 to 8
