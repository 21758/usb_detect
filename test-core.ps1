# Test core packages (excluding GUI which requires CGO)

Write-Host "Testing core packages..." -ForegroundColor Cyan
go test ./pkg/devices ./pkg/disk ./pkg/progress -v
