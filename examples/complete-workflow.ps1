# complete-workflow.ps1
# Complete workflow example

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SD Card Image Writer - Demo" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ScriptPath = Join-Path $PSScriptRoot "..\scripts\sd-write.ps1"

# Step 1: Show help
Write-Host "[Step 1] Display help" -ForegroundColor Yellow
Write-Host "Command: .\scripts\sd-write.ps1`n" -ForegroundColor Gray
& $ScriptPath
Write-Host ""

# Step 2: List devices
Write-Host "[Step 2] List available devices" -ForegroundColor Yellow
& $ScriptPath -List
Write-Host ""

# Step 3: Device detection
Write-Host "[Step 3] Device detection" -ForegroundColor Yellow
. (Join-Path $PSScriptRoot "..\scripts\sd-detect.ps1")
$devices = Get-PhysicalSD
Write-Host "Devices found: $($devices.Count)`n" -ForegroundColor Cyan

# Step 4: SD card identification
Write-Host "[Step 4] SD card identification" -ForegroundColor Yellow

$test1 = @{ Model = "SD Card Reader"; MediaType = "Removable Media"; Size = 32GB }
$test2 = @{ Model = "External HDD"; MediaType = "Fixed hard disk media"; Size = 1TB }
$test3 = @{ Model = "USB Reader"; MediaType = "Removable Media"; Size = 16GB }

Write-Host "  SD Card Reader: $(Test-IsSDCard $test1)" -ForegroundColor Green
Write-Host "  External HDD: $(Test-IsSDCard $test2)" -ForegroundColor Red
Write-Host "  USB Reader: $(Test-IsSDCard $test3)`n" -ForegroundColor Green

# Step 5: Binary info
Write-Host "[Step 5] Go binary information" -ForegroundColor Yellow
$goExe = Join-Path $PSScriptRoot "..\bin\sd-write.exe"
if (Test-Path $goExe) {
    $info = Get-Item $goExe
    $size = [math]::Round($info.Length / 1MB, 2)
    Write-Host "  Size: $size MB" -ForegroundColor White
    Write-Host "  Version: 2.0`n" -ForegroundColor Cyan
}

# Step 6: Usage examples
Write-Host "[Step 6] Usage examples" -ForegroundColor Yellow
Write-Host "  1. List devices: .\scripts\sd-write.ps1 -List" -ForegroundColor Gray
Write-Host "  2. Auto-detect: .\scripts\sd-write.ps1 -Image img -AutoDetect" -ForegroundColor Gray
Write-Host "  3. Specific disk: .\scripts\sd-write.ps1 -Image img -Disk 2" -ForegroundColor Gray
Write-Host "  4. Watch mode: .\scripts\sd-write.ps1 -Watch -Image img" -ForegroundColor Gray
Write-Host "  5. With verify: .\scripts\sd-write.ps1 -Image img -AutoDetect -Verify" -ForegroundColor Gray
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Demo Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Features:" -ForegroundColor Yellow
Write-Host "  - PS device detection (WMI)" -ForegroundColor Green
Write-Host "  - Go high-performance writing" -ForegroundColor Green
Write-Host "  - Auto SD card identification" -ForegroundColor Green
Write-Host "  - Safety checks" -ForegroundColor Green
Write-Host ""
