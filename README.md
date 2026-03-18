# SD Card Image Writer - SD卡镜像写入工具

[![Version](https://img.shields.io/badge/version-2.0-brightgreen.svg)]()
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)]()
[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)]()
[![License](https://img.shields.io/badge/license-MIT-blue.svg)]()

高性能的SD卡镜像写入工具，采用PowerShell + Go混合架构。

---

## ✨ 特性

- 🔍 **智能检测** - 自动识别SD卡设备
- ⚡ **高性能写入** - Go原生文件操作
- 📊 **实时进度** - 40字符进度条 + 速度显示
- 🛡️ **安全可靠** - 多重安全检查和用户确认
- 🎯 **易于使用** - 友好的命令行界面

---

## 🚀 快速开始

### 安装

无需安装，直接使用：

```powershell
# 克隆项目
git clone <repository-url>
cd sd-detect

# 以管理员身份运行 PowerShell
.\scripts\sd-write.ps1 -List
```

### 基础使用

```powershell
# 1. 列出SD卡设备
.\scripts\sd-write.ps1 -List

# 2. 自动检测并写入
.\scripts\sd-write.ps1 -Image .\raspios.img -AutoDetect

# 3. 指定磁盘写入
.\scripts\sd-write.ps1 -Image .\openwrt.img -Disk 2
```

---

## 📖 详细文档

- **[📚 用户使用指南](USER_GUIDE.md)** - 完整的使用说明
- **[📋 版本发布说明](RELEASE_NOTES.md)** - 版本更新记录
- **[🔧 开发文档](docs/)** - 技术文档

---

## 💡 使用示例

### 树莓派系统安装

```powershell
# 下载镜像
Invoke-WebRequest -Uri "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2023-05-03/2023-05-03-raspios-bullseye-armhf-lite.img.xz" -OutFile raspios.img.xz

# 解压并写入
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

## 📋 命令行参数

| 参数 | 说明 |
|------|------|
| `-Image <path>` | 镜像文件路径 |
| `-Disk <number>` | 目标磁盘编号 (0-99) |
| `-AutoDetect` | 自动检测SD卡 |
| `-List` | 列出可用设备 |
| `-Watch` | 监听SD卡插入 |
| `-BlockSize <size>` | 块大小 (512KB/1MB/4MB/8MB) |
| `-Verify` | 写入后验证 |
| `-Force` | 跳过确认（脚本用） |

---

## ⚠️ 重要提示

**此工具会完全擦除目标磁盘上的所有数据！**

使用前请：
1. ✅ 确认已选择正确的SD卡
2. ✅ 备份SD卡上的重要数据
3. ✅ 以管理员身份运行

---

## 🛠️ 系统要求

- **操作系统:** Windows 10/11
- **PowerShell:** 5.1+ (内置)
- **权限:** 管理员权限（写入时需要）

---

## 📊 项目结构

```
sd-detect/
├── scripts/           # PowerShell脚本
│   ├── sd-detect.ps1  # 设备检测
│   ├── sd-write.ps1   # 主入口
│   └── build.ps1      # 编译脚本
├── bin/
│   └── sd-write.exe   # 可执行文件 (1.83MB)
├── pkg/               # Go核心代码
├── tests/             # 测试文件
├── examples/          # 使用示例
└── docs/              # 开发文档
```

---

## 🧪 测试

```powershell
# 运行所有测试
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tests\final-verification.ps1

# 查看测试报告
cat docs/TEST_REPORT.md
```

**测试结果:** 48/48 通过 (100%)

---

## 🎯 适用场景

- ✅ 树莓派系统安装
- ✅ OpenWrt 路由器刷写
- ✅ 开发板系统部署
- ✅ SD卡系统备份恢复

---

## 📝 常见问题

**Q: 提示"需要管理员权限"？**
A: 右键点击 PowerShell，选择"以管理员身份运行"

**Q: 写入后Windows无法读取SD卡？**
A: 正常现象，SD卡现在包含Linux分区。在磁盘管理中重新分配盘符即可。

**Q: 如何查看写入进度？**
A: 工具会自动显示实时进度条

更多问题请查看 [用户使用指南](USER_GUIDE.md)

---

## 🔗 相关链接

- **[用户指南](USER_GUIDE.md)** - 详细使用说明
- **[发布说明](RELEASE_NOTES.md)** - 版本更新记录
- **[测试报告](docs/TEST_REPORT.md)** - 完整测试报告

---

## 📄 许可证

MIT License

---

## 🙏 致谢

本项目采用 TDD 方法开发，确保代码质量和功能稳定性。

---

**SD Card Image Writer v2.0**

*简单、快速、可靠* 🚀
