# Script Name: Find-WiscloudManufacturers.ps1
# Script Version: 2.1

# PartVersion: 1.0 #LOCK=OFF
# Part 1: Script Initialization and Setup
# This part initializes the script and defines helper functions for colored output.

Write-Host "Find WISCLOUD Manufacturers on Network - Version 2.1" -ForegroundColor Green

function Write-ColorMessage {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# PartVersion: 1.2 #LOCK=OFF
# Part 2: MAC Address to Manufacturer Lookup Function
# This function attempts to resolve a MAC address's OUI to a known manufacturer
# by querying an online OUI database.
function Get-MacManufacturer {
    param (
        [string]$MacAddress
    )

    # Clean the MAC address (remove dashes, colons, spaces)
    $cleanedMac = $MacAddress -replace "[-:]", ""

    # Ensure the MAC address is valid and long enough for OUI lookup (first 6 hex characters)
    if ($cleanedMac.Length -lt 6) {
        return "Unknown (Invalid MAC Format)"
    }

    # API endpoint for MAC address vendor lookup
    # Note: Relying on external APIs means the script requires internet access.
    # Be mindful of potential API rate limits if performing many lookups.
    $apiUrl = "https://api.macvendors.com/$cleanedMac"

    try {
        # Make a web request to the MAC Vendors API
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop

        # The API returns the manufacturer name directly if found, or an error if not.
        # If the response is not empty, assume it's the manufacturer.
        if (-not [string]::IsNullOrEmpty($response)) {
            return $response
        } else {
            return "Unknown Manufacturer (API Lookup Failed)"
        }
    }
    catch {
        # Handle errors during the API call (e.g., no internet, API down, MAC not found by API)
        # If the API returns a 404 (Not Found), it means the MAC is not in their database.
        if ($_.Exception.Response.StatusCode -eq 404) {
            return "Unknown Manufacturer (Not Found in API)"
        } else {
            # For other errors (e.g., network issues, API rate limit)
            Write-ColorMessage "Warning: API lookup failed for MAC $MacAddress. Error: $($_.Exception.Message)" -Color Yellow
            return "Unknown Manufacturer (API Error)"
        }
    }
}

# PartVersion: 1.1 #LOCK=OFF
# Part 3: Get Network Neighbors (ARP Cache)
# This part retrieves the current network neighbor (ARP) cache using Get-NetNeighbor.
# It includes error handling for cases where the cmdlet might not be available.

Write-ColorMessage "`nAttempting to retrieve network neighbor information..." -Color Cyan

try {
    # Get-NetNeighbor is available on Windows 8/Server 2012 and later.
    # Filtering for IPv4 addresses only.
    $neighbors = Get-NetNeighbor | Where-Object {
        ($_.State -eq 'Reachable' -or $_.State -eq 'Stale' -or $_.State -eq 'Permanent') -and
        ($_.AddressFamily -eq 'IPv4')
    }

    if (-not $neighbors) {
        Write-ColorMessage "No active IPv4 network neighbors found in the ARP cache." -Color Yellow
        exit
    }
}
catch {
    Write-ColorMessage "Error: Could not retrieve network neighbors. `nThis might be because 'Get-NetNeighbor' cmdlet is not available on your system (requires Windows 8/Server 2012 or newer), or due to insufficient permissions." -Color Red
    Write-ColorMessage "Please try running PowerShell as an administrator." -Color Red
    exit
}

# PartVersion: 1.9 #LOCK=OFF
# Part 4: Process and Display Results
# This part iterates through the retrieved network neighbors, looks up manufacturer names,
# and formats the output into a readable table, including an estimated time until results.
# It now filters the results to only show "WISCLOUD" manufacturers.

Write-ColorMessage "`nProcessing network neighbors to find WISCLOUD devices..." -Color Cyan

$results = @()
$processedCount = 0
$sleepDurationSeconds = 2.2

# Filter neighbors to count only those with a MAC address for accurate ETA calculation
$neighborsToProcess = $neighbors | Where-Object { -not [string]::IsNullOrEmpty($_.LinkLayerAddress) }
$totalExpectedLookups = $neighborsToProcess.Count
$estimatedTotalSeconds = $totalExpectedLookups * $sleepDurationSeconds

foreach ($neighbor in $neighborsToProcess) {
    $ipAddress = $neighbor.IPAddress.ToString()
    $macAddress = $neighbor.LinkLayerAddress

    # Only process if a MAC address exists (already filtered, but good for robustness)
    if (-not [string]::IsNullOrEmpty($macAddress)) {
        $processedCount++
        $interfaceAlias = $neighbor.InterfaceAlias
        $state = $neighbor.State

        # Calculate percentage complete and remaining seconds for Write-Progress
        $percentComplete = [int](($processedCount / $totalExpectedLookups) * 100)
        $secondsRemaining = [int](($totalExpectedLookups - $processedCount) * $sleepDurationSeconds)

        # Display ticking ETA using Write-Progress
        Write-Progress -Activity "Looking up Manufacturer" `
                       -Status "Processing IP: $ipAddress (MAC: $macAddress)" `
                       -PercentComplete $percentComplete `
                       -SecondsRemaining $secondsRemaining `
                       -CurrentOperation "Processed $processedCount of $totalExpectedLookups"

        $manufacturer = Get-MacManufacturer -MacAddress $macAddress

        $results += [PSCustomObject]@{
            'IP Address'     = $ipAddress
            'MAC Address'    = $macAddress
            'Manufacturer'   = $manufacturer
            'Interface'      = $interfaceAlias
            'State'          = $state
        }
        # Add a delay to respect API rate limits
        Start-Sleep -Seconds $sleepDurationSeconds
    }
}

# Clear the progress bar after completion
Write-Progress -Activity "Looking up Manufacturer" -Status "Completed" -Completed

# Filter results to only show WISCLOUD manufacturers
$wiscloudResults = $results | Where-Object { $_.Manufacturer -eq "WISCLOUD" }

# Display the results in a formatted table
if ($wiscloudResults.Count -gt 0) {
    # Clear the host console before displaying the table
    Clear-Host
    Write-ColorMessage "`n--- Found WISCLOUD Network Devices ---" -ForegroundColor Green

    # Define column headers and determine maximum widths for formatting
    $columnHeaders = @('IP Address', 'MAC Address', 'Manufacturer', 'Interface', 'State')
    $columnWidths = @{}
    $padding = 3 # Padding between columns

    # Initialize column widths with header lengths
    foreach ($header in $columnHeaders) {
        $columnWidths[$header] = $header.Length
    }

    # Update column widths based on data lengths from WISCLOUD results
    foreach ($item in $wiscloudResults) {
        foreach ($header in $columnHeaders) {
            $value = $item.$header.ToString()
            if ($value.Length -gt $columnWidths[$header]) {
                $columnWidths[$header] = $value.Length
            }
        }
    }

    # Get a copy of the keys before iterating and modifying the hash table
    $keysToPad = $columnWidths.Keys | Select-Object -Unique

    # Add padding to final column widths
    foreach ($key in $keysToPad) { # Iterate over the copy of keys
        $columnWidths[$key] += $padding
    }

    # Print table header
    $headerLine = ""
    foreach ($header in $columnHeaders) {
        $headerLine += $header.PadRight($columnWidths[$header])
    }
    Write-Host $headerLine -ForegroundColor Cyan

    # Print separator line
    Write-Host ("-" * $headerLine.Length) -ForegroundColor DarkGray

    # Print data rows (all will be WISCLOUD, so no special coloring needed)
    foreach ($item in $wiscloudResults) {
        $line = ""
        foreach ($header in $columnHeaders) {
            $value = $item.$header.ToString()
            $line += $value.PadRight($columnWidths[$header])
        }
        Write-Host $line -ForegroundColor White # Default color for all filtered results
    }

    Write-ColorMessage "`nScan complete. All listed devices are from WISCLOUD." -ForegroundColor Green
} else {
    Clear-Host # Clear screen even if no results
    Write-ColorMessage "No IPv4 network neighbors with valid MAC addresses from 'WISCLOUD' were found on your network." -Color Yellow
}
