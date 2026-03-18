# GUI Diagnostic Script

Write-Host "=== SD Card Image Writer - GUI Diagnostics ===" -ForegroundColor Cyan
Write-Host ""

# Check executable
$exePath = "bin\sd-gui.exe"
Write-Host "[1/5] Checking executable..." -ForegroundColor Yellow
if (Test-Path $exePath) {
    $info = Get-Item $exePath
    Write-Host "  ✓ Found: $($info.Name)" -ForegroundColor Green
    Write-Host "    Size: $([math]::Round($info.Length / 1MB, 2)) MB"
    Write-Host "    Modified: $($info.LastWriteTime)"
} else {
    Write-Host "  ✗ Not found: $exePath" -ForegroundColor Red
    Write-Host "    Run: go build -o bin/sd-gui.exe ./cmd/gui"
    exit 1
}
Write-Host ""

# Check OpenGL
Write-Host "[2/5] Checking OpenGL support..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.Windows.Forms
    Write-Host "  ✓ Windows Forms available" -ForegroundColor Green
} catch {
    Write-Host "  ✗ .NET Framework issue" -ForegroundColor Red
}
Write-Host ""

# Check permissions
Write-Host "[3/5] Checking permissions..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "  ✓ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Not running as Administrator" -ForegroundColor Yellow
    Write-Host "    Device detection may not work properly"
}
Write-Host ""

# Check display
Write-Host "[4/5] Checking display configuration..." -ForegroundColor Yellow
try {
    $screens = [System.Windows.Forms.Screen]::AllScreens
    Write-Host "  ✓ Detected $($screens.Count) screen(s)" -ForegroundColor Green
    foreach ($i in 0..($screens.Count - 1)) {
        $s = $screens[$i]
        Write-Host "    Screen $i : $($s.Bounds.Width)x$($s.Bounds.Height)"
    }
} catch {
    Write-Host "  ⚠ Could not detect screen info" -ForegroundColor Yellow
}
Write-Host ""

# Dependencies check
Write-Host "[5/5] Checking critical DLLs..." -ForegroundColor Yellow
$dlls = @("opengl32.dll", "glu32.dll", "gdi32.dll", "user32.dll")
foreach ($dll in $dlls) {
    $path = Join-Path $env:SystemRoot "System32\$dll"
    if (Test-Path $path) {
        Write-Host "  ✓ $dll" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $dll not found" -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "=== Diagnostics Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If the GUI still doesn't appear:" -ForegroundColor Yellow
Write-Host "1. Run from PowerShell (not Git Bash or WSL)" -ForegroundColor White
Write-Host "2. Try: .\launch-gui.ps1" -ForegroundColor White
Write-Host "3. Or run directly: .\bin\sd-gui.exe" -ForegroundColor White
Write-Host ""
Write-Host "Common issues:" -ForegroundColor Yellow
Write-Host "- Running from WSL: Use Windows PowerShell instead" -ForegroundColor White
Write-Host "- Window off-screen: Try moving windows or check display settings" -ForegroundColor White
Write-Host "- OpenGL issues: Update graphics drivers" -ForegroundColor White
