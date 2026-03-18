// Package disk provides disk image writing functionality for SD cards
package disk

import (
	"errors"
	"fmt"
	"io"
	"os"
	"time"
)

const (
	MinBlockSize     = 512             // 512 bytes
	MaxBlockSize     = 16 * 1024 * 1024 // 16MB
	DefaultBlockSize = 1024 * 1024     // 1MB
	MaxDiskNumber    = 99
)

var (
	ErrEmptyImagePath    = errors.New("image path cannot be empty")
	ErrInvalidDiskNumber = errors.New("disk number must be between 0 and 99")
	ErrInvalidBlockSize  = errors.New("block size must be between 512 and 16MB")
	ErrFileNotFound      = errors.New("image file not found")
	ErrWriteFailed       = errors.New("disk write failed")
)

// Writer handles writing disk images to physical drives
type Writer struct {
	ImagePath  string
	DiskNumber int
	BlockSize  int64
	OnProgress func(current, total int64)
}

// NewWriter creates a new Writer instance with default block size
func NewWriter(imagePath string, diskNumber int, blockSize int64) *Writer {
	if blockSize == 0 {
		blockSize = DefaultBlockSize
	}

	return &Writer{
		ImagePath:  imagePath,
		DiskNumber: diskNumber,
		BlockSize:  blockSize,
	}
}

// Validate validates the writer configuration
func (w *Writer) Validate() error {
	if w.ImagePath == "" {
		return ErrEmptyImagePath
	}

	if w.DiskNumber < 0 || w.DiskNumber > MaxDiskNumber {
		return ErrInvalidDiskNumber
	}

	if w.BlockSize < MinBlockSize || w.BlockSize > MaxBlockSize {
		return ErrInvalidBlockSize
	}

	return nil
}

// GetImageSize returns the size of the image file in bytes
func (w *Writer) GetImageSize() (int64, error) {
	info, err := os.Stat(w.ImagePath)
	if err != nil {
		if os.IsNotExist(err) {
			return 0, ErrFileNotFound
		}
		return 0, fmt.Errorf("failed to get file info: %w", err)
	}

	return info.Size(), nil
}

// OpenImage opens the image file for reading
func (w *Writer) OpenImage() (*os.File, error) {
	return os.Open(w.ImagePath)
}

// OpenDisk opens the physical disk for writing
func (w *Writer) OpenDisk() (*os.File, error) {
	diskPath := fmt.Sprintf(`\\.\PhysicalDrive%d`, w.DiskNumber)
	return os.OpenFile(diskPath, os.O_WRONLY, 0)
}

// Write writes the image to the physical disk
func (w *Writer) Write() error {
	// Validate configuration
	if err := w.Validate(); err != nil {
		return fmt.Errorf("validation failed: %w", err)
	}

	// Get image size
	imageSize, err := w.GetImageSize()
	if err != nil {
		return fmt.Errorf("failed to get image size: %w", err)
	}

	// Open image file
	imageFile, err := w.OpenImage()
	if err != nil {
		return fmt.Errorf("failed to open image: %w", err)
	}
	defer imageFile.Close()

	// Open physical disk
	diskFile, err := w.OpenDisk()
	if err != nil {
		return fmt.Errorf("failed to open disk: %w", err)
	}
	defer diskFile.Close()

	// Perform write operation
	return w.writeBuffered(imageFile, diskFile, imageSize)
}

// writeBuffered writes data using buffered I/O
func (w *Writer) writeBuffered(image, disk *os.File, size int64) error {
	buffer := make([]byte, w.BlockSize)
	var written int64
	startTime := time.Now()

	// Progress tracking
	if w.OnProgress != nil {
		w.OnProgress(0, size)
	}

	for {
		// Read from image
		n, err := image.Read(buffer)
		if n == 0 {
			if err == io.EOF {
				break
			}
			if err != nil {
				return fmt.Errorf("read error: %w", err)
			}
		}

		// Write to disk
		if _, err := disk.Write(buffer[:n]); err != nil {
			return fmt.Errorf("write error: %w", err)
		}

		written += int64(n)

		// Update progress
		if w.OnProgress != nil {
			w.OnProgress(written, size)
		}
	}

	// Sync to ensure data is written
	if err := disk.Sync(); err != nil {
		return fmt.Errorf("sync error: %w", err)
	}

	// Log completion
	w.logCompletion(written, startTime)

	return nil
}

// logCompletion logs write completion statistics
func (w *Writer) logCompletion(bytesWritten int64, startTime time.Time) {
	elapsed := time.Since(startTime)
	mbWritten := float64(bytesWritten) / (1024 * 1024)
	mbPerSec := mbWritten / elapsed.Seconds()

	// Note: This would normally use a proper logger
	// For now, we just return silently
	_ = mbPerSec
}

// WriteResult contains statistics about a write operation
type WriteResult struct {
	BytesWritten int64
	Duration     time.Duration
	SpeedMBps    float64
}

// WriteWithStats writes the image and returns statistics
func (w *Writer) WriteWithStats() (*WriteResult, error) {
	if err := w.Validate(); err != nil {
		return nil, fmt.Errorf("validation failed: %w", err)
	}

	imageSize, err := w.GetImageSize()
	if err != nil {
		return nil, fmt.Errorf("failed to get image size: %w", err)
	}

	imageFile, err := w.OpenImage()
	if err != nil {
		return nil, fmt.Errorf("failed to open image: %w", err)
	}
	defer imageFile.Close()

	diskFile, err := w.OpenDisk()
	if err != nil {
		return nil, fmt.Errorf("failed to open disk: %w", err)
	}
	defer diskFile.Close()

	return w.writeBufferedWithStats(imageFile, diskFile, imageSize)
}

// writeBufferedWithStats writes data and returns statistics
func (w *Writer) writeBufferedWithStats(image, disk *os.File, size int64) (*WriteResult, error) {
	buffer := make([]byte, w.BlockSize)
	var written int64
	startTime := time.Now()

	if w.OnProgress != nil {
		w.OnProgress(0, size)
	}

	for {
		n, err := image.Read(buffer)
		if n == 0 {
			if err == io.EOF {
				break
			}
			if err != nil {
				return nil, fmt.Errorf("read error: %w", err)
			}
		}

		if _, err := disk.Write(buffer[:n]); err != nil {
			return nil, fmt.Errorf("write error: %w", err)
		}

		written += int64(n)

		if w.OnProgress != nil {
			w.OnProgress(written, size)
		}
	}

	if err := disk.Sync(); err != nil {
		return nil, fmt.Errorf("sync error: %w", err)
	}

	elapsed := time.Since(startTime)
	mbWritten := float64(written) / (1024 * 1024)
	mbPerSec := mbWritten / elapsed.Seconds()

	return &WriteResult{
		BytesWritten: written,
		Duration:     elapsed,
		SpeedMBps:    mbPerSec,
	}, nil
}
