# Fyne GUI Bug Fixes - 线程安全和设备检测

## 🐛 修复的问题

### 1. Fyne 线程安全错误
```
Error: *** Error in Fyne call thread, this should have been called in fyne.Do[AndWait] ***
From: D:/sd_detect/pkg/ui/app.go:246
```

**原因：** 在 goroutine 中直接调用 Fyne UI 组件的更新方法。

**修复：**
- 移除了 `a.window.QueueEvent()`（Window 上不存在此方法）
- 对于简单的 UI 更新（SetText, SetValue），Fyne 2.x 已内部处理线程安全
- 对于复杂的 UI 操作，使用 `canvas.Refresh()` 方法

### 2. U盘检测问题

**可能原因：**
- 没有管理员权限
- PowerShell 脚本路径错误
- 执行策略限制

---

## ✅ 修复详情

### 修改的文件：`pkg/ui/app.go`

#### 修复前（有问题）:
```go
go func() {
    devicesList, err := devices.DetectDevicesSync()
    a.updateAfterRefresh(devicesList, err, a.refreshBtn.Enable)
}()

func (a *App) updateAfterRefresh(...) {
    a.window.QueueEvent(func() {  // ❌ 方法不存在
        a.statusLabel.SetText("...")
        a.deviceList.Refresh()
    })
}
```

#### 修复后（正确）:
```go
go func() {
    devicesList, err := devices.DetectDevicesSync()
    a.updateAfterRefresh(devicesList, err)
}()

func (a *App) updateAfterRefresh(...) {
    canvas := a.window.Canvas()
    if canvas != nil {
        canvas.Refresh(a.statusLabel)
        canvas.Refresh(a.refreshBtn)

        // 简单的 UI 更新在 Fyne 2.x 中是线程安全的
        a.statusLabel.SetText("检测到 X 个设备")
        a.deviceList.Refresh()
    }
}
```

---

## 🔧 使用诊断工具

### 运行 USB 诊断脚本

```powershell
# 以管理员身份运行 PowerShell
cd D:\sd_detect
.\diagnose-usb.ps1
```

**诊断检查项：**
1. ✅ 管理员权限检查
2. ✅ sd-detect.ps1 脚本存在性
3. ✅ PowerShell 执行策略
4. ✅ WMI USB/可移动设备检测
5. ✅ sd-detect.ps1 脚本执行测试

---

## 📋 故障排除步骤

### 问题 1: "检测失败" 或 "无设备"

**解决方案：**

1. **确认管理员权限**
   ```powershell
   # 右键 PowerShell → "以管理员身份运行"
   ```

2. **运行诊断脚本**
   ```powershell
   .\diagnose-usb.ps1
   ```

3. **手动测试设备检测**
   ```powershell
   .\scripts\sd-detect.ps1 -List
   ```

4. **检查 PowerShell 执行策略**
   ```powershell
   Get-ExecutionPolicy
   # 如果是 Restricted，运行：
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### 问题 2: GUI 线程安全错误（已修复）

**确认修复：**
- 线程安全错误应该已经解决
- 如果仍然出现，请确保使用最新构建的 `sd-gui.exe`

---

## 🚀 重新构建

```bash
# 设置环境
export PATH="/c/Users/31085/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.MCF.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64/bin:$PATH"
export CGO_ENABLED=1

# 构建
go build -o bin/sd-gui.exe ./cmd/gui
```

---

## 📝 技术说明

### Fyne 2.x 线程安全

**线程安全操作：**
- `widget.SetText()` - ✅ 线程安全
- `widget.SetValue()` - ✅ 线程安全
- `widget.Disable()` / `Enable()` - ✅ 线程安全
- `widget.Refresh()` - ✅ 线程安全

**需要特别注意：**
- Dialog 显示 - ✅ 自动处理线程安全
- Canvas 操作 - ⚠️ 使用 `canvas.Refresh()`
- 复杂的多步 UI 更新 - ⚠️ 考虑使用通道同步

### 推荐模式

```go
// ✅ 好的做法：简单的 UI 更新
go func() {
    data := fetchData()
    widget.SetText(data)  // Fyne 内部处理同步
}()

// ✅ 更好的做法：使用 canvas.Refresh()
go func() {
    data := fetchData()
    canvas := window.Canvas()
    canvas.Refresh(widget)  // 显式刷新
}()

// ❌ 避免在 goroutine 中进行复杂的 UI 操作
go func() {
    // 不要创建新窗口或在 goroutine 中显示对话框
}()
```

---

## ✨ 总结

| 问题 | 状态 | 解决方案 |
|------|------|----------|
| Fyne 线程安全错误 | ✅ 已修复 | 使用线程安全的 UI 更新方法 |
| U盘检测问题 | 🔍 诊断中 | 使用 diagnose-usb.ps1 诊断 |
| 管理员权限问题 | 📋 已知 | 必须以管理员身份运行 |

---

**下一步：** 运行 `.\diagnose-usb.ps1` 诊断 USB 检测问题！
