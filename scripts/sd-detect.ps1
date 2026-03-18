# sd-detect.ps1
# SD Card Device Detection Module
# Version: 1.0

#region Constants

$script:MAX_SD_CARD_SIZE_GB = 128
$script:MIN_SD_INDICATORS = 2
$script:SD_KEYWORDS = @('SD', 'Card', 'Reader', 'MMC')

#endregion

#region Private Helper Functions

<#
.SYNOPSIS
    Get volume information for a disk
.PARAMETER DiskIndex
    The disk index to query
.OUTPUTS
    Volume information object or null
#>
function Get-DiskVolumeInfo {
    param(
        [Parameter(Mandatory = $true)]
        [int]$DiskIndex
    )

    $partitions = Get-WmiObject Win32_DiskPartition |
                  Where-Object { $_.DiskIndex -eq $DiskIndex }

    if (-not $partitions) {
        return $null
    }

    $logicalDisks = $partitions | ForEach-Object {
        Get-WmiObject Win32_LogicalDisk |
        Where-Object { $_.VolumeSerialNumber -eq $_.VolumeSerialNumber }
    }

    return $logicalDisks | Select-Object -First 1
}

<#
.SYNOPSIS
    Format size in bytes to human readable string
.PARAMETER SizeBytes
    Size in bytes
.OUTPUTS
    Formatted string (e.g., "32.0 GB")
#>
function Format-FileSize {
    param([long]$SizeBytes)

    $sizeInGB = [math]::Round($SizeBytes / 1GB, 1)
    return "$sizeInGB GB"
}

<#
.SYNOPSIS
    Check if a string matches SD card keywords
.PARAMETER Text
    Text to check
.OUTPUTS
    Boolean indicating if text matches SD keywords
#>
function Test-SDKeyword {
    param([string]$Text)

    if ([string]::IsNullOrEmpty($Text)) {
        return $false
    }

    foreach ($keyword in $script:SD_KEYWORDS) {
        if ($Text -match $keyword) {
            return $true
        }
    }

    return $false
}

#endregion

#region Public Functions

<#
.SYNOPSIS
    Test if a disk is an SD card
.PARAMETER Disk
    Disk object with Model, MediaType, and Size properties
.OUTPUTS
    Boolean indicating if the disk is an SD card
.EXAMPLE
    Test-IsSDCard @{ Model = "SD Card"; MediaType = "Removable"; Size = 32GB }
#>
function Test-IsSDCard {
    param(
        [Parameter(Mandatory = $true)]
        $Disk
    )

    # Check for SD card indicators
    $indicators = @(
        (Test-SDKeyword $Disk.Model),
        ($Disk.MediaType -match "Removable"),
        ($Disk.Size -lt ($script:MAX_SD_CARD_SIZE_GB * 1GB))
    )

    # Need at least MIN_SD_INDICATORS to be considered an SD card
    return ($indicators.Where({ $_ }).Count -ge $script:MIN_SD_INDICATORS)
}

<#
.SYNOPSIS
    Get all removable SD card devices
.OUTPUTS
    Array of PSCustomObject representing SD cards
.EXAMPLE
    Get-PhysicalSD
.EXAMPLE
    Get-PhysicalSD | Where-Object { $_.IsSDCard }
#>
function Get-PhysicalSD {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param()

    # Get all removable disks using WMI
    $disks = Get-WmiObject Win32_DiskDrive |
             Where-Object {
                 $_.MediaType -like "*Removable*" -or
                 $_.MediaType -like "*SD*" -or
                 $_.Size -lt ($script:MAX_SD_CARD_SIZE_GB * 1GB)
             }

    $results = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($disk in $disks) {
        $volumeInfo = Get-DiskVolumeInfo -DiskIndex $disk.Index

        $device = [PSCustomObject]@{
            DeviceID    = $disk.Index
            DiskNumber  = $disk.Index
            Size        = [math]::Round($disk.Size / 1GB, 2)
            SizeGB      = Format-FileSize -SizeBytes $disk.Size
            Model       = $disk.Model
            MediaType   = $disk.MediaType
            DriveLetter = $volumeInfo?.DeviceID
            VolumeName  = $volumeInfo?.VolumeName
            FileSystem  = $volumeInfo?.FileSystem
            IsSDCard    = Test-IsSDCard $disk
        }

        $results.Add($device)
    }

    return $results.ToArray()
}

<#
.SYNOPSIS
    Display a formatted list of SD card devices
.OUTPUTS
    Array of device objects
.EXAMPLE
    Show-SDDeviceList
#>
function Show-SDDeviceList {
    [OutputType([PSCustomObject[]])]
    param()

    $devices = Get-PhysicalSD

    if ($devices.Count -eq 0) {
        Write-Warning "No SD card devices detected"
        return $devices
    }

    Write-Host "`nDetected removable devices:`n" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Gray

    for ($i = 0; $i -lt $devices.Count; $i++) {
        $dev = $devices[$i]

        Write-Host "`n[$($i + 1)] PhysicalDrive$($dev.DiskNumber) - $($dev.SizeGB)" `
                  -ForegroundColor Yellow

        if ($dev.DriveLetter) {
            Write-Host "    Drive: $($dev.DriveLetter)" -ForegroundColor White
        }

        if ($dev.VolumeName) {
            Write-Host "    Label: $($dev.VolumeName)" -ForegroundColor White
        }

        Write-Host "    Model: $($dev.Model)" -ForegroundColor White

        if ($dev.FileSystem) {
            Write-Host "    File System: $($dev.FileSystem)" -ForegroundColor White
        }

        if ($dev.IsSDCard) {
            Write-Host "    Type: SD Card" -ForegroundColor Green
        }

        Write-Host ("    " + ("-" * 50))
    }

    Write-Host ""

    return $devices
}

#endregion

# Note: This is a script file, functions are available after dot-sourcing
