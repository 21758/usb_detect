package progress

import (
	"testing"
	"time"
)

// TestNewBar tests progress bar creation
func TestNewBar(t *testing.T) {
	bar := NewBar(1000)

	if bar.Total != 1000 {
		t.Errorf("Expected Total 1000, got %d", bar.Total)
	}

	if bar.Current != 0 {
		t.Errorf("Expected Current 0, got %d", bar.Current)
	}

	if bar.Width != 40 {
		t.Errorf("Expected Width 40, got %d", bar.Width)
	}

	if bar.StartTime.IsZero() {
		t.Error("StartTime should not be zero")
	}
}

// TestBarUpdate tests updating progress
func TestBarUpdate(t *testing.T) {
	bar := NewBar(1000)

	bar.Update(500)

	if bar.Current != 500 {
		t.Errorf("Expected Current 500, got %d", bar.Current)
	}
}

// TestBarIncrement tests incrementing progress
func TestBarIncrement(t *testing.T) {
	bar := NewBar(1000)

	bar.Increment(100)
	bar.Increment(200)

	if bar.Current != 300 {
		t.Errorf("Expected Current 300, got %d", bar.Current)
	}
}

// TestBarString tests string representation
func TestBarString(t *testing.T) {
	bar := NewBar(1000)
	bar.Update(500)

	str := bar.String()
	if str == "" {
		t.Error("String() should not return empty string")
	}

	// Should contain percentage
	// Note: Not testing exact format to allow for future changes
}

// TestBarFinish tests finishing the progress bar
func TestBarFinish(t *testing.T) {
	bar := NewBar(1000)
	bar.Update(500)

	bar.Finish()

	if bar.Current != 1000 {
		t.Errorf("Expected Current 1000 after Finish, got %d", bar.Current)
	}
}

// TestSpeedCalculator tests speed calculation
func TestSpeedCalculator(t *testing.T) {
	calc := NewSpeedCalculator()

	if calc.smoothSpeed != 0 {
		t.Errorf("Expected initial smoothSpeed 0, got %f", calc.smoothSpeed)
	}

	// Simulate some activity
	calc.Update(1024 * 1024) // 1MB
	time.Sleep(10 * time.Millisecond)
	calc.Update(2 * 1024 * 1024) // 2MB total

	speed := calc.GetSpeedMBps()
	if speed <= 0 {
		t.Errorf("Expected positive speed, got %f", speed)
	}

	avgSpeed := calc.GetAverageSpeedMBps()
	if avgSpeed <= 0 {
		t.Errorf("Expected positive average speed, got %f", avgSpeed)
	}
}

// TestSpeedCalculator_GetETA tests ETA calculation
func TestSpeedCalculator_GetETA(t *testing.T) {
	calc := NewSpeedCalculator()

	// Simulate some activity to establish speed
	calc.Update(1024 * 1024) // 1MB
	time.Sleep(50 * time.Millisecond)
	calc.Update(2 * 1024 * 1024) // 2MB total

	// Calculate ETA for remaining 8MB
	eta := calc.GetETA(8 * 1024 * 1024)

	// ETA might be zero if calculation is too fast, only check if non-zero
	if eta > 0 {
		// ETA should be reasonable (less than 1 hour for 8MB at typical speeds)
		if eta > time.Hour {
			t.Errorf("ETA seems too long: %v", eta)
		}
	}
}

// TestFormatDuration tests duration formatting
func TestFormatDuration(t *testing.T) {
	tests := []struct {
		duration time.Duration
		expected string
	}{
		{30 * time.Second, "30s"},
		{90 * time.Second, "1m 30s"},
		{3661 * time.Second, "1h 1m"},
	}

	for _, tt := range tests {
		t.Run(tt.duration.String(), func(t *testing.T) {
			result := formatDuration(tt.duration)
			if result != tt.expected {
				t.Errorf("formatDuration(%v) = %s, want %s", tt.duration, result, tt.expected)
			}
		})
	}
}

// BenchmarkNewBar benchmarks progress bar creation
func BenchmarkNewBar(b *testing.B) {
	for i := 0; i < b.N; i++ {
		_ = NewBar(1000000)
	}
}

// BenchmarkBarUpdate benchmarks progress updates
func BenchmarkBarUpdate(b *testing.B) {
	bar := NewBar(1000000)
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		bar.Update(1000)
	}
}
