# sd-detect-json.ps1
# Outputs SD card device list in JSON format for GUI

# Import the main detection module
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $ScriptDir "sd-detect.ps1")

<#
.SYNOPSIS
    Get SD card devices and output as JSON
.PARAMETER AsJson
    Output as JSON format (always true for this script)
.OUTPUTS
    JSON string representing SD card devices
#>
function Get-PhysicalSD {
    [CmdletBinding()]
    param(
        [switch]$AsJson = $true  # Always output JSON
    )

    # Call the original function
    $devices = & (Get-Command Get-PhysicalSD).ScriptBlock.Invoke(@())

    # Output as JSON
    $devices | ConvertTo-Json -Compress
}
