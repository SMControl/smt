Write-Host "smt.ps1 - Version 1.62" # Script version incremented due to changes

# Part 3 - Define Task Variables
# PartVersion-1.3
#LOCK=OFF
# This section defines the names and corresponding URLs for the various tasks available in the SM Tools menu.
# These variables are used throughout the script to display menu options and launch the selected tasks.
$task1Name = "SO Upgrade Assistant"
$task1Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$task2Name = "SM Firebird Installer 32bit"
$task2Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/modules/module_firebird.ps1"
$task3Name = "SM Firebird Installer 64bit"
$task3Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/modules/module_firebird64.ps1"
$task4Name = "SM Scheduled Tasks"
$task4Url = "https://raw.githubusercontent.com/SMControl/SM_Tasks/refs/heads/main/SM_Tasks.ps1"
$task5Name = "PDTWifi Upgrade (WIP)"
$task5Url = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1"
$task6Name = "PC Transfer (WIP)"
$task6Url = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1"


# Function to display menu and get user selection
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.59 # Part version incremented due to color logic for Firebird installer
    #LOCK=OFF
    # Clears the console and displays the main menu options to the user.
    # It then prompts the user for their choice and returns it.
    Clear-Host
    Write-Host "SM Tools" -ForegroundColor Yellow
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "-------------------------" -ForegroundColor Cyan

    # Determine the color for the "SM Firebird Installer 32bit" entry based on folder existence
    $firebird32FolderPath = "C:\Program Files (x86)\Firebird\Firebird_4_0"
    if (Test-Path $firebird32FolderPath -PathType Container) {
        $firebird32Color = "Green" # 32bit Folder exists, display in green
    } else {
        $firebird32Color = "Yellow" # 32bit Folder does not exist, display in yellow
    }
    
    # Determine the color for the "SM Firebird Installer 64bit" entry based on folder existence
    $firebird64FolderPath = "C:\Program Files\Firebird"
    if (Test-Path $firebird64FolderPath -PathType Container) {
        $firebird64Color = "Green" # 64bit Folder exists, display in green
    } else {
        $firebird64Color = "Yellow" # 64bit Folder does not exist, display in yellow
    }

    $menuOptions = @(
        "1. $task1Name",
        "2. $task2Name", # 32bit Installer - handled separately for color
        "3. $task3Name", # 64bit Installer - handled separately for color
        "4. $task4Name",
        "5. $task5Name",
        "6. $task6Name"
    )
    # Loop through the defined menu options and display them.
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        # Special handling for the Firebird Installer entries to apply dynamic color
        if ($i -eq 1) { # Index 1 corresponds to task2Name (SM Firebird Installer 32bit)
            Write-Host $menuOptions[$i] -ForegroundColor $firebird32Color
        } elseif ($i -eq 2) { # New index 2 corresponds to task3Name (SM Firebird Installer 64bit)
            Write-Host $menuOptions[$i] -ForegroundColor $firebird64Color
        } else {
            Write-Host $menuOptions[$i]
        }
    }
    # Prompt the user for their selection.
    $choice = Read-Host "`nEnter your choice (or press Enter to quit)" # Added `n for a new line for better readability
    return $choice
}

# Function to launch the selected task
function Launch-Task ($taskName, $launchCommand, $external = $false) {
    # Part 2 - Launch Task
    # PartVersion-1.52
    #LOCK=OFF
    # This function is responsible for launching the selected task.
    # It can either execute the script directly or open it in a new PowerShell window.
    Write-Host "Launching $taskName..." -ForegroundColor Green
    if ($external) {
        # Launch the script in a new PowerShell window, keeping the window open after execution.
        Start-Process powershell.exe -ArgumentList "-NoExit -Command ""$launchCommand"""
    } else {
        # Execute the command by downloading the script from the URL and invoking it.
        # irm (Invoke-RestMethod) downloads the content, and iex (Invoke-Expression) executes it.
        try {
            Invoke-Expression "irm $launchCommand | iex"
        } catch {
            # Catch any errors during the launch process and display an error message in red.
            Write-Host "Error launching $taskName. Error Details: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 5 # Pause to allow the user to read the error message
        }
    }
}


# Main script logic function
function Run-Main-Logic {
    # Part 4 - Main Script Logic
    # PartVersion-1.53
    #LOCK=OFF
    # This is the core logic of the script, handling the menu display and task launching loop.
    do {
        # Display the menu and get the user's choice.
        $menuChoice = Show-Menu

        # Check if the user pressed 'Esc' (ASCII 27) to exit.
        if ($menuChoice -eq [char]27) {
            Write-Host "Exiting script..." -ForegroundColor Yellow
            break # Exit the do-while loop
        }

        # Use a switch statement to handle different user choices.
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
            "6" {
                Launch-Task $task6Name $task6Url
            }
            "" {
                # If the user presses Enter without typing anything, exit the script.
                Write-Host "Exiting..." -ForegroundColor Yellow
                break # Exit the do-while loop
            }
            default {
                # Handle invalid choices, display an error message in red.
                Write-Host "Invalid choice. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2 # Pause briefly before redisplaying the menu
            }
        }
    } while ($menuChoice -ne "") # Continue the loop until the user chooses to exit (empty input)
}

# Call the main logic function to start the script execution.
Run-Main-Logic
