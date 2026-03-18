# final-verification.ps1
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Final Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Check] File structure..." -ForegroundColor Yellow

$files = @(
    "scripts\sd-detect.ps1",
    "scripts\sd-write.ps1",
    "scripts\build.ps1",
    "bin\sd-write.exe",
    "tests\integration.tests.ps1",
    "examples\complete-workflow.ps1"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        Write-Host "  OK: $f" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: $f" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[Check] Script functionality..." -ForegroundColor Yellow
& .\scripts\sd-write.ps1 -List

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verification Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
