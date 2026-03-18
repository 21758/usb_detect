@echo off
REM SD Card Image Writer GUI Launcher
REM 双击此文件启动 GUI 应用

echo ========================================
echo  SD Card Image Writer v2.0
echo ========================================
echo.

REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Running as Administrator
) else (
    echo [WARNING] Not running as Administrator!
    echo Device detection may not work properly.
    echo.
    echo Please right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo.
echo Starting GUI...
echo.

REM 启动 GUI 应用
start "" "%~dp0bin\sd-gui.exe"

if %errorLevel% == 0 (
    echo GUI launched successfully!
    echo.
    echo If you don't see the window:
    echo 1. Check your taskbar for the application
    echo 2. Try Alt+Tab to find the window
    echo 3. Run diagnose-gui.ps1 for diagnostics
) else (
    echo Failed to launch GUI!
    echo Error code: %errorLevel%
)

echo.
pause
