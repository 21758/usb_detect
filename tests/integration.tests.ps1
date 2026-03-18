# integration.tests.ps1
# Integration tests for sd-write.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Integration Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ScriptPath = Join-Path $PSScriptRoot "..\scripts\sd-write.ps1"

# Test 1: Script exists
Write-Host "[Test 1] Script exists..." -ForegroundColor Yellow
if (Test-Path $ScriptPath) {
    Write-Host "  PASS: Script found`n" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Script not found`n" -ForegroundColor Red
    exit 1
}

# Test 2: Show help
Write-Host "[Test 2] Show help..." -ForegroundColor Yellow
& $ScriptPath 2>&1 | Select-Object -First 10
Write-Host ""

# Test 3: List devices
Write-Host "[Test 3] List devices..." -ForegroundColor Yellow
& $ScriptPath -List
Write-Host ""

# Test 4: Missing image parameter
Write-Host "[Test 4] Missing image parameter..." -ForegroundColor Yellow
$result = & $ScriptPath -Disk 1 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  PASS: Correctly rejected missing image`n" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Should have rejected`n" -ForegroundColor Red
}

# Test 5: Non-existent image
Write-Host "[Test 5] Non-existent image..." -ForegroundColor Yellow
$result = & $ScriptPath -Image "nonexistent.img" -Disk 1 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  PASS: Correctly rejected non-existent file`n" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Should have rejected`n" -ForegroundColor Red
}

# Test 6: Invalid disk number
Write-Host "[Test 6] Invalid disk number..." -ForegroundColor Yellow
try {
    $result = & $ScriptPath -Image "test.img" -Disk 100 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  PASS: Correctly rejected invalid disk`n" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Should have rejected`n" -ForegroundColor Red
    }
} catch {
    Write-Host "  PASS: Parameter validation caught error`n" -ForegroundColor Green
}

# Test 7: Go executable check
Write-Host "[Test 7] Go executable check..." -ForegroundColor Yellow
$goExe = Join-Path $PSScriptRoot "..\bin\sd-write.exe"
if (Test-Path $goExe) {
    $size = [math]::Round((Get-Item $goExe).Length / 1MB, 2)
    Write-Host "  PASS: Go executable found ($size MB)`n" -ForegroundColor Green
} else {
    Write-Host "  WARN: Go executable not found (run build.ps1)`n" -ForegroundColor Yellow
}

# Test 8: Function imports
Write-Host "[Test 8] Function imports..." -ForegroundColor Yellow
. (Join-Path $PSScriptRoot "..\scripts\sd-detect.ps1")

$functions = @('Get-PhysicalSD', 'Test-IsSDCard', 'Show-SDDeviceList')
$allExist = $true

foreach ($func in $functions) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Host "  PASS: $func imported" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: $func not found" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    exit 1
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Integration Tests Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
