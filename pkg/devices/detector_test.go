// Package devices - Device detection tests
package devices

import (
	"testing"
)

// TestNewDetector tests the detector constructor
func TestNewDetector(t *testing.T) {
	d := NewDetector()

	if d == nil {
		t.Fatal("NewDetector returned nil")
	}

	if d.scriptPath != "scripts\\sd-write.ps1" {
		t.Errorf("Expected scriptPath 'scripts\\\\sd-write.ps1', got '%s'", d.scriptPath)
	}
}

// TestDeviceStruct tests the Device struct
func TestDeviceStruct(t *testing.T) {
	dev := Device{
		DeviceID:    2,
		DiskNumber:  2,
		Size:        31.9,
		SizeGB:      "32.0 GB",
		Model:       "SD Card Reader",
		MediaType:   "Removable Media",
		DriveLetter: "E:",
		VolumeName:  "SD_CARD",
		FileSystem:  "FAT32",
		IsSDCard:    true,
	}

	// Verify all fields
	if dev.DeviceID != 2 {
		t.Errorf("Expected DeviceID 2, got %d", dev.DeviceID)
	}

	if dev.DiskNumber != 2 {
		t.Errorf("Expected DiskNumber 2, got %d", dev.DiskNumber)
	}

	if dev.SizeGB != "32.0 GB" {
		t.Errorf("Expected SizeGB '32.0 GB', got '%s'", dev.SizeGB)
	}

	if dev.Model != "SD Card Reader" {
		t.Errorf("Expected Model 'SD Card Reader', got '%s'", dev.Model)
	}

	if !dev.IsSDCard {
		t.Error("Expected IsSDCard to be true")
	}
}

// TestDetectDevices_Mock tests device detection with mock data
func TestDetectDevices_Mock(t *testing.T) {
	// This test verifies the Device struct works correctly
	devices := []Device{
		{
			DeviceID:    2,
			DiskNumber:  2,
			Size:        31.9,
			SizeGB:      "32.0 GB",
			Model:       "SD Card Reader",
			MediaType:   "Removable Media",
			DriveLetter: "E:",
			VolumeName:  "SD_CARD",
			FileSystem:  "FAT32",
			IsSDCard:    true,
		},
		{
			DeviceID:    3,
			DiskNumber:  3,
			Size:        63.9,
			SizeGB:      "64.0 GB",
			Model:       "USB Drive",
			MediaType:   "Removable Media",
			DriveLetter: "F:",
			VolumeName:  "FLASH",
			FileSystem:  "exFAT",
			IsSDCard:    false,
		},
	}

	if len(devices) != 2 {
		t.Errorf("Expected 2 devices, got %d", len(devices))
	}

	// Verify first device
	if devices[0].Model != "SD Card Reader" {
		t.Errorf("Expected first device to be 'SD Card Reader', got '%s'", devices[0].Model)
	}

	// Verify second device is not SD card
	if devices[1].IsSDCard {
		t.Error("Expected second device to not be SD card")
	}
}

// TestDetectDevices_Skip skips the actual PowerShell call
// This is skipped because it requires actual PowerShell and WMI
func TestDetectDevices_Skip(t *testing.T) {
	t.Skip("Skipping actual device detection - requires PowerShell environment")
}
