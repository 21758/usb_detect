// Package ui provides Fyne UI for SD card image writer
package ui

import (
	"fmt"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/storage"
	"fyne.io/fyne/v2/widget"

	"github.com/sd-detect/pkg/devices"
)

// App represents the main application
type App struct {
	fyneApp   fyne.App
	window    fyne.Window

	// UI Components
	deviceList     *widget.List
	devices        []devices.Device
	fileEntry      *widget.Entry
	progressBar    *widget.ProgressBar
	statusLabel    *widget.Label
	writeBtn       *widget.Button
	refreshBtn     *widget.Button
	browseBtn      *widget.Button

	// State
	selectedIndex int
	imagePath     string
	isWriting     bool
}

// NewApp creates a new application instance
func NewApp() *App {
	a := app.NewWithID("com.sd-detect.gui")

	return &App{
		fyneApp:      a,
		devices:      make([]devices.Device, 0),
		selectedIndex: -1,
	}
}

// CreateAndRun creates the main window and starts the application
func (a *App) CreateAndRun() {
	a.window = a.fyneApp.NewWindow("SD Card Image Writer v2.0")
	a.window.Resize(fyne.NewSize(900, 650))
	a.window.CenterOnScreen()
	a.window.SetFixedSize(false)

	// Create main content with better layout
	content := container.New(
		layout.NewVBoxLayout(),
		a.createHeader(),
		container.NewPadded(
			container.New(
				layout.NewVBoxLayout(),
				a.createMainSections(),
				layout.NewSpacer(),
				a.createActions(),
				a.createProgress(),
			),
		),
	)

	a.window.SetContent(content)
	a.window.Show()
	a.fyneApp.Run()
}

func (a *App) createHeader() *fyne.Container {
	title := widget.NewLabel("SD Card Image Writer v2.0")
	title.TextStyle = fyne.TextStyle{Bold: true}
	title.Alignment = fyne.TextAlignCenter

	return container.New(
		layout.NewVBoxLayout(),
		layout.NewSpacer(),
		title,
		layout.NewSpacer(),
		widget.NewSeparator(),
	)
}

func (a *App) createMainSections() *fyne.Container {
	// Use a tabs layout or scroll container for better space management
	return container.New(
		layout.NewVBoxLayout(),
		a.createDeviceSection(),
		widget.NewSeparator(),
		a.createFileSection(),
	)
}

func (a *App) createDeviceSection() *fyne.Container {
	label := widget.NewLabel("SD 卡设备")
	label.TextStyle = fyne.TextStyle{Bold: true}

	a.deviceList = widget.NewList(
		func() int {
			return len(a.devices)
		},
		func() fyne.CanvasObject {
			return widget.NewLabel("")
		},
		func(id widget.ListItemID, obj fyne.CanvasObject) {
			if id < 0 || id >= len(a.devices) {
				return
			}
			dev := a.devices[id]
			label := obj.(*widget.Label)
			label.SetText(fmt.Sprintf("[%d] %s - %s", id+1, dev.Model, dev.SizeGB))
		},
	)

	// Set minimum size for device list
	a.deviceList.Resize(fyne.NewSize(400, 200))

	a.deviceList.OnSelected = func(id widget.ListItemID) {
		a.selectedIndex = int(id)
		a.checkReadyToWrite()
	}

	a.refreshBtn = widget.NewButton("刷新设备", func() {
		a.refreshDevices()
	})

	deviceInfo := widget.NewLabel("选择要写入的 SD 卡设备")
	deviceInfo.TextStyle = fyne.TextStyle{Italic: true}

	topRow := container.New(
		layout.NewHBoxLayout(),
		label,
		layout.NewSpacer(),
		deviceInfo,
	)

	listContainer := container.New(
		layout.NewVBoxLayout(),
		topRow,
		widget.NewCard("", "", a.deviceList),
		container.New(
			layout.NewHBoxLayout(),
			layout.NewSpacer(),
			a.refreshBtn,
		),
	)

	return listContainer
}

func (a *App) createFileSection() *fyne.Container {
	label := widget.NewLabel("镜像文件")
	label.TextStyle = fyne.TextStyle{Bold: true}

	a.fileEntry = widget.NewEntry()
	a.fileEntry.PlaceHolder = "点击下方按钮选择 .img 或 .iso 镜像文件"
	a.fileEntry.Disable()

	a.browseBtn = widget.NewButton("浏览文件...", func() {
		a.showFileDialog()
	})

	fileInfo := widget.NewLabel("选择要写入的镜像文件")
	fileInfo.TextStyle = fyne.TextStyle{Italic: true}

	topRow := container.New(
		layout.NewHBoxLayout(),
		label,
		layout.NewSpacer(),
		fileInfo,
	)

	fileCard := container.NewVBox(
		a.fileEntry,
	)

	buttonContainer := container.New(
		layout.NewHBoxLayout(),
		layout.NewSpacer(),
		a.browseBtn,
	)

	return container.New(
		layout.NewVBoxLayout(),
		topRow,
		widget.NewCard("", "", fileCard),
		buttonContainer,
	)
}

func (a *App) createActions() *fyne.Container {
	a.writeBtn = widget.NewButton("开始写入", func() {
		a.startWrite()
	})
	a.writeBtn.Disable()
	a.writeBtn.Importance = widget.HighImportance

	return container.New(
		layout.NewHBoxLayout(),
		layout.NewSpacer(),
		a.writeBtn,
		layout.NewSpacer(),
	)
}

func (a *App) createProgress() *fyne.Container {
	label := widget.NewLabel("状态")
	label.TextStyle = fyne.TextStyle{Bold: true}

	a.progressBar = widget.NewProgressBar()
	a.statusLabel = widget.NewLabel("就绪")

	return container.New(
		layout.NewVBoxLayout(),
		label,
		a.progressBar,
		a.statusLabel,
	)
}

// refreshDevices refreshes the device list
func (a *App) refreshDevices() {
	a.statusLabel.SetText("正在检测设备...")
	a.refreshBtn.Disable()

	go func() {
		devicesList, err := devices.DetectDevicesSync()
		a.updateAfterRefresh(devicesList, err)
	}()
}

func (a *App) updateAfterRefresh(devicesList []devices.Device, err error) {
	// Use goroutine-safe canvas refresh
	canvas := a.window.Canvas()
	if canvas != nil {
		canvas.Refresh(a.statusLabel)
		canvas.Refresh(a.refreshBtn)

		if err != nil {
			dialog.ShowError(err, a.window)
			a.statusLabel.SetText("检测失败")
			return
		}

		if len(devicesList) == 0 {
			dialog.ShowInformation("未检测到设备", "未检测到 SD 卡设备，请确认已插入 SD 卡。", a.window)
			a.statusLabel.SetText("无设备")
			return
		}

		a.devices = devicesList
		a.deviceList.Refresh()
		a.statusLabel.SetText(fmt.Sprintf("检测到 %d 个设备", len(devicesList)))
	}
}

// showFileDialog shows the file selection dialog
func (a *App) showFileDialog() {
	fd := dialog.NewFileOpen(func(reader fyne.URIReadCloser, err error) {
		if err != nil {
			dialog.ShowError(err, a.window)
			return
		}
		if reader == nil {
			return
		}
		defer reader.Close()

		uri := reader.URI()
		a.imagePath = uri.Path()
		a.fileEntry.SetText(uri.Path())
		a.statusLabel.SetText(fmt.Sprintf("已选择: %s", uri.Name()))
		a.checkReadyToWrite()
	}, a.window)

	// Set file extensions filter
	fd.SetFilter(storage.NewExtensionFileFilter([]string{".img", ".iso"}))
	fd.Show()
}

// startWrite initiates the write operation
func (a *App) startWrite() {
	device := a.getSelectedDevice()
	if device == nil {
		dialog.ShowError(fmt.Errorf("未选择设备"), a.window)
		return
	}

	if a.imagePath == "" {
		dialog.ShowError(fmt.Errorf("未选择镜像"), a.window)
		return
	}

	// Show confirmation with more details
	confirmText := fmt.Sprintf(
		"即将写入镜像到 SD 卡\n\n"+
			"设备信息:\n"+
			"  型号: %s\n"+
			"  容量: %s\n"+
			"  物理磁盘: PhysicalDrive%d\n\n"+
			"镜像文件:\n"+
			"  %s\n\n"+
			"⚠️  此操作将删除目标磁盘上的所有数据！\n"+
			"⚠️  此操作无法撤销！\n\n"+
			"确定要继续吗？",
		device.Model, device.SizeGB, device.DiskNumber, a.imagePath,
	)

	dialog.ShowConfirm("确认写入", confirmText, func(ok bool) {
		if !ok {
			return
		}
		a.performWrite()
	}, a.window)
}

// performWrite executes the actual write operation
func (a *App) performWrite() {
	a.isWriting = true
	a.writeBtn.Disable()
	a.refreshBtn.Disable()
	a.browseBtn.Disable()

	// TODO: Implement actual write with progress updates
	// This would call the existing disk.Writer with progress callback
	go func() {
		// Simulate progress for now
		for i := 0; i <= 100; i += 5 {
			a.updateProgress(float64(i) / 100.0)
		}
		a.finishWrite()
	}()
}

func (a *App) updateProgress(value float64) {
	a.progressBar.SetValue(value)
	percent := int(value * 100)
	a.statusLabel.SetText(fmt.Sprintf("正在写入... %d%%", percent))
}

func (a *App) finishWrite() {
	a.progressBar.SetValue(1.0)
	a.statusLabel.SetText("写入完成！")
	dialog.ShowInformation("完成", "镜像已成功写入到 SD 卡。\n\n安全弹出 SD 卡后即可使用。", a.window)
	a.isWriting = false
	a.checkReadyToWrite()
	a.refreshBtn.Enable()
	a.browseBtn.Enable()
}

// checkReadyToWrite checks if both device and image are selected
func (a *App) checkReadyToWrite() {
	device := a.getSelectedDevice()
	if device != nil && a.imagePath != "" && !a.isWriting {
		a.writeBtn.Enable()
	} else {
		a.writeBtn.Disable()
	}
}

func (a *App) getSelectedDevice() *devices.Device {
	if a.selectedIndex >= 0 && a.selectedIndex < len(a.devices) {
		return &a.devices[a.selectedIndex]
	}
	return nil
}
