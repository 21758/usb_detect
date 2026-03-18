# GUI 故障排除指南

## 问题：GUI 没有显示

### ✅ 解决方案

#### 方法 1：使用批处理文件（推荐）

```
双击运行：启动GUI.bat
```

#### 方法 2：使用 PowerShell

```powershell
# 右键点击 PowerShell，选择"以管理员身份运行"
cd D:\sd_detect
.\bin\sd-gui.exe
```

#### 方法 3：使用命令提示符

```cmd
# 右键点击 cmd，选择"以管理员身份运行"
cd D:\sd_detect
bin\sd-gui.exe
```

---

### ❌ 不要使用

- ❌ Git Bash
- ❌ WSL (Windows Subsystem for Linux)
- ❌ MSYS2
- ❌ Cygwin

这些终端环境无法正确显示 Windows GUI 应用程序。

---

## 🔍 诊断工具

### 运行诊断脚本

```powershell
.\diagnose-gui.ps1
```

这会检查：
- ✓ 可执行文件是否存在
- ✓ OpenGL 支持
- ✓ 管理员权限
- ✓ 显示器配置
- ✓ 所需的 DLL 文件

---

## 🛠️ 常见问题

### 问题 1：窗口打开了但不可见

**解决方案：**
- 按 `Alt + Tab` 查找窗口
- 检查任务栏是否有应用图标
- 窗口可能在其他显示器上（如果有多显示器）

### 问题 2：进程启动但立即退出

**可能原因：**
- 缺少 Visual C++ 运行时
- OpenGL 驱动问题

**解决方案：**
```
1. 更新显卡驱动
2. 安装 Visual C++ Redistributable
3. 运行 diagnose-gui.ps1 检查依赖
```

### 问题 3：权限错误

**解决方案：**
```
右键点击 sd-gui.exe → 以管理员身份运行
```

---

## ✅ 检查清单

使用前请确认：

- [ ] 使用 Windows PowerShell 或 cmd（不是 Git Bash）
- [ ] 以管理员身份运行
- [ ] bin\sd-gui.exe 文件存在（约 42-45 MB）
- [ ] 已安装 GCC 编译器（用于构建）
- [ ] 显卡驱动已更新（支持 OpenGL）

---

## 📝 快速测试

创建一个测试文件 `test-gui.ps1`：

```powershell
# Test GUI launch
Write-Host "Starting GUI..." -ForegroundColor Green
Start-Process -FilePath "D:\sd_detect\bin\sd-gui.exe"
Write-Host "GUI should appear in a few seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Check if process is running
$process = Get-Process -Name "sd-gui" -ErrorAction SilentlyContinue
if ($process) {
    Write-Host "✓ GUI is running!" -ForegroundColor Green
    Write-Host "  PID: $($process.Id)" -ForegroundColor Cyan
} else {
    Write-Host "✗ GUI process not found" -ForegroundColor Red
}
```

运行测试：
```powershell
.\test-gui.ps1
```

---

## 🎯 最佳实践

1. **首次使用**
   - 使用 `启动GUI.bat` 启动
   - 以管理员身份运行

2. **日常使用**
   - 创建桌面快捷方式指向 `启动GUI.bat`
   - 或直接双击 `启动GUI.bat`

3. **开发/调试**
   - 使用 PowerShell 进行测试
   - 查看进程：`Get-Process sd-gui`
   - 强制关闭：`Stop-Process -Name sd-gui`

---

## 📞 仍然无法解决？

运行完整诊断并保存输出：

```powershell
.\diagnose-gui.ps1 > diagnostics.txt
```

然后检查 `diagnostics.txt` 文件内容。

---

**总结：GUI 应用必须在 Windows 原生环境中运行，不能从 Git Bash/WSL 启动。** 🖥️
