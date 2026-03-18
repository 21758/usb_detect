# sd-write.ps1
# SD Card Image Writer - Main Entry Point
# Integrates PowerShell device detection with Go image writer

param(
    [Parameter(Mandatory = $false)]
    [string]$Image,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 99)]
    [int]$Disk,

    [Parameter(Mandatory = $false)]
    [switch]$AutoDetect,

    [Parameter(Mandatory = $false)]
    [switch]$List,

    [Parameter(Mandatory = $false)]
    [switch]$Watch,

    [Parameter(Mandatory = $false)]
    [ValidateSet(512KB, 1MB, 4MB, 8MB)]
    [int]$BlockSize = 1MB,

    [Parameter(Mandatory = $false)]
    [switch]$Verify,

    [Parameter(Mandatory = $false)]
    [switch]$Force,

    [Parameter(Mandatory = $false)]
    [switch]$AsJson
)

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$GoExe = Join-Path $ScriptDir "..\bin\sd-write.exe"
$DetectScript = Join-Path $ScriptDir "sd-detect.ps1"

# Import detection module
. $DetectScript

function Write-UserError {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Write-UserWarning {
    param([string]$Message)
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
}

function Write-UserSuccess {
    param([string]$Message)
    Write-Host "SUCCESS: $Message" -ForegroundColor Green
}

function Show-Help {
    Write-Host @"
SD Card Image Writer v2.0
========================

USAGE:
    .\sd-write.ps1 -Image <path> -Disk <number> [options]
    .\sd-write.ps1 -List
    .\sd-write.ps1 -Watch -Image <path>

OPTIONS:
    -Image <path>      Path to image file (.img)
    -Disk <number>     Target disk number (0-99)
    -AutoDetect        Automatically detect SD card
    -List              List available SD cards
    -Watch             Watch for SD card insertion
    -BlockSize <size>  Write block size (512KB, 1MB, 4MB, 8MB)
    -Verify            Verify write after completion
    -Force             Skip confirmation prompt

EXAMPLES:
    # List SD cards
    .\sd-write.ps1 -List

    # Auto-detect and write
    .\sd-write.ps1 -Image .\raspios.img -AutoDetect

    # Write to specific disk
    .\sd-write.ps1 -Image .\openwrt.img -Disk 2

    # Watch mode
    .\sd-write.ps1 -Watch -Image .\backup.img

    # With verification
    .\sd-write.ps1 -Image .\image.img -AutoDetect -Verify
"@ -ForegroundColor Cyan
}

function Invoke-Confirmation {
    param(
        [string]$ImagePath,
        [PSCustomObject]$TargetDisk
    )

    $imageFile = Get-Item $ImagePath
    $imageSize = [math]::Round($imageFile.Length / 1GB, 2)

    Write-Host "`n" + ("=" * 60) -ForegroundColor Red
    Write-Host "⚠️  WARNING: About to write image to disk" -ForegroundColor Red
    Write-Host ("=" * 60) + "`n" -ForegroundColor Red

    Write-Host "Target Disk:" -ForegroundColor Yellow
    Write-Host "  Physical Drive: PhysicalDrive$($TargetDisk.DiskNumber)" -ForegroundColor White
    Write-Host "  Size: $($TargetDisk.SizeGB)" -ForegroundColor White
    if ($TargetDisk.DriveLetter) {
        Write-Host "  Current Drive: $($TargetDisk.DriveLetter)" -ForegroundColor White
    }
    if ($TargetDisk.VolumeName) {
        Write-Host "  Volume Label: $($TargetDisk.VolumeName)" -ForegroundColor White
    }

    Write-Host "`nImage File:" -ForegroundColor Yellow
    Write-Host "  Path: $ImagePath" -ForegroundColor White
    Write-Host "  Size: $imageSize GB`n" -ForegroundColor White

    Write-Host "This will ERASE ALL DATA on the target disk!" -ForegroundColor Red
    Write-Host "This operation CANNOT be undone!`n" -ForegroundColor Red

    $confirmation = Read-Host "Type 'YES' to confirm"

    if ($confirmation -ne 'YES') {
        Write-Host "`nOperation cancelled" -ForegroundColor Yellow
        return $false
    }

    return $true
}

function Test-Administrator {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )

    $isAdmin = $currentPrincipal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    return $isAdmin
}

function Invoke-ImageWrite {
    param(
        [string]$ImagePath,
        [int]$DiskNumber,
        [int]$BlockSize,
        [switch]$Verify
    )

    if (-not (Test-Administrator)) {
        Write-UserError "Administrator privileges required"
        Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
        return $false
    }

    if (-not (Test-Path $GoExe)) {
        Write-UserError "Go executable not found: $GoExe"
        Write-Host "Please run .\scripts\build.ps1 to build the executable" -ForegroundColor Yellow
        return $false
    }

    $args = @("-image", $ImagePath, "-disk", $DiskNumber, "-bs", $BlockSize)
    if ($Verify) {
        $args += "-verify"
    }

    Write-Host "`nStarting image write..." -ForegroundColor Cyan
    Write-Host "Command: $GoExe $($args -join ' ')`n" -ForegroundColor Gray

    $process = Start-Process -FilePath $GoExe -ArgumentList $args -NoNewWindow -Wait -PassThru

    return $process.ExitCode -eq 0
}

# Main logic
try {
    # Show help if no parameters
    if ($PSBoundParameters.Count -eq 0) {
        Show-Help
        exit 0
    }

    # Output as JSON (for Go integration)
    if ($AsJson) {
        $devices = Get-PhysicalSD
        if ($null -eq $devices -or $devices.Count -eq 0) {
            Write-Output "[]"
        } else {
            # Convert to JSON and wrap in array if needed
            $json = $devices | ConvertTo-Json -Depth 3
            if ($json -notmatch '^\s*\[') {
                # Single object, wrap in array
                Write-Output "[$json]"
            } else {
                Write-Output $json
            }
        }
        exit 0
    }

    # List devices
    if ($List) {
        Show-SDDeviceList
        exit 0
    }

    # Watch mode
    if ($Watch) {
        if (-not $Image) {
            Write-UserError "Watch mode requires -Image parameter"
            exit 1
        }

        Write-Host "Watching for SD card insertion..." -ForegroundColor Cyan
        Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Gray

        Watch-SDCardInsert -Callback {
            param($drive)
            Write-Host "`n[Callback] Device inserted: $drive" -ForegroundColor Green
            Write-Host "Starting write process...`n" -ForegroundColor Cyan

            # Auto-detect and write
            $devices = Get-PhysicalSD | Where-Object { $_.IsSDCard }
            if ($devices.Count -eq 0) {
                Write-UserWarning "No SD card detected"
                return
            }

            $diskNumber = $devices[0].DiskNumber

            if (-not $Force) {
                if (-not (Invoke-Confirmation -Image $Image -TargetDisk $devices[0])) {
                    return
                }
            }

            Invoke-ImageWrite -Image $Image -DiskNumber $diskNumber -BlockSize $BlockSize -Verify:$Verify
        }

        exit 0
    }

    # Validate image file
    if (-not $Image) {
        Write-UserError "-Image parameter is required"
        exit 1
    }

    if (-not (Test-Path $Image)) {
        Write-UserError "Image file not found: $Image"
        exit 1
    }

    # Auto-detect SD card
    if ($AutoDetect) {
        $devices = Get-PhysicalSD | Where-Object { $_.IsSDCard }

        if ($devices.Count -eq 0) {
            Write-UserWarning "No SD card detected"
            Write-Host "Please insert an SD card and try again" -ForegroundColor Yellow
            exit 1
        }

        if ($devices.Count -gt 1) {
            Write-Host "`nMultiple SD cards detected:" -ForegroundColor Yellow
            Show-SDDeviceList

            $selection = Read-Host "`nSelect device (1-$($devices.Count))"
            $Disk = $devices[$selection - 1].DiskNumber
        } else {
            $Disk = $devices[0].DiskNumber
            Write-Host "`nAuto-detected SD card: PhysicalDrive$Disk" -ForegroundColor Green
        }
    }

    # Validate disk number
    if ($Disk -eq 0) {
        Write-UserError "-Disk parameter or -AutoDetect is required"
        exit 1
    }

    # Get device info
    $devices = Get-PhysicalSD
    $targetDisk = $devices | Where-Object { $_.DiskNumber -eq $Disk }

    if (-not $targetDisk) {
        Write-UserError "Disk not found: PhysicalDrive$Disk"
        Write-Host "Run -List to see available devices" -ForegroundColor Yellow
        exit 1
    }

    # Safety check: system disk
    $systemDrive = (Get-WmiObject Win32_OperatingSystem).SystemDrive
    $systemDisk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$systemDrive'"

    # Basic check - if disk matches system drive, warn
    if ($targetDisk.DriveLetter -eq $systemDisk.DeviceID) {
        Write-UserError "Cannot write to system disk!"
        Write-Host "Target disk is the system drive: $systemDrive" -ForegroundColor Red
        exit 1
    }

    # User confirmation
    if (-not $Force) {
        if (-not (Invoke-Confirmation -Image $Image -TargetDisk $targetDisk)) {
            exit 0
        }
    }

    # Perform write
    $success = Invoke-ImageWrite -Image $Image -DiskNumber $Disk -BlockSize $BlockSize -Verify:$Verify

    if ($success) {
        Write-UserSuccess "Image write completed successfully!"
        exit 0
    } else {
        Write-UserError "Image write failed"
        exit 1
    }

} catch {
    Write-UserError "Unexpected error: $_"
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
