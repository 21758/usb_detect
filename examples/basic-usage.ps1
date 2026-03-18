# basic-usage.ps1
# Basic usage examples for SD detection module

# Import the module
$ModulePath = Join-Path $PSScriptRoot "..\scripts\sd-detect.ps1"
. $ModulePath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SD Detection Module - Usage Examples" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Example 1: List all removable devices
Write-Host "[Example 1] List all removable devices" -ForegroundColor Yellow
Write-Host "Command: Get-PhysicalSD`n" -ForegroundColor Gray

$devices = Get-PhysicalSD
Write-Host "Found: $($devices.Count) device(s)`n" -ForegroundColor Cyan

# Example 2: Show formatted device list
Write-Host "[Example 2] Show formatted device list" -ForegroundColor Yellow
Write-Host "Command: Show-SDDeviceList`n" -ForegroundColor Gray

Show-SDDeviceList

# Example 3: Filter SD cards only
Write-Host "[Example 3] Filter SD cards only" -ForegroundColor Yellow
Write-Host "Command: Get-PhysicalSD | Where-Object { `$_.IsSDCard }`n" -ForegroundColor Gray

$sdCards = Get-PhysicalSD | Where-Object { $_.IsSDCard }

if ($sdCards.Count -gt 0) {
    Write-Host "SD Cards found:" -ForegroundColor Green
    foreach ($card in $sdCards) {
        Write-Host "  - PhysicalDrive$($card.DiskNumber): $($card.SizeGB) - $($card.Model)" -ForegroundColor White
    }
} else {
    Write-Host "No SD cards detected" -ForegroundColor Yellow
}

Write-Host ""

# Example 4: Test specific device
Write-Host "[Example 4] Test specific device properties" -ForegroundColor Yellow
Write-Host "Command: Test-IsSDCard`n" -ForegroundColor Gray

$testDisk = @{
    Model     = "SD Card Reader"
    MediaType = "Removable Media"
    Size      = 32GB
}

$result = Test-IsSDCard $testDisk
Write-Host "Test Disk: $($testDisk.Model)" -ForegroundColor White
Write-Host "Is SD Card: $result" -ForegroundColor $(if ($result) { "Green" } else { "Red" })

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Examples Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
