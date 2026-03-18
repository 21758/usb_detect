# build.ps1
# Build script for Go binary

param(
    [ValidateSet("windows", "linux", "darwin", "all")]
    [string]$Platform = "windows"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SD-Detect Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Clean bin directory
Write-Host "[Step 1] Cleaning bin directory..." -ForegroundColor Yellow
if (Test-Path .\bin) {
    Remove-Item -Path .\bin -Recurse -Force
}
New-Item -Path .\bin -ItemType Directory | Out-Null
Write-Host "  OK: Bin directory cleaned`n" -ForegroundColor Green

# Build for specified platform
function Build-Go {
    param($GOOS, $GOARCH, $Output)

    $env:GOOS = $GOOS
    $env:GOARCH = $GOARCH
    $env:CGO_ENABLED = "0"

    Write-Host "Building for $GOOS-$GOARCH..." -ForegroundColor Cyan

    go build -ldflags "-s -w" -o $Output ./cmd/sd-write/

    if ($LASTEXITCODE -eq 0) {
        $size = (Get-Item $Output).Length / 1MB
        Write-Host "  OK: Built $Output ($size MB)`n" -ForegroundColor Green
    } else {
        throw "Build failed for $GOOS-$GOARCH"
    }
}

# Run tests first
Write-Host "[Step 2] Running tests..." -ForegroundColor Yellow
go test -v ./pkg/disk/ ./pkg/progress/ 2>&1 | Select-Object -Last 5

if ($LASTEXITCODE -ne 0) {
    Write-Host "  FAIL: Tests failed" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: All tests passed`n" -ForegroundColor Green

# Build based on platform
Write-Host "[Step 3] Building binaries..." -ForegroundColor Yellow
Write-Host ""

switch ($Platform) {
    "windows" {
        Build-Go "windows" "amd64" ".\bin\sd-write.exe"
    }
    "linux" {
        Build-Go "linux" "amd64" ".\bin\sd-write"
    }
    "darwin" {
        Build-Go "darwin" "amd64" ".\bin\sd-write-mac"
    }
    "all" {
        Build-Go "windows" "amd64" ".\bin\sd-write.exe"
        Build-Go "linux" "amd64" ".\bin\sd-write"
        Build-Go "darwin" "amd64" ".\bin\sd-write-mac"
    }
}

# Copy scripts
Write-Host "[Step 4] Copying scripts..." -ForegroundColor Yellow
Copy-Item -Path ".\scripts\sd-detect.ps1" -Destination ".\bin\" -Force
Write-Host "  OK: Scripts copied`n" -ForegroundColor Green

# Display summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Get-ChildItem -Path .\bin | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  $($_.Name) ($size MB)" -ForegroundColor White
}

Write-Host ""
Write-Host "Output directory: .\bin" -ForegroundColor Gray
