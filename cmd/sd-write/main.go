// Package main provides the CLI for SD card image writing
package main

import (
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/sd-detect/pkg/disk"
	"github.com/sd-detect/pkg/progress"
)

// Options contains command-line options
type Options struct {
	ImagePath string
	DiskNumber int
	BlockSize int64
	Verify bool
	List bool
}

func main() {
	opts := parseFlags()

	if opts.List {
		listDevices()
		return
	}

	if err := validateOptions(opts); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	if err := writeImage(opts); err != nil {
		fmt.Fprintf(os.Stderr, "Write failed: %v\n", err)
		os.Exit(1)
	}
}

// parseFlags parses command-line flags
func parseFlags() *Options {
	opts := &Options{}

	flag.StringVar(&opts.ImagePath, "image", "", "Path to image file")
	flag.IntVar(&opts.DiskNumber, "disk", 0, "Target disk number (0-99)")
	flag.Int64Var(&opts.BlockSize, "bs", 1024*1024, "Block size in bytes")
	flag.BoolVar(&opts.Verify, "verify", false, "Verify after write")
	flag.BoolVar(&opts.List, "list", false, "List available devices")
	flag.Parse()

	return opts
}

// validateOptions validates the options
func validateOptions(opts *Options) error {
	if opts.ImagePath == "" {
		return fmt.Errorf("image path is required")
	}

	if opts.DiskNumber < 0 || opts.DiskNumber > 99 {
		return fmt.Errorf("disk number must be between 0 and 99")
	}

	return nil
}

// writeImage writes the image to disk
func writeImage(opts *Options) error {
	// Create writer
	writer := disk.NewWriter(opts.ImagePath, opts.DiskNumber, opts.BlockSize)

	// Validate configuration
	if err := writer.Validate(); err != nil {
		return fmt.Errorf("validation failed: %w", err)
	}

	// Get image size
	imageSize, err := writer.GetImageSize()
	if err != nil {
		return fmt.Errorf("failed to get image size: %w", err)
	}

	fmt.Printf("Image: %s\n", opts.ImagePath)
	fmt.Printf("Size: %.2f MB\n", float64(imageSize)/(1024*1024))
	fmt.Printf("Disk: PhysicalDrive%d\n", opts.DiskNumber)
	fmt.Printf("Block size: %d bytes\n\n", opts.BlockSize)

	// Create progress bar
	bar := progress.NewBar(imageSize)
	defer bar.Finish()

	// Set progress callback
	writer.OnProgress = func(current, total int64) {
		bar.Update(current)
	}

	// Write with statistics
	result, err := writer.WriteWithStats()
	if err != nil {
		return err
	}

	// Print completion message
	fmt.Printf("\n✓ Write complete!\n")
	fmt.Printf("  Size: %.2f MB\n", float64(result.BytesWritten)/(1024*1024))
	fmt.Printf("  Time: %s\n", result.Duration.Round(time.Millisecond))
	fmt.Printf("  Speed: %.2f MB/s\n", result.SpeedMBps)

	if opts.Verify {
		fmt.Println("\nVerifying...")
		// TODO: Implement verification
	}

	return nil
}

// listDevices lists available devices
func listDevices() {
	fmt.Println("Please use PowerShell script for device detection:")
	fmt.Println("  .\\scripts\\sd-detect.ps1")
	fmt.Println("\nOr:")
	fmt.Println("  .\\scripts\\sd-write.ps1 -List")
}
