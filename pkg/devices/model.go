// Package devices provides SD card device detection and management
package devices

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

// Device represents an SD card or removable device
type Device struct {
	DeviceID    int     `json:"device_id"`
	DiskNumber  int     `json:"disk_number"`
	Size        float64 `json:"size"`
	SizeGB      string  `json:"size_gb"`
	Model       string  `json:"model"`
	MediaType   string  `json:"media_type"`
	DriveLetter string  `json:"drive_letter"`
	VolumeName  string  `json:"volume_name"`
	FileSystem  string  `json:"file_system"`
	IsSDCard    bool    `json:"is_sd_card"`
}

// Detector handles device detection operations
type Detector struct {
	scriptPath string
}

// NewDetector creates a new device detector
func NewDetector() *Detector {
	return &Detector{
		scriptPath: "scripts\\sd-write.ps1",
	}
}

// DetectDevices detects all removable SD card devices by calling PowerShell
func (d *Detector) DetectDevices() ([]Device, error) {
	// Build PowerShell command - call sd-write.ps1 with -AsJson
	args := []string{
		"-NoProfile",
		"-ExecutionPolicy", "Bypass",
		"-File", d.scriptPath,
		"-AsJson",
	}

	cmd := exec.Command("powershell.exe", args...)

	// Execute command and capture output
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to execute PowerShell: %w", err)
	}

	// Parse JSON output
	var devices []Device
	if err := json.Unmarshal(output, &devices); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %w", err)
	}

	return devices, nil
}

// DetectDevicesSync synchronously detects devices
// This is a convenience wrapper that calls DetectDevices
func DetectDevicesSync() ([]Device, error) {
	d := NewDetector()
	return d.DetectDevices()
}
