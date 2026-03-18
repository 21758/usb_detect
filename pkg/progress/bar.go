// Package progress provides progress bar functionality for console output
package progress

import (
	"fmt"
	"strings"
	"time"
)

// Bar represents a progress bar
type Bar struct {
	Total     int64
	Current   int64
	StartTime time.Time
	Width     int
}

// NewBar creates a new progress bar
func NewBar(total int64) *Bar {
	return &Bar{
		Total:     total,
		StartTime: time.Now(),
		Width:     40,
	}
}

// Update updates the current progress and redraws the bar
func (b *Bar) Update(current int64) {
	b.Current = current
	b.render()
}

// Increment adds to the current progress
func (b *Bar) Increment(delta int64) {
	b.Current += delta
	b.render()
}

// render draws the progress bar
func (b *Bar) render() {
	if b.Total <= 0 {
		return
	}

	percent := float64(b.Current) / float64(b.Total) * 100
	elapsed := time.Since(b.StartTime).Seconds()

	var eta string
	if percent > 0 && b.Current < b.Total {
		etaSeconds := elapsed / percent * (100 - percent)
		eta = fmt.Sprintf(" ETA: %s", formatDuration(time.Duration(etaSeconds)*time.Second))
	}

	// Calculate bar width
	filled := int(percent / 100 * float64(b.Width))
	if filled > b.Width {
		filled = b.Width
	}

	bar := strings.Repeat("█", filled) + strings.Repeat("░", b.Width-filled)

	// Format sizes
	currentMB := float64(b.Current) / (1024 * 1024)
	totalMB := float64(b.Total) / (1024 * 1024)

	fmt.Printf("\r[%s] %.1f%% (%.2f / %.2f MB)%s",
		bar, percent,
		currentMB, totalMB,
		eta)
}

// Finish completes the progress bar
func (b *Bar) Finish() {
	// Ensure final 100% is shown
	b.Current = b.Total
	b.render()
	fmt.Println() // Move to next line
}

// String returns a string representation of current progress
func (b *Bar) String() string {
	if b.Total <= 0 {
		return "0/0 (0%)"
	}

	percent := float64(b.Current) / float64(b.Total) * 100
	return fmt.Sprintf("%.1f%% (%d/%d bytes)", percent, b.Current, b.Total)
}

// formatDuration formats a duration in a human-readable way
func formatDuration(d time.Duration) string {
	if d < time.Minute {
		return fmt.Sprintf("%ds", int(d.Seconds()))
	} else if d < time.Hour {
		return fmt.Sprintf("%dm %ds", int(d.Minutes())%60, int(d.Seconds())%60)
	} else {
		return fmt.Sprintf("%dh %dm", int(d.Hours()), int(d.Minutes())%60)
	}
}

// SpeedCalculator calculates transfer speed
type SpeedCalculator struct {
	startTime   time.Time
	lastUpdate  time.Time
	lastBytes   int64
	totalBytes  int64
	smoothSpeed float64 // Exponentially smoothed speed
	alpha       float64 // Smoothing factor (0-1)
}

// NewSpeedCalculator creates a new speed calculator
func NewSpeedCalculator() *SpeedCalculator {
	return &SpeedCalculator{
		startTime:  time.Now(),
		lastUpdate: time.Now(),
		alpha:      0.1, // Smoothing factor
	}
}

// Update updates the speed calculation with new data
func (s *SpeedCalculator) Update(bytesWritten int64) {
	now := time.Now()
	deltaTime := now.Sub(s.lastUpdate).Seconds()
	deltaBytes := bytesWritten - s.lastBytes

	s.totalBytes = bytesWritten
	s.lastBytes = bytesWritten
	s.lastUpdate = now

	// Calculate instant speed
	instantSpeed := float64(deltaBytes) / (1024 * 1024) / deltaTime

	// Apply exponential smoothing
	if s.smoothSpeed == 0 {
		s.smoothSpeed = instantSpeed
	} else {
		s.smoothSpeed = s.alpha*instantSpeed + (1-s.alpha)*s.smoothSpeed
	}
}

// GetSpeedMBps returns the current speed in MB/s
func (s *SpeedCalculator) GetSpeedMBps() float64 {
	return s.smoothSpeed
}

// GetAverageSpeedMBps returns the average speed since start
func (s *SpeedCalculator) GetAverageSpeedMBps() float64 {
	elapsed := time.Since(s.startTime).Seconds()
	if elapsed == 0 {
		return 0
	}
	return float64(s.totalBytes) / (1024 * 1024) / elapsed
}

// GetElapsed returns elapsed time
func (s *SpeedCalculator) GetElapsed() time.Duration {
	return time.Since(s.startTime)
}

// GetETA returns estimated time to completion
func (s *SpeedCalculator) GetETA(remainingBytes int64) time.Duration {
	if s.smoothSpeed == 0 {
		return 0
	}

	secondsRemaining := float64(remainingBytes) / (1024 * 1024) / s.smoothSpeed
	return time.Duration(secondsRemaining) * time.Second
}
