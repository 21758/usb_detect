package disk

import (
	"os"
	"testing"
	"time"
)

// TestNewWriter tests the NewWriter constructor
func TestNewWriter(t *testing.T) {
	w := NewWriter("test.img", 2, 1024*1024)

	if w == nil {
		t.Fatal("NewWriter returned nil")
	}

	if w.ImagePath != "test.img" {
		t.Errorf("Expected ImagePath 'test.img', got '%s'", w.ImagePath)
	}

	if w.DiskNumber != 2 {
		t.Errorf("Expected DiskNumber 2, got %d", w.DiskNumber)
	}

	if w.BlockSize != 1024*1024 {
		t.Errorf("Expected BlockSize 1048576, got %d", w.BlockSize)
	}
}

// TestNewWriter_DefaultBlockSize tests default block size
func TestNewWriter_DefaultBlockSize(t *testing.T) {
	w := NewWriter("test.img", 2, 0)

	if w.BlockSize != DefaultBlockSize {
		t.Errorf("Expected default BlockSize %d, got %d", DefaultBlockSize, w.BlockSize)
	}
}

// TestWriterValidate tests configuration validation
func TestWriterValidate(t *testing.T) {
	tests := []struct {
		name      string
		writer    *Writer
		wantError error
	}{
		{
			name: "valid configuration",
			writer: &Writer{
				ImagePath:  "test.img",
				DiskNumber: 1,
				BlockSize:  1024 * 1024,
			},
			wantError: nil,
		},
		{
			name: "empty image path",
			writer: &Writer{
				ImagePath:  "",
				DiskNumber: 1,
				BlockSize:  1024 * 1024,
			},
			wantError: ErrEmptyImagePath,
		},
		{
			name: "invalid disk number (negative)",
			writer: &Writer{
				ImagePath:  "test.img",
				DiskNumber: -1,
				BlockSize:  1024 * 1024,
			},
			wantError: ErrInvalidDiskNumber,
		},
		{
			name: "invalid disk number (too large)",
			writer: &Writer{
				ImagePath:  "test.img",
				DiskNumber: 100,
				BlockSize:  1024 * 1024,
			},
			wantError: ErrInvalidDiskNumber,
		},
		{
			name: "invalid block size (zero)",
			writer: &Writer{
				ImagePath:  "test.img",
				DiskNumber: 1,
				BlockSize:  0,
			},
			wantError: ErrInvalidBlockSize,
		},
		{
			name: "invalid block size (too small)",
			writer: &Writer{
				ImagePath:  "test.img",
				DiskNumber: 1,
				BlockSize:  256,
			},
			wantError: ErrInvalidBlockSize,
		},
		{
			name: "block size too large",
			writer: &Writer{
				ImagePath:  "test.img",
				DiskNumber: 1,
				BlockSize:  100 * 1024 * 1024, // 100MB
			},
			wantError: ErrInvalidBlockSize,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := tt.writer.Validate()
			if err != tt.wantError {
				t.Errorf("Validate() error = %v, wantError %v", err, tt.wantError)
			}
		})
	}
}

// TestGetImageSize tests getting image file size
func TestGetImageSize(t *testing.T) {
	// Create a temporary test file
	tmpFile, err := os.CreateTemp("", "test-*.img")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	defer os.Remove(tmpFile.Name())

	// Write some data
	testData := make([]byte, 1024*1024) // 1MB
	if _, err := tmpFile.Write(testData); err != nil {
		t.Fatalf("Failed to write to temp file: %v", err)
	}
	tmpFile.Close()

	// Test getting size
	w := NewWriter(tmpFile.Name(), 1, 1024*1024)
	size, err := w.GetImageSize()

	if err != nil {
		t.Errorf("GetImageSize() returned error: %v", err)
	}

	if size != 1024*1024 {
		t.Errorf("Expected size 1048576, got %d", size)
	}
}

// TestGetImageSize_FileNotFound tests error handling for missing file
func TestGetImageSize_FileNotFound(t *testing.T) {
	w := NewWriter("nonexistent.img", 1, 1024*1024)
	_, err := w.GetImageSize()

	if err == nil {
		t.Error("Expected error for nonexistent file, got nil")
	}

	if err != ErrFileNotFound {
		t.Errorf("Expected ErrFileNotFound, got %v", err)
	}
}

// TestOpenImage tests opening image file
func TestOpenImage(t *testing.T) {
	// Create temp file
	tmpFile, err := os.CreateTemp("", "test-*.img")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	defer os.Remove(tmpFile.Name())
	tmpFile.Close()

	w := NewWriter(tmpFile.Name(), 1, 1024*1024)
	file, err := w.OpenImage()

	if err != nil {
		t.Errorf("OpenImage() returned error: %v", err)
	}

	if file == nil {
		t.Error("OpenImage() returned nil file")
	} else {
		file.Close()
	}
}

// TestProgressCallback tests progress callback functionality
func TestProgressCallback(t *testing.T) {
	called := false
	var progressCurrent, progressTotal int64

	w := &Writer{
		ImagePath:  "test.img",
		DiskNumber: 1,
		BlockSize:  1024,
		OnProgress: func(current, total int64) {
			called = true
			progressCurrent = current
			progressTotal = total
		},
	}

	// Trigger progress callback
	if w.OnProgress != nil {
		w.OnProgress(512, 1024)
	}

	if !called {
		t.Error("Progress callback was not called")
	}

	if progressCurrent != 512 {
		t.Errorf("Expected current 512, got %d", progressCurrent)
	}

	if progressTotal != 1024 {
		t.Errorf("Expected total 1024, got %d", progressTotal)
	}
}

// TestWriteResult tests WriteResult structure
func TestWriteResult(t *testing.T) {
	result := &WriteResult{
		BytesWritten: 1024 * 1024,
		Duration:     10 * time.Second,
		SpeedMBps:    1.0,
	}

	if result.BytesWritten != 1024*1024 {
		t.Errorf("BytesWriter mismatch")
	}

	if result.Duration != 10*time.Second {
		t.Errorf("Duration mismatch")
	}

	if result.SpeedMBps != 1.0 {
		t.Errorf("SpeedMBps mismatch")
	}
}

// TestConstants tests defined constants
func TestConstants(t *testing.T) {
	if MinBlockSize != 512 {
		t.Errorf("MinBlockSize = %d, want 512", MinBlockSize)
	}

	if MaxBlockSize != 16*1024*1024 {
		t.Errorf("MaxBlockSize = %d, want 16777216", MaxBlockSize)
	}

	if DefaultBlockSize != 1024*1024 {
		t.Errorf("DefaultBlockSize = %d, want 1048576", DefaultBlockSize)
	}

	if MaxDiskNumber != 99 {
		t.Errorf("MaxDiskNumber = %d, want 99", MaxDiskNumber)
	}
}

// BenchmarkNewWriter benchmarks the NewWriter constructor
func BenchmarkNewWriter(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = NewWriter("test.img", 1, 1024*1024)
	}
}

// BenchmarkValidate benchmarks the Validate method
func BenchmarkValidate(b *testing.B) {
	w := NewWriter("test.img", 1, 1024*1024)
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		_ = w.Validate()
	}
}
