Write-Host "smt.ps1 - Version 1.39"
# Provides a menu of tasks to perform, and launches them directly.
# 
# Function to display menu and get user selection
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.39
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
    $choice = Read-Host "Enter your choice"
    return $choice
}

# Function to launch the selected task
function Launch-Task ($taskName, $launchCommand, $external = $false) {
    # Part 2 - Launch Task
    # PartVersion-1.39
    # -----
    Write-Host "Launching $taskName..." -ForegroundColor Green
    if ($external) {
        # Launch in a new PowerShell window
        Start-Process powershell.exe -ArgumentList "-NoExit -Command ""$launchCommand"""        
    } else {
        # Execute the command using irm and iex
        try {
            Invoke-Expression "irm $launchCommand | iex"
        } catch {
            Write-Host "Error launching $taskName: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 5
        }
    }
}

# Part 3 - Main Script Logic
# PartVersion-1.39
# -----

# Define URLs for each task
$smartOfficeUpgradeUrl = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$stationmasterFirebirdUrl = "https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1"
$pdtWifi64UpgradeUrl = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1"
$newPCSetupUrl = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1"
$smServicesUrl = "https://your-smservices.com/SM_Services.ps1"

# Function to run the main script logic
function Run-Main-Logic {
    # Part 4 - Main Script Logic
    # PartVersion-1.39
    # -----
    do {
        $menuChoice = Show-Menu
    
        switch ($menuChoice) {
            "1" {
                Launch-Task "SO Upgrade Assistant" $smartOfficeUpgradeUrl
            }
            "2" {
                Launch-Task "SM Firebird Installer" $stationmasterFirebirdUrl
            }
            "3" {
                Launch-Task "PDTWifi64 Upgrade" $pdtWifi64UpgradeUrl
            }
            "4" {
                Launch-Task "Setup new PC" $newPCSetupUrl
            }
            "5" {
                Launch-Task "SM Services" $smServicesUrl
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
        Write-Host "Press Enter to return to the main menu..." -ForegroundColor Yellow # added this line
        Read-Host # added this line
    } while ($menuChoice -ne "")
}

# Call the main logic function
Run-Main-Logic
