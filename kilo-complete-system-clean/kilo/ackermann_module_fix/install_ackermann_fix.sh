#!/bin/bash

# Installation script for fixed ackermann-pwm-base module
# This fixes the import error: "unknown resource type: API rdk:component:movement_sensor..."

set -e

INSTALL_DIR="/opt/kilo"
MODULE_DIR="$INSTALL_DIR/modules/ackermann-pwm-base"
BINARY_DIR="$INSTALL_DIR/bin"

echo "🔧 Installing fixed ackermann-pwm-base module..."

# Create directories
sudo mkdir -p "$MODULE_DIR"
sudo mkdir -p "$BINARY_DIR"

# Extract the archive if provided
if [ -f "ackermann_module_fix.zip" ]; then
    echo "📦 Extracting archive..."
    unzip -q ackermann_module_fix.zip
    
    # Copy binary
    sudo cp ackermann "$BINARY_DIR/"
    sudo chmod +x "$BINARY_DIR/ackermann"
    
    # Copy module source
    sudo cp -r modules/ackermann-pwm-base/* "$MODULE_DIR/"
    sudo chown -R root:root "$MODULE_DIR"
    sudo chown root:root "$BINARY_DIR/ackermann"
    
    echo "✅ Fixed module installed to $MODULE_DIR"
    echo "✅ Binary installed to $BINARY_DIR/ackermann"
else
    echo "❌ Error: ackermann_module_fix.zip not found"
    exit 1
fi

# Create systemd service if it doesn't exist
SERVICE_FILE="/etc/systemd/system/ackermann-module.service"
if [ ! -f "$SERVICE_FILE" ]; then
    echo "🔧 Creating systemd service..."
    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Viam Ackermann PWM Base Module
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$MODULE_DIR
ExecStart=$BINARY_DIR/ackermann
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable ackermann-module
    echo "✅ Systemd service created and enabled"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To start the module:"
echo "  sudo systemctl start ackermann-module"
echo ""
echo "To check status:"
echo "  sudo systemctl status ackermann-module"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u ackermann-module -f"
echo ""
echo "The module is now ready for Viam integration!"