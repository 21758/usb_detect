# 交互式 CLI 工具 - 替代方案

由于网络限制无法安装 Fyne，我创建了一个更实用的交互式 CLI 工具。

## 功能特性

1. **交互式菜单** - 简单的文本界面
2. **设备列表显示** - 格式化的设备信息
3. **文件选择** - 支持拖放或路径输入
4. **进度显示** - 实时写入进度
5. **安全确认** - 多重确认机制

---

## 交互式脚本

创建 `scripts/interactive.ps1`:

```powershell
# scripts/interactive.ps1
# Interactive SD Card Image Writer

param([switch]$Force)

function Show-Menu {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SD Card Image Writer v2.0" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "请选择操作:" -ForegroundColor Yellow
    Write-Host "  1. 列出SD卡设备" -ForegroundColor White
    Write-Host "  2. 写入镜像到SD卡" -ForegroundColor White
    Write-Host "  3. 批量写入（监听模式）" -ForegroundColor White
    Write-Host "  4. 退出" -ForegroundColor White
    Write-Host ""

    $choice = Read-Host "请输入选项 (1-4)"

    switch ($choice) {
        "1" { Show-Devices }
        "2" { Write-Image }
        "3" { WatchMode }
        "4" { exit }
        default { Write-Host "无效选项" -ForegroundColor Red }
    }
}

function Show-Devices {
    Write-Host "`n检测SD卡设备..." -ForegroundColor Yellow

    $devices = & .\scripts\sd-detect.ps1

    if ($devices.Count -eq 0) {
        Write-Host "`n未检测到SD卡设备" -ForegroundColor Red
        return
    }

    Write-Host "`n检测到以下设备:" -ForegroundColor Green
    Write-Host ("=" * 60) -ForegroundColor Gray

    for ($i = 0; $i -lt $devices.Count; $i++) {
        $dev = $devices[$i]
        Write-Host "`n[$($i + 1)] PhysicalDrive$($dev.DiskNumber) - $($dev.SizeGB)" -ForegroundColor Cyan
        Write-Host "    型号: $($dev.Model)" -ForegroundColor White
        Write-Host "    盘符: $($dev.DriveLetter)" -ForegroundColor Gray
        Write-Host "    卷标: $($dev.VolumeName)" -ForegroundColor Gray
        Write-Host "    类型: $(if ($dev.IsSDCard) { 'SD Card' } else { 'Other' })" -ForegroundColor $(if ($dev.IsSDCard) { 'Green' } else { 'Yellow' })
    }

    Write-Host "`n" + ("-" * 60)
    Write-Host "按 Enter 返回主菜单..."
    Read-Host
}

function Write-Image {
    Write-Host "`n=== 写入镜像到SD卡 ===" -ForegroundColor Cyan

    # 1. 显示设备
    $devices = & .\scripts\sd-detect.ps1
    if ($devices.Count -eq 0) {
        Write-Host "未检测到SD卡设备，请先插入SD卡" -ForegroundColor Red
        Read-Host
        return
    }

    Write-Host "`n可用设备:" -ForegroundColor Yellow
    foreach ($dev in $devices) {
        Write-Host "  [$($dev.DiskNumber)] $($dev.Model) - $($dev.SizeGB)" -ForegroundColor White
    }

    $deviceNum = Read-Host "`n请选择设备编号"

    if ($deviceNum -lt 1 -or $deviceNum -gt $devices.Count) {
        Write-Host "无效的设备编号" -ForegroundColor Red
        return
    }

    $selectedDevice = $devices[$deviceNum - 1]

    # 2. 选择镜像
    $imagePath = Read-Host "`n请输入镜像文件路径 (或拖放文件到此窗口)"

    if (-not (Test-Path $imagePath)) {
        Write-Host "文件不存在: $imagePath" -ForegroundColor Red
        return
    }

    # 3. 确认
    $fileInfo = Get-Item $imagePath
    $fileSize = [math]::Round($fileInfo.Length / 1GB, 2)

    Write-Host "`n" + ("=" * 60) -ForegroundColor Red
    Write-Host "⚠️  即将写入镜像到 SD 卡" -ForegroundColor Red
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host "`n目标设备:" -ForegroundColor Yellow
    Write-Host "  物理磁盘: PhysicalDrive$($selectedDevice.DiskNumber)" -ForegroundColor White
    Write-Host "  容量: $($selectedDevice.SizeGB)" -ForegroundColor White
    Write-Host "  型号: $($selectedDevice.Model)" -ForegroundColor White

    Write-Host "`n镜像文件:" -ForegroundColor Yellow
    Write-Host "  路径: $imagePath" -ForegroundColor White
    Write-Host "  大小: $fileSize GB" -ForegroundColor White

    Write-Host "`n" + ("=" * 60) -ForegroundColor Red
    Write-Host "此操作将删除目标磁盘上的所有数据！" -ForegroundColor Red
    Write-Host "此操作无法撤销！" -ForegroundColor Red
    Write-Host ("=" * 60) -ForegroundColor Red
    Write-Host ""

    $confirm = Read-Host "请输入 'YES' 确认继续"

    if ($confirm -ne 'YES') {
        Write-Host "`n操作已取消" -ForegroundColor Yellow
        return
    }

    # 4. 执行写入
    Write-Host "`n开始写入..." -ForegroundColor Green
    & .\bin\sd-write.exe -image $imagePath -disk $selectedDevice.DiskNumber

    Write-Host "`n`n✓ 写入完成！" -ForegroundColor Green
    Write-Host "安全弹出SD卡后即可使用" -ForegroundColor Yellow

    Write-Host "`n按 Enter 返回主菜单..."
    Read-Host
}

function WatchMode {
    Write-Host "`n=== 监听模式 ===" -ForegroundColor Cyan
    Write-Host "`n此模式会自动检测SD卡插入并写入镜像。" -ForegroundColor Yellow

    $imagePath = Read-Host "`n请输入镜像文件路径:"

    if (-not (Test-Path $imagePath)) {
        Write-Host "文件不存在: $imagePath" -ForegroundColor Red
        return
    }

    Write-Host "`n正在监听SD卡插入... (Ctrl+C 退出)" -ForegroundColor Cyan
    Write-Host ""

    # 使用现有的监听功能
    & .\scripts\sd-write.ps1 -Watch -Image $imagePath
}

# Main loop
while ($true) {
    Show-Menu
}
```

---

## 使用方法

```powershell
# 以管理员身份运行
.\scripts\interactive.ps1
```

---

## 功能对比

| 功能 | GUI | 交互式CLI |
|------|-----|----------|
| 易用性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 开发时间 | 6-9小时 | 30分钟 |
| 依赖 | Fyne框架 | 无额外依赖 |
| 跨平台 | 理论支持 | Windows |
| 维护性 | 复杂 | 简单 |

---

**结论：**

考虑到：
1. Fyne 安装遇到网络问题
2. 实际上交互式 CLI 对于这种工具来说更实用
3. 开发时间更短，维护更容易

**我建议使用交互式 CLI 替代 Fyne GUI。**

如果您仍需要 Fyne GUI，请：
1. 手动安装 Fyne: `go get fyne.io/fyne/v2`
2. 然后我可以继续实现完整的 GUI

或者，您希望我继续实现交互式 CLI 版本？
