# test-go-binary.ps1
# Test the compiled Go binary

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Go Binary Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$exePath = Join-Path $PSScriptRoot "..\bin\sd-write.exe"

# Test 1: Binary exists
Write-Host "[Test 1] Binary exists..." -ForegroundColor Yellow
if (Test-Path $exePath) {
    $size = (Get-Item $exePath).Length / 1MB
    Write-Host "  PASS: Binary found ($size MB)`n" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Binary not found`n" -ForegroundColor Red
    exit 1
}

# Test 2: Help message
Write-Host "[Test 2] Display help..." -ForegroundColor Yellow
& $exePath -help 2>&1 | Select-Object -First 5
Write-Host ""

# Test 3: List devices
Write-Host "[Test 3] List devices..." -ForegroundColor Yellow
& $exePath -list
Write-Host ""

# Test 4: Validate error handling
Write-Host "[Test 4] Validate error handling..." -ForegroundColor Yellow
$result = & $exePath -image "nonexistent.img" -disk 1 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  PASS: Correctly failed with error code $LASTEXITCODE" -ForegroundColor Green
    Write-Host "  Error: $result" -ForegroundColor Gray
} else {
    Write-Host "  FAIL: Should have failed" -ForegroundColor Red
}
Write-Host ""

# Test 5: Validate missing parameters
Write-Host "[Test 5] Validate missing parameters..." -ForegroundColor Yellow
$result = & $exePath 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  PASS: Correctly failed with error code $LASTEXITCODE" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Should have failed" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Binary Tests Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
