# USB Detection Diagnostic Script

Write-Host "=== USB Device Detection Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

# Check administrator privileges
Write-Host "[1/5] Checking administrator privileges..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "  ✓ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "  ✗ NOT running as Administrator!" -ForegroundColor Red
    Write-Host "    Please right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Continuing anyway, but device detection may not work..." -ForegroundColor Yellow
}
Write-Host ""

# Check PowerShell script
Write-Host "[2/5] Checking sd-detect.ps1 script..." -ForegroundColor Yellow
$scriptPath = "scripts\sd-detect.ps1"
if (Test-Path $scriptPath) {
    Write-Host "  ✓ Found: $scriptPath" -ForegroundColor Green
} else {
    Write-Host "  ✗ NOT found: $scriptPath" -ForegroundColor Red
    Write-Host "    Please ensure the script exists" -ForegroundColor Yellow
}
Write-Host ""

# Check execution policy
Write-Host "[3/5] Checking PowerShell execution policy..." -ForegroundColor Yellow
$policy = Get-ExecutionPolicy
Write-Host "  Current policy: $policy" -ForegroundColor Cyan
if ($policy -eq "Restricted" -or $policy -eq "Undefined") {
    Write-Host "  ⚠ Policy may prevent script execution" -ForegroundColor Yellow
    Write-Host "    Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor White
} else {
    Write-Host "  ✓ Execution policy allows scripts" -ForegroundColor Green
}
Write-Host ""

# List USB devices using WMI
Write-Host "[4/5] Detecting USB/Removable devices..." -ForegroundColor Yellow
try {
    $disks = Get-WmiObject Win32_DiskDrive | Where-Object { $_.MediaType -eq "Removable Media" -or $_.InterfaceType -eq "USB" }
    if ($disks) {
        Write-Host "  ✓ Found removable devices:" -ForegroundColor Green
        foreach ($disk in $disks) {
            $sizeGB = [math]::Round($disk.Size / 1GB, 2)
            Write-Host "    - Drive: $($disk.Index)" -ForegroundColor Cyan
            Write-Host "      Model: $($disk.Model)" -ForegroundColor White
            Write-Host "      Size: $sizeGB GB" -ForegroundColor White
            Write-Host "      Type: $($disk.MediaType)" -ForegroundColor Gray
            Write-Host ""
        }
    } else {
        Write-Host "  ✗ No removable devices found" -ForegroundColor Yellow
        Write-Host "    Please insert a USB drive or SD card" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Error detecting devices: $_" -ForegroundColor Red
}
Write-Host ""

# Test sd-detect.ps1 directly
Write-Host "[5/5] Testing sd-detect.ps1 script..." -ForegroundColor Yellow
if (Test-Path $scriptPath) {
    Write-Host "  Running: $scriptPath -AsJson" -ForegroundColor Gray
    try {
        $output = & $scriptPath -AsJson 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Script executed successfully" -ForegroundColor Green
            Write-Host "  Output:" -ForegroundColor Gray
            Write-Host $output
        } else {
            Write-Host "  ✗ Script failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "  Error output:" -ForegroundColor Gray
            Write-Host $output
        }
    } catch {
        Write-Host "  ✗ Error running script: $_" -ForegroundColor Red
    }
} else {
    Write-Host "  ⊘ Skipping (script not found)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "=== Diagnostic Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. If not running as Administrator, restart with elevated privileges" -ForegroundColor White
Write-Host "2. Insert a USB drive or SD card" -ForegroundColor White
Write-Host "3. Try running the GUI again: .\bin\sd-gui.exe" -ForegroundColor White
Write-Host "4. Or use the CLI: .\scripts\sd-write.ps1 -List" -ForegroundColor White
