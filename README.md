# USB/SD Card Image Writer - USB/SD卡镜像写入工具

[![Version](https://img.shields.io/badge/version-2.0-brightgreen.svg)]()
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)]()
[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)]()
[![License](https://img.shields.io/badge/license-GPLv3-blue.svg)]()
[![GUI](https://img.shields.io/badge/GUI-Fyne-green.svg)]()

高性能的 SD 卡镜像写入工具，采用 Go + Fyne GUI 架构，支持 CLI 和 GUI 两种使用方式。

---

## ✨ 特性

- 🔍 **智能检测** - 自动识别 SD 卡设备
- 🖥️ **图形界面** - 友好的 GUI 应用程序
- ⚡ **高性能写入** - Go 原生文件操作
- 📊 **实时进度** - 进度条 + 速度显示
- 🛡️ **安全可靠** - 多重安全检查和用户确认
- 🎯 **易于使用** - CLI 和 GUI 双模式

---

## 🚀 快速开始

### 下载使用

从 [Releases](https://github.com/21758/usb_detect/releases) 下载预编译的二进制文件。

### GUI 模式（推荐）

双击 `启动GUI.bat` 或直接运行 `sd-gui.exe`：

```powershell
.\bin\sd-gui.exe
```

### CLI 模式

```powershell
# 列出 SD 卡设备
.\scripts\sd-write.ps1 -List

# 自动检测并写入
.\scripts\sd-write.ps1 -Image .\raspios.img -AutoDetect

# 指定磁盘写入
.\scripts\sd-write.ps1 -Image .\openwrt.img -Disk 2
```

### 直接使用二进制

```powershell
# CLI 模式
.\bin\sd-write.exe -list
.\bin\sd-write.exe -image .\raspios.img -disk 2 -bs 1048576
```

---

## 📖 命令行参数

### PowerShell 脚本参数

| 参数 | 说明 |
|------|------|
| `-Image <path>` | 镜像文件路径 |
| `-Disk <number>` | 目标磁盘编号 (0-99) |
| `-AutoDetect` | 自动检测 SD 卡 |
| `-List` | 列出可用设备 |
| `-Watch` | 监听 SD 卡插入 |
| `-BlockSize <size>` | 块大小 (512KB/1MB/4MB/8MB) |
| `-Verify` | 写入后验证 |
| `-Force` | 跳过确认 |

### CLI 二进制参数

| 参数 | 说明 |
|------|------|
| `-image <path>` | 镜像文件路径 |
| `-disk <number>` | 目标磁盘编号 (0-99) |
| `-bs <bytes>` | 块大小（字节，默认 1MB） |
| `-verify` | 写入后验证 |
| `-list` | 列出可用设备 |

---

## 💡 使用示例

### 树莓派系统安装

```powershell
# GUI 模式
.\bin\sd-gui.exe

# CLI 模式
.\scripts\sd-write.ps1 -Image .\raspios.img -AutoDetect
```

### 监听模式（批量刷写）

```powershell
.\scripts\sd-write.ps1 -Watch -Image .\firmware.img
```

### 带验证的写入

```powershell
.\scripts\sd-write.ps1 -Image .\image.img -AutoDetect -Verify
```

---

## 📋 项目结构

```
usb_detect/
├── cmd/               # 命令行入口
│   ├── sd-write/      # CLI 应用
│   └── gui/           # GUI 应用
├── pkg/               # Go 核心代码
│   ├── disk/          # 磁盘写入
│   ├── progress/      # 进度显示
│   ├── devices/       # 设备检测
│   └── ui/            # GUI 界面
├── scripts/           # PowerShell 脚本
│   ├── sd-detect.ps1  # 设备检测
│   └── sd-write.ps1   # 主入口脚本
├── bin/               # 编译输出
│   ├── sd-write.exe   # CLI 可执行文件
│   └── sd-gui.exe     # GUI 可执行文件
├── 启动GUI.bat        # GUI 启动脚本
└── LICENSE            # GPL v3 许可证
```

---

## ⚠️ 重要提示

**此工具会完全擦除目标磁盘上的所有数据！**

使用前请：
1. ✅ 确认已选择正确的 SD 卡
2. ✅ 备份 SD 卡上的重要数据
3. ✅ 以管理员身份运行

---

## 🛠️ 系统要求

- **操作系统:** Windows 10/11
- **PowerShell:** 5.1+ (内置)
- **权限:** 管理员权限（写入时需要）

---

## 🧪 开发

### 编译

```powershell
# 编译 CLI
go build -o bin/sd-write.exe ./cmd/sd-write

# 编译 GUI
go build -o bin/sd-gui.exe ./cmd/gui
```

### 运行测试

```powershell
go test ./...
```

---

## 🎯 适用场景

- ✅ 树莓派系统安装
- ✅ OpenWrt 路由器刷写
- ✅ 开发板系统部署
- ✅ SD 卡系统备份恢复

---

## 📝 常见问题

**Q: 提示"需要管理员权限"？**
A: 右键点击 PowerShell，选择"以管理员身份运行"

**Q: 写入后 Windows 无法读取 SD 卡？**
A: 正常现象，SD 卡现在包含 Linux 分区。在磁盘管理中重新分配盘符即可。

**Q: GUI 无法启动？**
A: 确保 Windows 防火墙/杀毒软件没有阻止程序运行。

---

## 🔗 相关链接

- **GitHub:** https://github.com/21758/usb_detect
- **Fyne:** https://fyne.io/

---

## 📄 许可证

GNU General Public License v3.0

---

**USB/SD Card Image Writer v2.0**

*简单、快速、可靠* 🚀
