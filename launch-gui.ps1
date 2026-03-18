# Launch GUI Application
# This script ensures the GUI app runs with proper Windows display context

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$GuiExe = Join-Path $ScriptPath "bin\sd-gui.exe"

Write-Host "Starting SD Card Image Writer GUI..." -ForegroundColor Cyan
Write-Host "Executable: $GuiExe" -ForegroundColor Gray

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator. Device detection may not work properly." -ForegroundColor Yellow
    Write-Host "Please right-click and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Continue anyway? (Y/N)"
    if ($response -ne 'Y' -and $response -ne 'y') {
        exit
    }
}

# Launch the GUI
Write-Host "Launching application..." -ForegroundColor Green
Start-Process -FilePath $GuiExe -NoNewWindow -Wait

Write-Host ""
Write-Host "Application closed." -ForegroundColor Cyan
