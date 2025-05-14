Write-Host "smt.ps1 - Version 1.44"
# Provides a menu of tasks to perform, and launches them directly.
# 
# Function to display menu and get user selection
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.44
    # -----
    Clear-Host
    Write-Host "SM Tools" -ForegroundColor Yellow
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "-------------------------" -ForegroundColor Cyan
    $menuOptions = @(
        "1. SO Upgrade Assistant",
        "2. SM Firebird Installer",
        "3. PDTWifi64 Upgrade",
        "4. Setup new PC (Testing)",
        "5. SM Services (Testing)",
        "Press Enter to Exit"
    )
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        Write-Host $menuOptions[$i]
    }
    $choice = Read-Host "Enter your choice"
    return $choice
}

# Function to launch the selected task
function Launch-Task ($taskName, $launchCommand, $external = $false) {
    # Part 2 - Launch Task
    # PartVersion-1.44
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
            Write-Host "Error launching $taskName $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 5
        }
    }
}

# Part 3 - Main Script Logic
# PartVersion-1.44
# -----

# Define URLs for each task
$taskUrls = @{
    "1" = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
    "2" = "https://raw.githubusercontent.com/SMControl/SM_Firebird_Installer/main/SMFI_Online.ps1"
    "3" = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1"
    "4" = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1"
    "5" = "https://your-smservices.com/SM_Services.ps1"
}

function Run-Main-Logic {
    # Part 4 - Main Script Logic
    # PartVersion-1.44
    # -----
    do {
        $menuChoice = Show-Menu
    
        switch ($menuChoice) {
            "1" {
                Launch-Task "SO Upgrade Assistant" $taskUrls["1"]
            }
            "2" {
                Launch-Task "SM Firebird Installer" $taskUrls["2"]
            }
            "3" {
                Launch-Task "PDTWifi64 Upgrade" $taskUrls["3"]
            }
            "4" {
                Launch-Task "Setup new PC" $taskUrls["4"]
            }
            "5" {
                Launch-Task "SM Services" $taskUrls["5"]
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
        Write-Host "Press Enter to return to the main menu..." -ForegroundColor Yellow
        Read-Host
    } while ($menuChoice -ne "")
}

# Call the main logic function
Run-Main-Logic
