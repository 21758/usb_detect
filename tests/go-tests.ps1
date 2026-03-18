# go-tests.ps1
# Run Go tests and show results

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Go Package Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Go is installed
Write-Host "[Check] Verifying Go installation..." -ForegroundColor Yellow
try {
	$goVersion = go version 2>&1
	if ($LASTEXITCODE -eq 0) {
		Write-Host "  PASS: Go is installed" -ForegroundColor Green
		Write-Host "  INFO: $goVersion" -ForegroundColor Gray
	} else {
		throw "Go not found"
	}
} catch {
	Write-Host "  FAIL: Go is not installed or not in PATH" -ForegroundColor Red
	Write-Host "  Please install Go from https://golang.org/dl/" -ForegroundColor Yellow
	exit 1
}

Write-Host ""

# Run Go tests
Write-Host "[Test] Running Go tests..." -ForegroundColor Yellow
Write-Host ""

Push-Location
try {
	Set-Location -Path $PSScriptRoot\..

	# Run tests with verbose output
	go test -v ./pkg/disk/ 2>&1

	if ($LASTEXITCODE -eq 0) {
		Write-Host ""
		Write-Host "========================================" -ForegroundColor Green
		Write-Host "All Go Tests Passed" -ForegroundColor Green
		Write-Host "========================================" -ForegroundColor Green
	} else {
		Write-Host ""
		Write-Host "========================================" -ForegroundColor Red
		Write-Host "Some Tests Failed (Expected in RED phase)" -ForegroundColor Red
		Write-Host "========================================" -ForegroundColor Red
	}
} finally {
	Pop-Location
}
