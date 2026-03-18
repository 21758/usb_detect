# run-tests.ps1
# Complete test runner for SD detection module

$ErrorActionPreference = "Stop"

# Import module
$ModulePath = Join-Path $PSScriptRoot "..\scripts\sd-detect.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SD Detection Module Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Module import
Write-Host "[Test 1] Import module..." -ForegroundColor Yellow
try {
    . $ModulePath
    Write-Host "  PASS: Module imported`n" -ForegroundColor Green
} catch {
    Write-Host "  FAIL: Module import error: $_`n" -ForegroundColor Red
    exit 1
}

# Test 2: Check function definitions
Write-Host "[Test 2] Check functions exist..." -ForegroundColor Yellow
$functions = @('Get-PhysicalSD', 'Test-IsSDCard', 'Show-SDDeviceList')
$allExist = $true

foreach ($func in $functions) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Host "  PASS: $func exists" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: $func not found" -ForegroundColor Red
        $allExist = $false
    }
}

if (-not $allExist) {
    exit 1
}
Write-Host ""

# Test 3: Test-IsSDCard unit tests
Write-Host "[Test 3] Test-IsSDCard unit tests..." -ForegroundColor Yellow
$testCases = @(
    @{ Input = @{ Model = "SD Card Reader"; MediaType = "Removable Media"; Size = 32GB }; Expected = $true; Name = "SD Card Reader" },
    @{ Input = @{ Model = "External HDD"; MediaType = "Fixed hard disk media"; Size = 1TB }; Expected = $false; Name = "External HDD" },
    @{ Input = @{ Model = "USB Reader"; MediaType = "Removable Media"; Size = 16GB }; Expected = $true; Name = "USB Reader" },
    @{ Input = @{ Model = "Generic Storage"; MediaType = "Fixed hard disk media"; Size = 500GB }; Expected = $false; Name = "Generic Storage" },
    @{ Input = @{ Model = "Some Device"; MediaType = "Fixed hard disk media"; Size = 16GB }; Expected = $false; Name = "Small Fixed Disk" }
)

$passed = 0
$total = $testCases.Count

foreach ($test in $testCases) {
    $result = Test-IsSDCard $test.Input
    if ($result -eq $test.Expected) {
        Write-Host "  PASS: $($test.Name) => $result (expected: $($test.Expected))" -ForegroundColor Green
        $passed++
    } else {
        Write-Host "  FAIL: $($test.Name) => $result (expected: $($test.Expected))" -ForegroundColor Red
    }
}

Write-Host "  Result: $passed/$total passed`n" -ForegroundColor $(if ($passed -eq $total) { "Green" } else { "Yellow" })

# Test 4: Get-PhysicalSD execution
Write-Host "[Test 4] Get-PhysicalSD execution..." -ForegroundColor Yellow
try {
    $devices = Get-PhysicalSD -ErrorAction Stop
    Write-Host "  PASS: Get-PhysicalSD executed" -ForegroundColor Green
    Write-Host "  INFO: Found $($devices.Count) device(s)" -ForegroundColor Gray

    if ($devices.Count -gt 0) {
        Write-Host ""

        # Verify structure of first device
        $device = $devices[0]
        $requiredProps = @('DeviceID', 'DiskNumber', 'Size', 'SizeGB', 'Model', 'IsSDCard')
        $propsOK = $true

        Write-Host "  [Test 4.1] Verify device properties..." -ForegroundColor Yellow
        foreach ($prop in $requiredProps) {
            if ($device.PSObject.Properties.Name -contains $prop) {
                Write-Host "    PASS: Property '$prop' exists" -ForegroundColor Green
            } else {
                Write-Host "    FAIL: Property '$prop' missing" -ForegroundColor Red
                $propsOK = $false
            }
        }

        # Test data types
        Write-Host ""
        Write-Host "  [Test 4.2] Verify data types..." -ForegroundColor Yellow
        if ($device.DiskNumber -is [int]) {
            Write-Host "    PASS: DiskNumber is integer" -ForegroundColor Green
        } else {
            Write-Host "    FAIL: DiskNumber is not integer" -ForegroundColor Red
            $propsOK = $false
        }

        if ($device.Size -ge 0) {
            Write-Host "    PASS: Size is non-negative" -ForegroundColor Green
        } else {
            Write-Host "    FAIL: Size is negative" -ForegroundColor Red
            $propsOK = $false
        }
    }
} catch {
    Write-Host "  FAIL: Get-PhysicalSD error: $_" -ForegroundColor Red
}
Write-Host ""

# Test 5: Show-SDDeviceList execution
Write-Host "[Test 5] Show-SDDeviceList execution..." -ForegroundColor Yellow
try {
    $output = Show-SDDeviceList 6>&1
    Write-Host "  PASS: Show-SDDeviceList executed" -ForegroundColor Green
    Write-Host "  INFO: Function completed without errors" -ForegroundColor Gray
} catch {
    Write-Host "  FAIL: Show-SDDeviceList error: $_" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All Tests Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
