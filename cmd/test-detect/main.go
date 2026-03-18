// Test device detection
package main

import (
	"encoding/json"
	"fmt"
	"log"

	"github.com/sd-detect/pkg/devices"
)

func main() {
	fmt.Println("=== Device Detection Test ===")
	fmt.Println()

	devices, err := devices.DetectDevicesSync()
	if err != nil {
		log.Fatalf("Error detecting devices: %v", err)
	}

	if len(devices) == 0 {
		fmt.Println("No devices detected")
		return
	}

	fmt.Printf("Found %d device(s):\n\n", len(devices))

	for i, dev := range devices {
		fmt.Printf("[%d] Device ID: %d\n", i+1, dev.DeviceID)
		fmt.Printf("    Disk Number: %d\n", dev.DiskNumber)
		fmt.Printf("    Size: %.2f GB (%s)\n", dev.Size, dev.SizeGB)
		fmt.Printf("    Model: %s\n", dev.Model)
		fmt.Printf("    Media Type: %s\n", dev.MediaType)
		if dev.DriveLetter != "" {
			fmt.Printf("    Drive Letter: %s\n", dev.DriveLetter)
		}
		if dev.VolumeName != "" {
			fmt.Printf("    Volume Name: %s\n", dev.VolumeName)
		}
		if dev.FileSystem != "" {
			fmt.Printf("    File System: %s\n", dev.FileSystem)
		}
		fmt.Printf("    Is SD Card: %v\n", dev.IsSDCard)
		fmt.Println()
	}

	// Test JSON output
	fmt.Println("=== JSON Output ===")
	jsonData, _ := json.MarshalIndent(devices, "", "  ")
	fmt.Println(string(jsonData))
}
