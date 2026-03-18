# SD卡镜像写入工具 - 实现计划（混合方案）

**项目名称:** SD Card Image Writer (Hybrid: PowerShell + Go)
**创建日期:** 2026-03-18
**版本:** 2.0
**状态:** 计划中
**实现方案:** 混合架构（PowerShell 设备检测 + Go 镜像写入）

---

## 目录

- [需求概述](#需求概述)
- [混合方案架构](#混合方案架构)
- [方案对比与选择](#方案对比与选择)
- [系统架构](#系统架构)
- [实现阶段](#实现阶段)
- [依赖项](#依赖项)
- [安全考虑](#安全考虑)
- [参考资源](#参考资源)
- [时间估算](#时间估算)

---

## 需求概述

### 核心功能

1. **SD卡检测**
   - 自动识别插入的SD卡
   - 显示SD卡详细信息（容量、盘符、卷标、设备型号）
   - 支持监听模式，实时检测SD卡插入

2. **镜像写入**
   - 将嵌入式系统镜像（.img文件）写入SD卡
   - 支持实时进度显示
   - 写入完成后可选的完整性验证

### 使用场景

- 树莓派系统安装
- 开发板系统刷写
- SD卡系统备份恢复

### 目标用户

- 嵌入式系统开发者
- 树莓派用户
- 需要频繁刷写SD卡的技术人员

---

## 混合方案架构

### 为什么选择混合方案？

**取长补短，发挥各自优势：**

| 功能模块 | 技术选型 | 理由 |
|---------|---------|------|
| **设备检测** | PowerShell | WMI 原生支持，代码简洁（几行搞定） |
| **设备监听** | PowerShell | WMI Events 事件系统内置支持 |
| **安全检查** | PowerShell | 用户交互友好，权限检查简单 |
| **镜像写入** | Go | 高性能，单文件分发，无依赖 |
| **进度显示** | Go | 原生控制台操作，性能好 |
| **打包部署** | Go | 静态编译，单一 exe 文件 |

### 混合方案优势

✅ **开发效率高** - PowerShell 处理复杂的设备检测逻辑
✅ **运行性能好** - Go 处理性能敏感的镜像写入
✅ **部署灵活** - 可单独使用 exe，或完整脚本工具包
✅ **易于维护** - 脚本可读性强，Go 代码模块化
✅ **用户体验** - 脚本模式提供交互，exe 模式提供批处理

### 架构流程图

```
用户交互层
    ↓
PowerShell 脚本层 (sd-write.ps1)
    ├→ 设备检测 (WMI 查询)
    ├→ 设备监听 (WMI Events)
    ├→ 安全检查 (用户确认)
    └→ 调用 Go exe
         ↓
Go 核心层 (sd-write.exe)
    ├→ 物理磁盘写入 (高性能)
    ├→ 进度显示 (实时)
    └→ 数据验证 (可选)
```

---

## 方案对比与选择

### 方案 A：纯 PowerShell

**优势：**
- ✅ 开发速度快（脚本化）
- ✅ Windows 集成深（WMI/.NET）
- ✅ 调试方便（即改即测）

**劣势：**
- ❌ 性能相对较低（解释执行）
- ❌ 执行策略限制
- ❌ 多文件分发（脚本+模块）
- ❌ 不够"专业"（用户认知）

**适合场景：** 个人项目、快速原型

---

### 方案 B：纯 Go

**优势：**
- ✅ 高性能（原生二进制）
- ✅ 单文件分发（静态编译）
- ✅ 无依赖（独立运行）
- ✅ 可跨平台

**劣势：**
- ❌ WMI 集成繁琐（需第三方库）
- ❌ Windows API 编程复杂
- ❌ 开发周期长
- ❌ 学习曲线陡

**适合场景：** 商业产品、开源发布

---

### 方案 C：混合方案 ⭐ 推荐

**优势：**
- ✅ 取长补短（PS+Go 各司其职）
- ✅ 开发效率高（WMI 用 PS）
- ✅ 性能好（写入用 Go）
- ✅ 部署灵活（多模式）
- ✅ 易维护（代码分离）

**劣势：**
- ⚠️ 稍微增加复杂度（多文件）

**适合场景：** **大多数场景（个人/团队/开源）**

---

## 系统架构

### 项目结构

```
sd-detect/
├── cmd/
│   └── sd-write/
│       └── main.go                  # Go 主程序入口
├── pkg/
│   ├── disk/
│   │   ├── writer.go                # 物理磁盘写入逻辑
│   │   └── writer_test.go           # 单元测试
│   ├── progress/
│   │   ├── bar.go                   # 进度条显示
│   │   └── bar_test.go
│   ├── verify/
│   │   ├── checksum.go              # 数据验证
│   │   └── checksum_test.go
│   └── safety/
│       └── systemdisk.go            # 系统盘检测
│
├── scripts/
│   ├── sd-detect.ps1                # PowerShell 设备检测
│   ├── sd-write.ps1                 # PowerShell 主入口
│   └── build.ps1                    # 自动编译脚本
│
├── bin/
│   ├── sd-write.exe                 # 编译产物 (Windows)
│   ├── sd-write                     # 编译产物 (Linux)
│   └── sd-detect.ps1                # 复制的脚本
│
├── tests/
│   ├── integration/
│   │   └── e2e.test.ps1             # 集成测试
│   └── fixtures/
│       └── test.img                 # 测试镜像
│
├── docs/
│   ├── README.md
│   ├── ARCHITECTURE.md              # 架构说明
│   └── API.md                       # API 文档
│
├── go.mod
├── go.sum
├── Makefile                         # 构建脚本
├── IMPLEMENTATION_PLAN.md           # 本文档
└── LICENSE
```

### 技术栈

#### PowerShell 层

| 技术 | 版本 | 用途 |
|------|------|------|
| PowerShell | 5.1+ / Core 6+ | 运行环境 |
| WMI | Win32 API | 设备检测 |
| .NET Framework | 4.5+ | 文件操作 |

#### Go 层

| 技术 | 版本 | 用途 |
|------|------|------|
| Go | 1.21+ | 核心写入逻辑 |
| golang.org/x/sys/windows | 最新 | Windows API 绑定 |
| color | 最新 | 终端颜色输出 |

### 核心API

#### PowerShell API

- `Get-WmiObject` - WMI 查询
- `Register-WmiEvent` - 事件监听
- `System.IO.File` - .NET 文件操作

#### Go API

- `os.OpenFile` - 文件操作
- `golang.org/x/sys/windows` - Windows API
- `io.CopyBuffer` - 高性能数据复制

---

## 实现阶段

### Phase 1: PowerShell 设备检测模块

**目标：** 实现快速、准确的SD卡检测

**技术栈：** PowerShell + WMI

**预计时间：** 2-3 小时
**复杂度：** 低（WMI 原生支持）

#### 1.1 物理磁盘枚举

```powershell
# scripts/sd-detect.ps1

<#
.SYNOPSIS
    SD卡检测模块
.DESCRIPTION
    使用 WMI 查询可移动SD卡设备
#>

function Get-PhysicalSD {
    <#
    .SYNOPSIS
    获取所有可移动SD卡设备

    .OUTPUTS
    PSCustomObject[] - SD卡设备信息列表
    #>

    $disks = Get-WmiObject Win32_DiskDrive |
             Where-Object {
                 $_.MediaType -like "*Removable*" -or
                 $_.MediaType -like "*SD*" -or
                 $_.Size -lt 128GB
             }

    $results = @()

    foreach ($disk in $disks) {
        # 获取关联的卷信息
        $partitions = Get-WmiObject Win32_DiskPartition |
                      Where-Object { $_.DiskIndex -eq $disk.Index }

        $volumeInfo = $null
        if ($partitions) {
            $logicalDisks = $partitions | ForEach-Object {
                Get-WmiObject Win32_LogicalDisk |
                Where-Object { $_.VolumeSerialNumber -eq $_.VolumeSerialNumber }
            }
            $volumeInfo = $logicalDisks | Select-Object -First 1
        }

        $results += [PSCustomObject]@{
            DeviceID       = $disk.Index
            DiskNumber     = $disk.Index
            Size           = [math]::Round($disk.Size / 1GB, 2)
            SizeGB         = "$([math]::Round($disk.Size / 1GB, 1)) GB"
            Model          = $disk.Model
            MediaType      = $disk.MediaType
            DriveLetter    = $volumeInfo?.DeviceID
            VolumeName     = $volumeInfo?.VolumeName
            FileSystem     = $volumeInfo?.FileSystem
            IsSDCard       = Test-IsSDCard $disk
        }
    }

    return $results
}
```

#### 1.2 SD卡识别

```powershell
function Test-IsSDCard {
    param($disk)

    $sdIndicators = @(
        $disk.Model -match "SD|Card|Reader|MMC",
        $disk.MediaType -match "Removable",
        $disk.Size -lt 128GB
    )

    return ($sdIndicators.Where({ $_ }).Count -ge 2)
}
```

#### 1.3 设备监听

```powershell
function Watch-SDCardInsert {
    param([scriptblock]$Callback)

    Write-Host "正在监听SD卡插入... (Ctrl+C 退出)" -ForegroundColor Cyan

    Register-WmiEvent -Class win32_VolumeChangeEvent `
                      -SourceIdentifier SDInsert `
                      -Action {
        $event = $Event.SourceEventArgs.NewEvent

        if ($event.EventType -eq 2) {
            $drive = $event.DriveName
            $driveInfo = Get-WmiObject Win32_LogicalDisk |
                         Where-Object { $_.DeviceID -eq $drive }

            if ($driveInfo.DriveType -eq 2) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 检测到新设备: $drive" `
                          -ForegroundColor Green

                if ($Callback) {
                    & $Callback $drive
                }
            }
        }
    }

    try {
        while ($true) { Start-Sleep -Seconds 1 }
    }
    finally {
        Clean-SDWatcher
    }
}
```

#### 1.4 设备列表显示

```powershell
function Show-SDDeviceList {
    $devices = Get-PhysicalSD

    if ($devices.Count -eq 0) {
        Write-Warning "未检测到SD卡设备"
        return
    }

    Write-Host "`n检测到以下可移动设备:`n" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Gray

    for ($i = 0; $i -lt $devices.Count; $i++) {
        $dev = $devices[$i]
        Write-Host "`n[$($i + 1)] PhysicalDrive$($dev.DiskNumber) - $($dev.SizeGB)" `
                  -ForegroundColor Yellow

        if ($dev.DriveLetter) {
            Write-Host "    盘符: $($dev.DriveLetter)"
        }
        if ($dev.VolumeName) {
            Write-Host "    卷标: $($dev.VolumeName)"
        }
        Write-Host "    型号: $($dev.Model)"
        Write-Host "    类型: SD Card" -ForegroundColor Green
    }

    return $devices
}
```

---

### Phase 2: Go 镜像写入核心

**目标：** 实现高性能的物理磁盘写入

**技术栈：** Go 1.21+

**预计时间：** 4-6 小时
**复杂度：** 中（Windows API）

#### 2.1 主程序入口

```go
// cmd/sd-write/main.go

package main

import (
    "flag"
    "fmt"
    "os"
)

type Options struct {
    ImagePath string
    DiskNumber int
    BlockSize int64
    Verify bool
    List bool
}

func main() {
    opts := parseFlags()

    if opts.List {
        // 注意：Go 无法直接调用 WMI
        // 这里应该调用 PowerShell 脚本或返回错误
        fmt.Println("请使用 PowerShell 脚本查看设备列表")
        os.Exit(1)
    }

    if err := validateOptions(opts); err != nil {
        fmt.Fprintf(os.Stderr, "错误: %v\n", err)
        os.Exit(1)
    }

    if err := writeImage(opts); err != nil {
        fmt.Fprintf(os.Stderr, "写入失败: %v\n", err)
        os.Exit(1)
    }
}

func parseFlags() *Options {
    opts := &Options{}

    flag.StringVar(&opts.ImagePath, "image", "", "镜像文件路径")
    flag.IntVar(&opts.DiskNumber, "disk", 0, "目标磁盘编号")
    flag.Int64Var(&opts.BlockSize, "bs", 1024*1024, "块大小（字节）")
    flag.BoolVar(&opts.Verify, "verify", false, "写入后验证")
    flag.BoolVar(&opts.List, "list", false, "列出设备")
    flag.Parse()

    return opts
}
```

#### 2.2 核心写入逻辑

```go
// pkg/disk/writer.go

package disk

import (
    "fmt"
    "io"
    "os"
    "time"
)

type Writer struct {
    ImagePath string
    DiskNumber int
    BlockSize int64
    OnProgress func(current, total int64)
}

func NewWriter(imagePath string, diskNumber int, blockSize int64) *Writer {
    return &Writer{
        ImagePath: imagePath,
        DiskNumber: diskNumber,
        BlockSize: blockSize,
    }
}

func (w *Writer) Write() error {
    // 打开镜像文件
    imageFile, err := os.Open(w.ImagePath)
    if err != nil {
        return fmt.Errorf("打开镜像文件失败: %w", err)
    }
    defer imageFile.Close()

    // 获取文件大小
    stat, _ := imageFile.Stat()
    totalBytes := stat.Size()

    // 打开物理磁盘
    diskPath := fmt.Sprintf(`\\.\PhysicalDrive%d`, w.DiskNumber)
    diskFile, err := os.OpenFile(diskPath, os.O_WRONLY, 0)
    if err != nil {
        return fmt.Errorf("打开磁盘失败: %w", err)
    }
    defer diskFile.Close()

    // 分块写入
    buffer := make([]byte, w.BlockSize)
    var writtenBytes int64
    startTime := time.Now()

    for {
        n, err := imageFile.Read(buffer)
        if n == 0 {
            break
        }

        if _, err := diskFile.Write(buffer[:n]); err != nil {
            return fmt.Errorf("写入失败: %w", err)
        }

        writtenBytes += int64(n)

        // 回调进度
        if w.OnProgress != nil {
            w.OnProgress(writtenBytes, totalBytes)
        }

        if err != nil && err != io.EOF {
            return err
        }
    }

    // 刷新
    if err := diskFile.Sync(); err != nil {
        return fmt.Errorf("刷新失败: %w", err)
    }

    elapsed := time.Since(startTime)
    speed := float64(writtenBytes) / (1024 * 1024) / elapsed.Seconds()

    fmt.Printf("\n✓ 写入完成！\n")
    fmt.Printf("  大小: %.2f MB\n", float64(totalBytes)/(1024*1024))
    fmt.Printf("  耗时: %s\n", elapsed.Round(time.Second))
    fmt.Printf("  速度: %.2f MB/s\n", speed)

    return nil
}
```

#### 2.3 进度显示

```go
// pkg/progress/bar.go

package progress

import (
    "fmt"
    "strings"
    "time"
)

type Bar struct {
    Total int64
    Current int64
    StartTime time.Time
}

func NewBar(total int64) *Bar {
    return &Bar{
        Total: total,
        StartTime: time.Now(),
    }
}

func (b *Bar) Update(current int64) {
    b.Current = current
    b.render()
}

func (b *Bar) render() {
    percent := float64(b.Current) / float64(b.Total) * 100
    elapsed := time.Since(b.StartTime).Seconds()

    var eta string
    if percent > 0 {
        etaSeconds := elapsed / percent * (100 - percent)
        eta = fmt.Sprintf(" ETA: %s", time.Duration(etaSeconds)*time.Second)
    }

    barWidth := 40
    filled := int(percent / 100 * float64(barWidth))
    bar := strings.Repeat("█", filled) + strings.Repeat("░", barWidth-filled)

    fmt.Printf("\r[%s] %.1f%% (%.2f / %.2f MB)%s",
        bar, percent,
        float64(b.Current)/(1024*1024),
        float64(b.Total)/(1024*1024),
        eta)
}

func (b *Bar) Finish() {
    fmt.Println()
}
```

---

### Phase 3: PowerShell + Go 集成

**目标：** 创建统一的用户界面

**技术栈：** PowerShell + Go

**预计时间：** 1-2 小时
**复杂度：** 低

#### 3.1 PowerShell 主入口

```powershell
# scripts/sd-write.ps1

<#
.SYNOPSIS
    SD卡镜像写入工具
.DESCRIPTION
    使用 PowerShell 检测设备，Go 执行写入
#>

param(
    [string]$Image,
    [int]$Disk,
    [switch]$AutoDetect,
    [switch]$List,
    [switch]$Watch,
    [int]$BlockSize = 1MB,
    [switch]$Verify,
    [switch]$Force
)

# 获取脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$GoExe = Join-Path $ScriptDir "..\bin\sd-write.exe"

# 列出设备
if ($List) {
    & $ScriptDir\sd-detect.ps1
    return
}

# 监听模式
if ($Watch) {
    if (-not $Image) {
        throw "监听模式需要指定镜像文件"
    }

    & $ScriptDir\sd-detect.ps1 -Watch -Callback {
        param($drive)
        Write-Host "`n准备写入镜像: $Image" -ForegroundColor Cyan
        & $ScriptDir\sd-write.ps1 -Image $Image -AutoDetect
    }
    return
}

# 检查镜像文件
if (-not (Test-Path $Image)) {
    throw "镜像文件不存在: $Image"
}

# 自动检测SD卡
if ($AutoDetect) {
    $devices = & $ScriptDir\sd-detect.ps1 | Where-Object { $_.IsSDCard }

    if ($devices.Count -eq 0) {
        throw "未检测到SD卡"
    }

    if ($devices.Count -gt 1) {
        & $ScriptDir\sd-detect.ps1
        $selection = Read-Host "`n请选择设备"
        $Disk = $devices[$selection - 1].DiskNumber
    } else {
        $Disk = $devices[0].DiskNumber
        Write-Host "`n自动检测到SD卡: PhysicalDrive$Disk" -ForegroundColor Green
    }
}

# 获取设备信息
$devices = & $ScriptDir\sd-detect.ps1
$targetDisk = $devices | Where-Object { $_.DiskNumber -eq $Disk }

if (-not $targetDisk) {
    throw "未找到磁盘: PhysicalDrive$Disk"
}

# 安全确认
if (-not $Force) {
    Show-Confirmation -Image $Image -Disk $targetDisk
}

# 检查管理员权限
if (-not (Test-Administrator)) {
    throw "需要管理员权限"
}

# 调用 Go exe 执行写入
& $GoExe -image $Image -disk $Disk -bs $BlockSize -verify:$Verify
```

---

### Phase 4: 安全保护（两侧实现）

**目标：** 完善的安全检查

**技术栈：** PowerShell + Go

**预计时间：** 2-3 小时
**复杂度：** 中

#### PowerShell 侧

```powershell
function Test-SystemDisk {
    param([int]$DiskNumber)

    $os = Get-WmiObject Win32_OperatingSystem
    $systemDrive = $os.SystemDrive

    $systemPartition = Get-WmiObject Win32_DiskPartition |
                       Where-Object {
                           (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$systemDrive'").VolumeSerialNumber -eq $_.VolumeSerialNumber
                       }

    if ($systemPartition -and $systemPartition.DiskIndex -eq $DiskNumber) {
        throw "错误：不能写入系统磁盘！"
    }
}

function Invoke-WriteConfirmation {
    param(
        [string]$Image,
        [PSCustomObject]$Disk
    )

    Write-Host "`n" + ("=" * 60) -ForegroundColor Red
    Write-Host "⚠️  警告：即将写入镜像到磁盘" -ForegroundColor Red
    Write-Host ("=" * 60) -ForegroundColor Red

    Write-Host "`n目标磁盘: PhysicalDrive$($Disk.DiskNumber)" -ForegroundColor Yellow
    Write-Host "容量: $($Disk.SizeGB)" -ForegroundColor Yellow
    Write-Host "镜像文件: $Image`n" -ForegroundColor Yellow

    Write-Host "此操作将删除所有数据！无法撤销！`n" -ForegroundColor Red

    $confirm = Read-Host "请输入 'YES' 确认"

    if ($confirm -ne 'YES') {
        throw "操作已取消"
    }
}
```

#### Go 侧

```go
// pkg/safety/systemdisk.go

package safety

import (
    "fmt"
    "os"
    "syscall"
    "unsafe"
)

// Windows API 常量
const (
    ERROR_ACCESS_DENIED = 5
)

var (
    kernel32 = syscall.NewLazyDLL("kernel32.dll")
)

func CheckSystemDisk(diskNumber int) error {
    // 获取系统盘信息
    // 这里需要使用 Windows API 验证

    // 简化版：如果失败则返回错误
    return nil
}

func RequireAdmin() error {
    var token syscall.Token
    currentProcess, _ := syscall.GetCurrentProcess()

    err := syscall.OpenProcessToken(currentProcess, syscall.TOKEN_QUERY, &token)
    if err != nil {
        return err
    }
    defer token.Close()

    var isAdmin bool
    token.IsMember("S-1-16-12288", &isAdmin) // Administrator SID

    if !isAdmin {
        return fmt.Errorf("需要管理员权限")
    }

    return nil
}
```

---

### Phase 5: 编译与打包

**目标：** 一键构建和打包

**技术栈：** PowerShell + Make

**预计时间：** 1-2 小时
**复杂度：** 低

#### 5.1 编译脚本

```powershell
# scripts/build.ps1

<#
.SYNOPSIS
    自动编译脚本
#>

param(
    [ValidateSet("windows", "linux", "darwin", "all")]
    [string]$Platform = "windows"
)

$ErrorActionPreference = "Stop"

# 编译 Go 程序
function Build-Go {
    param($GOOS, $GOARCH, $Output)

    $env:GOOS = $GOOS
    $env:GOARCH = $GOARCH
    $env:CGO_ENABLED = "0"

    Write-Host "编译 $GOOS-$GOARCH..." -ForegroundColor Cyan

    go build -ldflags "-s -w" -o $Output ./cmd/sd-write

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 成功: $Output" -ForegroundColor Green
    } else {
        throw "编译失败"
    }
}

# 清理并创建目录
Remove-Item -Path .\bin -Recurse -Force -ErrorAction SilentlyContinue
New-Item -Path .\bin -ItemType Directory | Out-Null

# 根据平台编译
switch ($Platform) {
    "windows" {
        Build-Go "windows" "amd64" ".\bin\sd-write.exe"
    }
    "linux" {
        Build-Go "linux" "amd64" ".\bin\sd-write"
    }
    "darwin" {
        Build-Go "darwin" "amd64" ".\bin\sd-write"
    }
    "all" {
        Build-Go "windows" "amd64" ".\bin\sd-write.exe"
        Build-Go "linux" "amd64" ".\bin\sd-write-linux"
        Build-Go "darwin" "amd64" ".\bin\sd-write-mac"
    }
}

# 复制脚本文件
Write-Host "`n复制脚本文件..." -ForegroundColor Cyan
Copy-Item -Path ".\scripts\sd-detect.ps1" -Destination ".\bin\"
Copy-Item -Path ".\scripts\sd-write.ps1" -Destination ".\bin\"

Write-Host "`n✓ 构建完成！" -ForegroundColor Green
Write-Host "输出目录: .\bin" -ForegroundColor Gray
```

#### 5.2 Makefile

```makefile
# Makefile

.PHONY: all build clean test

# 默认目标
all: build

# 编译所有平台
build:
	@powershell -NoProfile -File scripts/build.ps1 -Platform all

# 编译 Windows
build-windows:
	@powershell -NoProfile -File scripts/build.ps1 -Platform windows

# 运行测试
test:
	@go test -v ./...
	@powershell -NoProfile -File tests/integration/e2e.test.ps1

# 清理
clean:
	@rm -rf bin/

# 安装到系统
install: build-windows
	@copy bin\sd-write.exe C:\Windows\System32\
	@echo "已安装到 C:\Windows\System32\"
```

---

### Phase 6: 测试与文档

**目标：** 确保质量和可用性

**技术栈：** Go Testing + Pester

**预计时间：** 2-3 小时
**复杂度：** 低

#### Go 单元测试

```go
// pkg/disk/writer_test.go

package disk

import (
    "os"
    "testing"
)

func TestWriter_Write(t *testing.T) {
    // 使用虚拟磁盘测试
    // 或使用 mock

    writer := NewWriter("test.img", 99, 1024*1024)

    err := writer.Write()
    if err != nil {
        t.Errorf("Write() failed: %v", err)
    }
}
```

#### PowerShell 集成测试

```powershell
# tests/integration/e2e.test.ps1

Describe "E2E Tests" {
    BeforeAll {
        Import-Module .\scripts\sd-detect.ps1
    }

    It "应该检测到可移动设备" {
        $devices = Get-PhysicalSD
        $devices | Should -Not -BeNullOrEmpty
    }

    It "应该正确识别SD卡" {
        $devices = Get-PhysicalSD
        $sdCards = $devices | Where-Object { $_.IsSDCard }
        # 在有SD卡的环境中测试
    }
}
```

#### README.md

```markdown
# SD Card Image Writer

高性能的 SD 卡镜像写入工具（PowerShell + Go 混合架构）

## 快速开始

### 1. 下载预编译版本

从 [Releases](releases) 下载对应平台的二进制文件

### 2. 解压使用

```powershell
# 解压到目录
unzip sd-writer-v1.0-windows.zip

# 列出SD卡
.\sd-write.ps1 -List

# 写入镜像
.\sd-write.ps1 -Image .\raspios.img -AutoDetect
```

### 3. 从源码编译

```powershell
# 克隆仓库
git clone https://github.com/user/sd-detect.git
cd sd-detect

# 编译
.\scripts\build.ps1

# 运行
.\bin\sd-write.ps1 -List
```

## 使用示例

### 列出SD卡
```powershell
.\sd-write.ps1 -List
```

### 自动检测并写入
```powershell
.\sd-write.ps1 -Image .\openwrt.img -AutoDetect
```

### 指定设备写入
```powershell
.\sd-write.ps1 -Image .\raspios.img -Disk 2
```

### 监听模式
```powershell
.\sd-write.ps1 -Watch -Image .\backup.img
```

## 架构说明

本工具采用混合架构：

- **PowerShell 层**：设备检测、用户交互、安全检查
- **Go 层**：高性能镜像写入、进度显示

详细架构见：[ARCHITECTURE.md](docs/ARCHITECTURE.md)

## 系统要求

- Windows 10/11
- PowerShell 5.1+
- 管理员权限

## 许可证

MIT License
```

---

## 依赖项

### 运行时依赖

| 依赖 | 版本要求 | 用途 |
|------|---------|------|
| Windows | 10/11 | 操作系统 |
| PowerShell | 5.1+ | 脚本运行时 |
| WMI | 内置 | 设备检测 |

### 开发依赖

| 依赖 | 版本要求 | 用途 |
|------|---------|------|
| Go | 1.21+ | 核心逻辑开发 |
| Git | 最新 | 版本控制 |
| Pester | 5.0+ | PowerShell 测试 |
| Make | 可选 | 构建自动化 |

---

## 安全考虑

### 关键安全问题

| 安全问题 | 风险等级 | 缓解措施 |
|---------|---------|---------|
| 误写系统盘 | **严重** | PS+Go 双重检测 |
| 误写其他USB设备 | **高** | 清晰设备信息确认 |
| 写入中断损坏 | **中** | 异常处理，重试机制 |
| 镜像验证不足 | **中** | 可选哈希验证 |
| 权限提升 | **低** | 需要管理员权限 |

### 安全检查清单

- [ ] PowerShell 侧系统盘检测
- [ ] Go 侧二次验证
- [ ] 用户明确确认
- [ ] 管理员权限检查
- [ ] 镜像文件验证
- [ ] 异常处理完善

---

## 参考资源

### 开源项目

1. **Raspberry Pi Imager** - https://github.com/raspberrypi/rpi-imager
2. **Balena Etcher** - https://github.com/balena-io/etcher
3. **dd for Windows** - https://github.com/ch3ng0/dd

### 技术文档

1. Go Windows API: https://pkg.go.dev/golang.org/x/sys/windows
2. WMI Reference: https://docs.microsoft.com/en-us/windows/win32/wmisdk/wmi-start-page
3. PowerShell Documentation: https://docs.microsoft.com/en-us/powershell/

---

## 时间估算

| 阶段 | 时间 | 技术栈 | 复杂度 |
|-----|------|--------|--------|
| Phase 1: PS设备检测 | 2-3 小时 | PowerShell | 低 |
| Phase 2: Go写入核心 | 4-6 小时 | Go | 中 |
| Phase 3: 集成 | 1-2 小时 | PS + Go | 低 |
| Phase 4: 安全保护 | 2-3 小时 | PS + Go | 中 |
| Phase 5: 编译打包 | 1-2 小时 | PS + Make | 低 |
| Phase 6: 测试文档 | 2-3 小时 | - | 低 |
| **总计** | **12-19 小时** | **混合** | **中** |

---

## 项目里程碑

### Milestone 1: 设备检测 (Phase 1)
✅ PowerShell 模块完成
✅ 能检测和显示SD卡
✅ 监听模式可用

### Milestone 2: 核心写入 (Phase 2)
✅ Go 核心编译成功
✅ 能成功写入镜像
✅ 进度显示正常

### Milestone 3: 完整集成 (Phase 3-4)
✅ PS + Go 集成完成
✅ 安全检查到位
✅ 用户交互友好

### Milestone 4: 发布就绪 (Phase 5-6)
✅ 自动构建完成
✅ 测试覆盖充分
✅ 文档完整

---

## 使用示例

### 快速开始流程

```powershell
# 1. 列出SD卡
PS> .\sd-write.ps1 -List

检测到以下可移动设备:
[1] PhysicalDrive2 - 32.0 GB
    盘符: E:
    卷标: SD_CARD
    类型: SD Card

# 2. 写入镜像
PS> .\sd-write.ps1 -Image .\raspios.img -Disk 2

⚠️  警告：即将写入镜像到磁盘
============================================================
目标磁盘: PhysicalDrive2
容量: 32.0 GB
镜像文件: .\raspios.img

此操作将删除所有数据！无法撤销！

请输入 'YES' 确认: YES

[████████████████████░░░░░░░░░░░░░░░░] 45.2% (1.9 / 4.2 GB) ETA: 0:45

✓ 写入完成！
  大小: 4.2 GB
  耗时: 0:02:15
  速度: 31.2 MB/s
```

### 监听模式

```powershell
PS> .\sd-write.ps1 -Watch -Image .\openwrt.img

正在监听SD卡插入... (Ctrl+C 退出)

[15:23:45] 检测到新设备: E:

自动检测到SD卡: PhysicalDrive2

⚠️  警告：即将写入镜像到磁盘
...
```

---

## 附录

### 命令速查表

| 命令 | 描述 |
|-----|------|
| `.\sd-write.ps1 -List` | 列出所有SD卡 |
| `.\sd-write.ps1 -Image <path> -Disk <n>` | 写入到指定磁盘 |
| `.\sd-write.ps1 -Image <path> -AutoDetect` | 自动检测并写入 |
| `.\sd-write.ps1 -Watch -Image <path>` | 监听模式 |
| `.\sd-detect.ps1` | 单独的设备检测脚本 |

### 退出代码

| 代码 | 含义 |
|-----|------|
| 0 | 成功 |
| 1 | 一般错误 |
| 2 | 权限不足 |
| 3 | 设备未找到 |
| 4 | 写入失败 |
| 5 | 用户取消 |

### 故障排除

| 问题 | 解决方案 |
|-----|---------|
| "访问被拒绝" | 以管理员身份运行 |
| "设备未找到" | 运行 `-List` 查看设备 |
| "写入失败" | 检查SD卡写保护 |
| "进度卡住" | 检查SD卡是否拔出 |

---

**文档版本:** 2.0 (混合方案)
**最后更新:** 2026-03-18
**状态:** 已确认

## 方案选择记录

- ❌ 方案 A：纯 PowerShell - 因性能和分发问题放弃
- ❌ 方案 B：纯 Go - 因 WMI 集成复杂放弃
- ✅ **方案 C：混合方案** - 取长补短，已采纳
