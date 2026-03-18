# SD Card Image Writer - 使用指南

**版本:** 2.0
**更新日期:** 2026-03-18

---

## 📖 目录

1. [快速开始](#快速开始)
2. [安装](#安装)
3. [基础用法](#基础用法)
4. [高级用法](#高级用法)
5. [常见问题](#常见问题)
6. [故障排除](#故障排除)
7. [安全警告](#安全警告)

---

## 快速开始

### 最简单的使用方式

```powershell
# 1. 以管理员身份打开 PowerShell

# 2. 列出SD卡设备
.\scripts\sd-write.ps1 -List

# 3. 自动检测并写入镜像
.\scripts\sd-write.ps1 -Image .\raspios.img -AutoDetect
```

---

## 安装

### 方式一：直接使用（推荐）

无需安装，直接使用即可：

```powershell
# 克隆或下载项目
cd sd-detect

# 确认文件存在
dir scripts\sd-write.ps1
dir bin\sd-write.exe
```

### 方式二：编译（可选）

如果需要从源码编译：

```powershell
# 安装 Go 1.21+
# 运行编译脚本
.\scripts\build.ps1
```

---

## 基础用法

### 1. 列出SD卡设备

```powershell
.\scripts\sd-write.ps1 -List
```

**输出示例：**
```
检测到以下可移动设备:

[1] PhysicalDrive2 - 32.0 GB
    盘符: E:
    卷标: SD_CARD
    型号: SD Card Reader
    类型: SD Card
```

### 2. 自动检测并写入

```powershell
.\scripts\sd-write.ps1 -Image .\raspios.img -AutoDetect
```

**流程：**
1. 自动检测SD卡
2. 显示确认信息
3. 输入 `YES` 确认
4. 开始写入并显示进度

### 3. 指定磁盘写入

```powershell
.\scripts\sd-write.ps1 -Image .\openwrt.img -Disk 2
```

---

## 高级用法

### 监听模式

自动监听SD卡插入，插入后立即写入：

```powershell
.\scripts\sd-write.ps1 -Watch -Image .\backup.img
```

**使用场景：** 批量刷写多张SD卡

### 自定义块大小

```powershell
.\scripts\sd-write.ps1 -Image .\image.img -Disk 2 -BlockSize 4194304
```

**可选值：**
- `524288` (512KB) - 适合小文件
- `1048576` (1MB) - 默认值，推荐
- `4194304` (4MB) - 适合大文件
- `8388608` (8MB) - 最大值

### 写入后验证

```powershell
.\scripts\sd-write.ps1 -Image .\image.img -AutoDetect -Verify
```

**注意：** 验证功能会额外花费一些时间

### 强制模式（跳过确认）

**仅用于脚本自动化的场景：**

```powershell
.\scripts\sd-write.ps1 -Image .\image.img -Disk 2 -Force
```

⚠️ **警告：** 强制模式会跳过所有确认，请确保参数正确！

---

## 命令行参数完整列表

| 参数 | 类型 | 必需 | 描述 |
|------|------|------|------|
| `-Image` | string | 条件* | 镜像文件路径 |
| `-Disk` | int | 条件* | 目标磁盘编号 (0-99) |
| `-AutoDetect` | switch | 否 | 自动检测SD卡 |
| `-List` | switch | 否 | 列出可用设备 |
| `-Watch` | switch | 否 | 监听SD卡插入 |
| `-BlockSize` | int | 否 | 块大小（字节） |
| `-Verify` | switch | 否 | 写入后验证 |
| `-Force` | switch | 否 | 跳过确认提示 |

* `-Image` 或 `-List` 必须提供其一
* `-Disk` 或 `-AutoDetect` 必须提供其一

---

## 常见问题

### Q: 提示"需要管理员权限"？

**A:** 右键点击 PowerShell，选择"以管理员身份运行"

### Q: 写入后Windows无法读取SD卡？

**A:** 正常现象。SD卡现在包含Linux分区。

解决方法：
1. 打开"磁盘管理"
2. 右键点击SD卡分区
3. 选择"删除卷"
4. 创建新简单卷并格式化

### Q: 如何查看写入进度？

**A:** 工具会自动显示实时进度条：

```
[████████████████████░░░░░░░░░░░░░░░░░] 45.2% (1.9/4.2 GB) ETA: 0:45
```

### Q: 支持哪些镜像格式？

**A:** 支持所有原始磁盘镜像格式：
- `.img` - 标准磁盘镜像
- `.iso` - ISO镜像（部分支持）
- 直接复制文件到SD卡

### Q: 写入速度很慢？

**A:** 尝试增大块大小：

```powershell
.\scripts\sd-write.ps1 -Image .\image.img -Disk 2 -BlockSize 4194304
```

---

## 故障排除

### 问题 1: 设备未找到

**症状：**
```
ERROR: Disk not found: PhysicalDrive2
```

**解决方案：**
1. 检查SD卡是否正确插入
2. 运行 `-List` 查看可用设备
3. 重新拔插SD卡
4. 更换SD卡插槽

### 问题 2: 写入失败

**症状：**
```
ERROR: Write failed
```

**可能原因：**
1. SD卡写保护开关已打开
2. SD卡已损坏
3. SD卡接触不良
4. 权限不足

**解决方案：**
1. 检查SD卡写保护开关
2. 尝试更换SD卡
3. 清洁SD卡金属触点
4. 确保以管理员身份运行

### 问题 3: 进度卡住

**症状：**
进度条长时间不动

**可能原因：**
1. SD卡在写入过程中被拔出
2. SD卡出现坏块
3. USB接口供电不足

**解决方案：**
1. 不要在写入过程中拔出SD卡
2. 尝试更换SD卡
3. 使用后置USB接口（供电更稳定）

### 问题 4: 参数验证错误

**症状：**
```
ERROR: Invalid block size
```

**解决方案：**
使用有效的块大小值：
- 512KB = 524288
- 1MB = 1048576
- 4MB = 4194304
- 8MB = 8388608

---

## 安全警告

### ⚠️ 重要提示

**此工具会完全擦除目标磁盘上的所有数据！**

### 使用前检查清单

- [ ] 确认已选择正确的SD卡
- [ ] 确认SD卡上没有重要数据
- [ ] 备份SD卡上的所有重要文件
- [ ] 了解操作无法撤销

### 系统盘保护

工具会自动检测系统盘并拒绝写入，但请仍然注意：

1. 仔细查看确认信息中的磁盘编号
2. 确认磁盘容量是否正确
3. 确认盘符是否正确

### 写入后注意事项

1. **不要格式化** Windows提示的"需要格式化"警告
2. **安全弹出** 写入完成后安全弹出SD卡
3. **验证镜像** 首次使用建议验证镜像完整性

---

## 实用示例

### 树莓派系统安装

```powershell
# 1. 下载镜像
Invoke-WebRequest -Uri "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf-lite.img.xz" -OutFile raspios.img.xz

# 2. 解压（使用 7-Zip 或其他工具）

# 3. 写入SD卡
.\scripts\sd-write.ps1 -Image .\raspios.img -AutoDetect
```

### OpenWrt 刷写

```powershell
.\scripts\sd-write.ps1 -Image .\openwrt-23.05-sdcard.img -AutoDetect -BlockSize 4194304
```

### 批量刷写多张SD卡

```powershell
# 使用监听模式
.\scripts\sd-write.ps1 -Watch -Image .\firmware.img

# 然后依次插入SD卡，每次写入完成后：
# 1. 等待写入完成
# 2. 拔出SD卡
# 3. 插入下一张SD卡
# 脚本会自动检测并写入
```

---

## 进阶技巧

### 检查SD卡健康状态

```powershell
# 列出设备并查看详细信息
.\scripts\sd-write.ps1 -List

# 查看是否被识别为SD卡
.\scripts\sd-detect.ps1 | Where-Object { $_.IsSDCard }
```

### 获取镜像信息

```powershell
# 查看镜像文件大小
(Get-Item .\raspios.img).Length / 1GB

# 查看镜像SHA256（用于验证）
Get-FileHash .\raspios.img -Algorithm SHA256
```

### 创建写入脚本

```powershell
# batch-write.ps1
$images = @("image1.img", "image2.img", "image3.img")

foreach ($img in $images) {
    Write-Host "写入 $img..." -ForegroundColor Cyan
    .\scripts\sd-write.ps1 -Image $img -AutoDetect -Force

    Write-Host "完成！请更换SD卡..." -ForegroundColor Yellow
    Read-Host "按 Enter 继续"
}
```

---

## 技术支持

### 获取帮助信息

```powershell
# 显示命令行帮助
.\scripts\sd-write.ps1

# 显示Go二进制帮助
.\bin\sd-write.exe
```

### 日志信息

所有操作都会显示详细的进度和状态信息。

如遇问题，请记录：
1. 完整的错误消息
2. 使用的命令
3. SD卡型号和容量
4. 镜像文件名称和大小

---

## 附录

### A. 退出代码

| 代码 | 含义 |
|------|------|
| 0 | 成功 |
| 1 | 一般错误 |
| 2 | 权限不足 |
| 3 | 设备未找到 |
| 4 | 写入失败 |
| 5 | 用户取消 |

### B. 磁盘编号说明

- **PhysicalDrive0** - 通常是系统盘（不要写入！）
- **PhysicalDrive1** - 可能是系统盘或多硬盘
- **PhysicalDrive2+** - 通常是可移动设备

**建议：** 始终使用 `-List` 确认正确的磁盘编号

### C. 性能参考

| SD卡等级 | 写入速度 | 4GB镜像耗时 |
|---------|---------|------------|
| Class 4 | ~4 MB/s | ~17分钟 |
| Class 10 | ~10 MB/s | ~7分钟 |
| UHS-1 | ~20 MB/s | ~3.5分钟 |
| UHS-3 | ~80 MB/s | ~1分钟 |

*实际速度取决于SD卡和读卡器质量

---

## 更新日志

### v2.0 (2026-03-18)

- ✨ 混合架构（PowerShell + Go）
- ✨ 自动SD卡检测
- ✨ 实时进度显示
- ✨ 监听模式
- ✨ 完善的错误处理

---

## 许可证

MIT License

---

**SD Card Image Writer v2.0**

如有问题或建议，欢迎反馈。

*祝使用愉快！* 🚀

---

## 🖥️ GUI 版本

### 概述

除了命令行版本，我们还提供了基于 Fyne 的图形用户界面。

### 构建 GUI 应用

```bash
# 1. 安装 GCC（用于 CGo）
winget install --id BrechtSanders.WinLibs.MCF.UCRT

# 2. 重启终端后构建
export CGO_ENABLED=1
go build -o bin/sd-gui.exe ./cmd/gui
```

### 使用 GUI

```powershell
# 以管理员身份运行
.\bin\sd-gui.exe
```

### GUI 功能

- 🖱️ 图形界面，易于使用
- 📋 自动检测 SD 卡设备
- 📁 可视化文件选择
- 📊 实时进度显示
- ⚠️ 安全确认对话框

详细使用说明请参阅 [GUI-GUIDE.md](GUI-GUIDE.md)

### CLI vs GUI

| 特性 | CLI 版本 | GUI 版本 |
|------|----------|----------|
| 易用性 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 依赖 | 仅 Go | Go + GCC |
| 文件大小 | ~2MB | ~45MB |
| 自动化 | ✅ 优秀 | ❌ 不支持 |
| 日常使用 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

**SD Card Image Writer v2.0** - CLI + GUI 双版本

