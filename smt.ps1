# smt.ps1 v1.64
Write-Host "smt.ps1 - Version 1.64"
# Part 0 - Set Window Geometry
# [PartVersion v1.0]
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Window {
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    }
"@
$consoleWindow = [Window]::GetConsoleWindow()
Add-Type -AssemblyName System.Windows.Forms
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height
$windowHeight = 300
$windowWidth = 500
$posY = $screenHeight - $windowHeight
[Window]::MoveWindow($consoleWindow, 0, $posY, $windowWidth, $windowHeight, $true) | Out-Null
# Part 3 - Define Task Variables
# [PartVersion v1.2]
$task1Name = "SO Upgrade Assistant"
$task1Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$task2Name = "SM Firebird 3 Installer"
$task2Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/modules/module_firebird.ps1"
$task3Name = "SM Firebird 5 Installer"
$task3Url = "" # Placeholder URL
$task4Name = "SM Scheduled Tasks"
$task4Url = "https://raw.githubusercontent.com/SMControl/SM_Tasks/refs/heads/main/SM_Tasks.ps1"
# $task5Name = "PDTWifi Upgrade (WIP)" # DISABLED
# $task5Url = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1" # DISABLED
# $task6Name = "PC Transfer (WIP)" # DISABLED
# $task6Url = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1" # DISABLED
function Show-Menu {
    # Part 1 - Display Menu Options
    # [PartVersion v1.60]
    Clear-Host
    # Print the tool title in yellow (info color)
    Write-Host "SM Tools" -ForegroundColor Yellow
    # Print the menu prompt using default gray (the default text color)
    Write-Host "Please select an option:"
    Write-Host "-------------------------"
    $firebirdFolderPath = "C:\Program Files (x86)\Firebird\Firebird_4_0"
    if (Test-Path $firebirdFolderPath -PathType Container) {
        $firebirdColor = "Green"
    }
    else {
        $firebirdColor = "Yellow"
    }
    $menuOptions = @(
        "1. $task1Name",
        "2. $task2Name",
        "3. $task3Name",
        "4. $task4Name"
        # "5. $task5Name" # DISABLED
        # "6. $task6Name" # DISABLED
    )
    for ($i = 0; $i -lt $menuOptions.Count; $i++) {
        if ($i -eq 1) {
            Write-Host $menuOptions[$i] -ForegroundColor $firebirdColor
        }
        else {
            Write-Host $menuOptions[$i]
        }
    }
    $choice = Read-Host "`nEnter your choice (or press Enter to quit)"
    return $choice
}
function Launch-Task ($taskName, $launchCommand, $external = $false) {
    # Part 2 - Launch Task
    # [PartVersion v1.53]
    # Output success message to the user in green
    Write-Host "Launching $taskName..." -ForegroundColor Green
    if ($external) {
        # Launch powershell.exe with -NoProfile flag as mandatory
        Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -Command ""$launchCommand"""
    }
    else {
        try {
            Invoke-Expression "irm $launchCommand | iex"
        }
        catch {
            Write-Host "Error launching $taskName. Error Details: $($_.Exception.Message)" -ForegroundColor Red
            Start-Sleep -Seconds 5
        }
    }
}
function Run-Main-Logic {
    # Part 4 - Main Script Logic
    # [PartVersion v1.54]
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
                if ([string]::IsNullOrWhiteSpace($task3Url)) {
                    Write-Host "Placeholder task: URL not configured yet." -ForegroundColor Yellow
                    Start-Sleep -Seconds 2
                }
                else {
                    Launch-Task $task3Name $task3Url
                }
            }
            "4" {
                Launch-Task $task4Name $task4Url
            }
            # "5" { Launch-Task $task5Name $task5Url } # DISABLED - PDTWifi Upgrade (WIP)
            # "6" { Launch-Task $task6Name $task6Url } # DISABLED - PC Transfer (WIP)
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
Run-Main-Logic
