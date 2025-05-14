Write-Host "smt.ps1 - Version 1.38"
# Provides a menu of tasks to perform, shows details, and launches them.
# 
# Function to display menu and get user selection
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.38
    # -----
    Clear-Host
    Write-Host "SM Tools" -ForegroundColor Yellow
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "-------------------------" -ForegroundColor Cyan
    Write-Host "1. SO Upgrade Assistant"
    Write-Host "2. SM Firebird Installer"
    Write-Host "3. PDTWifi64 Upgrade"
    Write-Host "4. Setup new PC (Testing)"
    Write-Host "5. SM Services (Testing)"
    Write-Host "Press Enter to Exit"
}

# Function to display task details and launch option
function Show-Task-Details ($taskName, $taskDescription, $launchCommand, $external = $false) {
    # Part 2 - Display Task Details and Launch Option
    # PartVersion-1.38
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
            if ($external) {
                # Launch in a new PowerShell window
                Start-Process powershell.exe -ArgumentList "-NoExit -Command ""$launchCommand"""
                
            } else {
                # Execute the command using irm and iex
                try {
                    Invoke-Expression "irm $launchCommand | iex"
                } catch {
                    Write-Host "Error launching $taskName $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 5
                }
                Write-Host "Press Enter to return to the main menu..." -ForegroundColor Yellow
                Read-Host
            }
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
# PartVersion-1.38
# -----

# Define URLs for each task
$smartOfficeUpgradeUrl = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$stationmasterFirebirdUrl = "https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1"
$pdtWifi64UpgradeUrl = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1"
$winsmUpdateUrl = "https://your-winsmupdate.com/update.ps1"
$newPCSetupUrl = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1"
$smServicesUrl = "https://your-smservices.com/SM_Services.ps1"

# Function to run the main script logic
function Run-Main-Logic {
    # Part 4 - Main Script Logic
    # PartVersion-1.38
    # -----
    do {
        $menuChoice = Show-Menu
    
        switch ($menuChoice) {
            "1" {
                try {
                    Show-Task-Details "SO Upgrade Assistant" "This tool assists with the Pre and Post aspects of upgrading Smart Office." $smartOfficeUpgradeUrl
                } catch {
                    Write-Host "Failed to launch Smart Office Upgrade Assistant.  Error: $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 5
                }
            }
            "2" {
                try {
                    Show-Task-Details "SM Firebird Installer" "Fully and automatically installs Firebird with our required settings." $stationmasterFirebirdUrl
                } catch {
                    Write-Host "Failed to launch Stationmaster Firebird Installer. Error: $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 5
                }
            }
            "3" {
                try {
                    Show-Task-Details "PDTWifi64 Upgrade" "Pulls latest PDTWifi64.exe." $pdtWifi64UpgradeUrl
                } catch {
                    Write-Host "Failed to launch PDTWifi64 Upgrade. Error: $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 5
                }
            }
            "4" {
                try {
                    Show-Task-Details "Setup new PC" "Assistant Script to help guide through new PC Setup. EARLY TESTING" $newPCSetupUrl
                } catch {
                    Write-Host "Failed to launch Setup new PC. Error: $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 5
                }
            }
            "5" {
                try {
                    Show-Task-Details "SM Services" "Manage all SM Windows Services. NOT IMPLEMENTED YET" $smServicesUrl
                } catch {
                    Write-Host "Failed to launch SM Services. Error: $($_.Exception.Message)" -ForegroundColor Red
                    Start-Sleep -Seconds 5
                }
            }
            "" {
                Write-Host "Exiting..." -ForegroundColor Yellow
                break
            }
            default {
                Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($menuChoice -ne "")
}

# Call the main logic function
Run-Main-Logic
