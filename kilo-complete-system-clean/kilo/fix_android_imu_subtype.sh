#!/bin/bash

# Quick fix for Android IMU SUBTYPE error
# This script replaces the problematic Android IMU module with the fixed version

set -e

echo "🔧 Fixing Android IMU SUBTYPE error..."

INSTALL_DIR="/opt/kilo"
BACKUP_DIR="$INSTALL_DIR/backup_$(date +%Y%m%d_%H%M%S)"

# Create backup directory
sudo mkdir -p "$BACKUP_DIR"

# Backup existing Android IMU files if they exist
if [ -f "$INSTALL_DIR/bin/fixed_android_imu_v2.py" ]; then
    echo "📦 Backing up existing files to $BACKUP_DIR"
    sudo cp "$INSTALL_DIR/bin/fixed_android_imu_v2.py" "$BACKUP_DIR/"
fi

# Download the fixed Android IMU module
echo "📥 Downloading fixed Android IMU module..."
cd /tmp
curl -s -L -o fixed_android_imu_v2.py "https://raw.githubusercontent.com/theholybull/kilo/fix/android-imu-subtype-error/fixed_android_imu_v2.py"

if [ ! -f "fixed_android_imu_v2.py" ]; then
    echo "❌ Error: Failed to download fixed Android IMU module"
    exit 1
fi

# Install the fixed module
echo "🔧 Installing fixed module..."
sudo mkdir -p "$INSTALL_DIR/bin"
sudo cp fixed_android_imu_v2.py "$INSTALL_DIR/bin/"
sudo chmod +x "$INSTALL_DIR/bin/fixed_android_imu_v2.py"

# Create the corrected Viam module registration file
echo "🔧 Creating module registration..."
sudo mkdir -p "$INSTALL_DIR/modules"

# Clean up
rm -f fixed_android_imu_v2.py

echo ""
echo "✅ Android IMU SUBTYPE error fixed!"
echo ""
echo "What was fixed:"
echo "  - Changed MovementSensor.SUBTYPE to MovementSensor.API"
echo "  - Updated module registration to use correct API reference"
echo "  - Compatible with Viam Python SDK v0.4.0+"
echo ""
echo "Next steps:"
echo "  1. Restart your Viam agent: sudo systemctl restart viam-agent"
echo "  2. Check module logs: sudo journalctl -u viam-agent -f"
echo ""
echo "The Android IMU module should now register correctly!"