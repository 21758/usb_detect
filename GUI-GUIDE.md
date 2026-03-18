# SD Card Image Writer - GUI 使用指南

## 概述

这是一个基于 Fyne 框架的图形用户界面应用程序，用于将镜像文件写入 SD 卡。

## 系统要求

- Windows 10/11
- 管理员权限
- GCC 编译器（用于构建，首次使用前需要安装）

## 安装 GCC 编译器

GUI 应用程序需要 CGo 支持。如果您还没有安装 GCC 编译器：

```powershell
# 使用 winget 安装 WinLibs GCC
winget install --id BrechtSanders.WinLibs.MCF.UCRT
```

安装后需要重启终端或刷新环境变量。

## 构建 GUI 应用

```bash
# 设置 CGO
export CGO_ENABLED=1
export PATH="/c/Users/$(whoami)/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.MCF.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64/bin:$PATH"

# 构建
go build -o bin/sd-gui.exe ./cmd/gui
```

## 使用 GUI 应用

### 启动应用

```powershell
# 以管理员身份运行
.\bin\sd-gui.exe
```

### 功能说明

#### 1. 刷新设备
- 点击"刷新设备"按钮
- 应用会自动检测所有 SD 卡读卡器
- 检测到的设备会显示在列表中

#### 2. 选择镜像
- 点击"浏览..."按钮
- 选择 .img 或 .iso 镜像文件
- 支持拖放文件到窗口

#### 3. 写入镜像
1. 从列表中选择目标 SD 卡
2. 选择镜像文件
3. 点击"开始写入"
4. 确认警告信息
5. 等待写入完成

### 安全提示

⚠️ **重要警告**：
- 此操作会删除 SD 卡上的所有数据
- 无法撤销
- 确保选择了正确的设备

## 故障排除

### GCC 未找到
```
错误: gcc: command not found
```
**解决方案**：安装 GCC 并刷新环境变量：
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

### CGO 构建失败
```
错误: build constraints exclude all Go files
```
**解决方案**：确保 CGO_ENABLED=1：
```bash
export CGO_ENABLED=1
```

### 未检测到设备
- 检查 SD 卡是否正确插入
- 尝试重新插拔 SD 卡
- 以管理员身份运行应用

## 项目结构

```
sd_detect/
├── cmd/gui/           # GUI 入口
│   └── main.go
├── pkg/ui/            # GUI 实现
│   └── app.go
├── pkg/devices/       # 设备检测（复用）
├── pkg/disk/          # 磁盘写入（复用）
└── bin/
    └── sd-gui.exe     # 构建的可执行文件
```

## 与 CLI 版本的对比

| 特性 | GUI 版本 | CLI 版本 |
|------|---------|----------|
| 易用性 | ⭐⭐⭐⭐⭐ 图形界面 | ⭐⭐⭐ 命令行 |
| 依赖 | GCC/CGo | 仅 Go |
| 文件大小 | ~45MB | ~2MB |
| 适用场景 | 日常使用 | 脚本/自动化 |

## 下一步

GUI 应用已成功构建！您可以：

1. 运行 `.\bin\sd-gui.exe` 测试 GUI
2. 完善进度显示功能（集成 pkg/disk.Writer）
3. 添加写入验证功能
4. 添加主题/语言设置

需要我继续完善任何功能吗？
