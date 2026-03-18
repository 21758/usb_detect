#!/bin/bash
# Test core packages (excluding GUI which requires CGO)

echo "Testing core packages..."
go test ./pkg/devices ./pkg/disk ./pkg/progress -v
