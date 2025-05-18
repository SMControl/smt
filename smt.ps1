Write-Host "smt.ps1 - Version 1.52"

# Define task names and URLs
$task1Name = "SO Upgrade Assistant"
$task1Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$task2Name = "SM Firebird Installer"
$task2Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/modules/module_firebird.ps1"
$task3Name = "SM Tasks (Testing)"
$task3Url = "https://your-smservices.com/SM_Services.ps1"
$task4Name = "PDTWifi64 Upgrade"
$task4Url = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1"
$task5Name = "Setup new PC (Testing)"
$task5Url = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1"


# Function to display menu and get user selection
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.51
    # -----
    Clear-Host
    Write-Host "SM Tools" -ForegroundColor Yellow
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "-------------------------" -ForegroundColor Cyan
    $menuOptions = @(
        "1. $task1Name",
        "2. $task2Name",
        "3. $task3Name",
        "4. $task4Name",
        "5. $task5Name",
        "Press Enter to Exit"
    )
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        Write-Host $menuOptions[$i]
    }
    $choice = Read-Host "Enter your choice (or press Esc to quit)"
    return $choice
}

# Function to launch the selected task
function Launch-Task ($taskName, $launchCommand, $external = $false) {
    # Part 2 - Launch Task
    # PartVersion-1.51
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



function Run-Main-Logic {
    # Part 4 - Main Script Logic
    # PartVersion-1.51
    # -----
    do {
        $menuChoice = Show-Menu
    
        if ($menuChoice -eq [char]27) {
            Write-Host "Exiting script..." -ForegroundColor Yellow
            break
        }
    
        switch ($menuChoice) {
            "1" {
                Launch-Task $task1Name $task1Url
            }
            "2" {
                Launch-Task $task2Name $task2Url
            }
            "3" {
                Launch-Task $task3Name $task3Url
            }
            "4" {
                Launch-Task $task4Name $task4Url
            }
            "5" {
                Launch-Task $task5Name $task5Url
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
        # Removed the  "Press Enter to return to the main menu..." and Read-Host lines
    } while ($menuChoice -ne "")
}

# Call the main logic function
Run-Main-Logic
