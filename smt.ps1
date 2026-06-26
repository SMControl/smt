# Increament Version number each time we update script
Write-Host "smt.ps1 - Version 1.63"
# Part 0 - Set Window Geometry
# PartVersion-1.0
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
# PartVersion-1.1
$task1Name = "SO Upgrade Assistant"
$task1Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/main/soua.ps1"
$task2Name = "SM Firebird Installer"
$task2Url = "https://raw.githubusercontent.com/SMControl/SO_Upgrade/refs/heads/main/modules/module_firebird.ps1"
$task3Name = "SM Scheduled Tasks"
$task3Url = "https://raw.githubusercontent.com/SMControl/SM_Tasks/refs/heads/main/SM_Tasks.ps1"
# $task4Name = "PDTWifi Upgrade (WIP)" # DISABLED
# $task4Url = "https://raw.githubusercontent.com/SMControl/smt/refs/heads/main/modules/PDTWifi64_Upgrade.ps1" # DISABLED
# $task5Name = "PC Transfer (WIP)" # DISABLED
# $task5Url = "https://raw.githubusercontent.com/SMControl/smpc/refs/heads/main/smpc.ps1" # DISABLED
function Show-Menu {
    # Part 1 - Display Menu Options
    # PartVersion-1.58
    Clear-Host
    Write-Host "SM Tools" -ForegroundColor Yellow
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "-------------------------" -ForegroundColor Cyan
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
        "3. $task3Name"
        # "4. $task4Name" # DISABLED
        # "5. $task5Name" # DISABLED
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
    # PartVersion-1.52
    Write-Host "Launching $taskName..." -ForegroundColor Green
    if ($external) {
        Start-Process powershell.exe -ArgumentList "-NoExit -Command ""$launchCommand"""
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
    # PartVersion-1.53
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
            # "4" { Launch-Task $task4Name $task4Url } # DISABLED - PDTWifi Upgrade (WIP)
            # "5" { Launch-Task $task5Name $task5Url } # DISABLED - PC Transfer (WIP)
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
