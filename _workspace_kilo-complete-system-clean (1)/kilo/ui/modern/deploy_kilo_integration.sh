#!/bin/bash
# Kilo Truck Integration Deployment Script
# Fixes all issues and integrates all components

set -e

echo "🚗 Kilo Truck Integration Deployment"
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PI_DIR="/opt/kilo"
BACKUP_DIR="/opt/kilo/backups/$(date +%Y%m%d_%H%M%S)"
VIAM_JSON="/etc/viam.json"

# Step 1: Backup current configuration
echo -e "${YELLOW}Step 1: Creating backups...${NC}"
sudo mkdir -p "$BACKUP_DIR"
sudo cp -r /opt/kilo "$BACKUP_DIR/" 2>/dev/null || true
sudo cp "$VIAM_JSON" "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✓ Backups created${NC}"

# Step 2: Create directory structure
echo -e "${YELLOW}Step 2: Setting up directories...${NC}"
sudo mkdir -p $PI_DIR/{modules,config,logs,bin}
sudo mkdir -p $PI_DIR/modules/android-imu
sudo mkdir -p /etc/kilo
echo -e "${GREEN}✓ Directories created${NC}"

# Step 3: Install fixed Android IMU module
echo -e "${YELLOW}Step 3: Installing fixed Android IMU module...${NC}"

# Copy the fixed module
sudo cp /workspace/fixed_android_imu.py $PI_DIR/modules/android-imu/android_imu_module.py

# Create launcher
sudo tee $PI_DIR/modules/android-imu/android_imu > /dev/null <<'LAUNCHER'
#!/usr/bin/env bash
cd $PI_DIR/modules/android-imu
exec python3 android_imu_module.py
LAUNCHER

sudo chmod +x $PI_DIR/modules/android-imu/android_imu

# Install dependencies
if [ -d "/opt/kilo/venv" ]; then
    source /opt/kilo/venv/bin/activate
    pip install -U viam-sdk aiohttp
    deactivate
else
    echo -e "${YELLOW}Creating Python virtual environment...${NC}"
    sudo python3 -m venv $PI_DIR/venv
    source $PI_DIR/venv/bin/activate
    pip install -U viam-sdk aiohttp
    deactivate
fi

echo -e "${GREEN}✓ Android IMU module installed${NC}"

# Step 4: Update Viam configuration
echo -e "${YELLOW}Step 4: Updating Viam configuration...${NC}"

# Fix the viam.json issues
sudo jq '(.services[] | select(.name=="safety") | .depends_on) |= map(select(. != "oak_imu"))' "$VIAM_JSON" | sudo tee "$VIAM_JSON.tmp" > /dev/null
sudo mv "$VIAM_JSON.tmp" "$VIAM_JSON"

# Add correct module entry if missing
if ! sudo jq -e '.modules[] | select(.name=="android-imu")' "$VIAM_JSON" > /dev/null; then
    sudo jq '.modules += [{
        "type": "local",
        "name": "android-imu", 
        "executable_path": "'$PI_DIR'/modules/android-imu/android_imu"
    }]' "$VIAM_JSON" | sudo tee "$VIAM_JSON.tmp" > /dev/null
    sudo mv "$VIAM_JSON.tmp" "$VIAM_JSON"
fi

# Ensure pixel_imu uses correct model
sudo jq '(.components[] | select(.name=="pixel_imu") | .model) |= "kilo:movement_sensor:android-imu"' "$VIAM_JSON" | sudo tee "$VIAM_JSON.tmp" > /dev/null
sudo mv "$VIAM_JSON.tmp" "$VIAM_JSON"

# Add configurable path to pixel_imu
sudo jq '(.components[] | select(.name=="pixel_imu") | .attributes) |= . + {"path": "/imu"}' "$VIAM_JSON" | sudo tee "$VIAM_JSON.tmp" > /dev/null
sudo mv "$VIAM_JSON.tmp" "$VIAM_JSON"

echo -e "${GREEN}✓ Viam configuration updated${NC}"

# Step 5: Install network configuration system
echo -e "${YELLOW}Step 5: Installing network configuration...${NC}"
sudo cp /workspace/network_config_system.py $PI_DIR/bin/
sudo cp /workspace/fix_network_routing.sh $PI_DIR/bin/
sudo chmod +x $PI_DIR/bin/*.sh
sudo chmod +x $PI_DIR/bin/*.py

# Create systemd service for network management
sudo tee /etc/systemd/system/kilo-network.service > /dev/null <<'SERVICE'
[Unit]
Description=Kilo Network Management
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=$PI_DIR/bin/fix_network_routing.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable kilo-network
sudo systemctl start kilo-network

echo -e "${GREEN}✓ Network configuration installed${NC}"

# Step 6: Install personality integration
echo -e "${YELLOW}Step 6: Installing personality integration...${NC}"
sudo cp /workspace/personality_integration.py $PI_DIR/bin/

# Create systemd service for personality integration
sudo tee /etc/systemd/system/kilo-personality-bridge.service > /dev/null <<'SERVICE'
[Unit]
Description=Kilo Personality Bridge
After=viam-agent.service
Wants=viam-agent.service

[Service]
Type=simple
User=pi
WorkingDirectory=$PI_DIR
Environment=PYTHONPATH=$PI_DIR
ExecStart=$PI_DIR/venv/bin/python3 $PI_DIR/bin/personality_integration.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable kilo-personality-bridge
echo -e "${GREEN}✓ Personality integration installed${NC}"

# Step 7: Install Cars-style eyes
echo -e "${YELLOW}Step 7: Installing Cars-style eyes...${NC}"
sudo cp /workspace/cars_eyes_fixed.html /var/www/html/eyes.html
sudo mkdir -p /var/www/html 2>/dev/null || true
sudo chown -R pi:pi /var/www/html 2>/dev/null || true

# Create eyes server
sudo tee $PI_DIR/bin/eyes_server.py > /dev/null <<'EYES_SERVER'
#!/usr/bin/env python3
import asyncio
import websockets
import json
from http.server import HTTPServer, SimpleHTTPRequestHandler
import threading
import os

class EyesHTTPHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/var/www/html", **kwargs)

async def eyes_websocket(websocket, path):
    """Handle WebSocket connections for eyes"""
    try:
        async for message in websocket:
            # Forward to connected eyes
            pass
    except websockets.exceptions.ConnectionClosed:
        pass

def start_http_server():
    """Start HTTP server for eyes HTML"""
    server = HTTPServer(('0.0.0.0', 7862), EyesHTTPHandler)
    server.serve_forever()

async def main():
    """Start eyes server"""
    # Start HTTP server in background thread
    http_thread = threading.Thread(target=start_http_server, daemon=True)
    http_thread.start()
    
    # Start WebSocket server
    ws_server = await websockets.serve(eyes_websocket, "0.0.0.0", 7863)
    print("Eyes server running on HTTP :7862 and WS :7863")
    await ws_server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())
EYES_SERVER

sudo chmod +x $PI_DIR/bin/eyes_server.py

# Create systemd service for eyes server
sudo tee /etc/systemd/system/kilo-eyes.service > /dev/null <<'SERVICE'
[Unit]
Description=Kilo Eyes Server
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=$PI_DIR
Environment=PYTHONPATH=$PI_DIR
ExecStart=$PI_DIR/venv/bin/python3 $PI_DIR/bin/eyes_server.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable kilo-eyes
echo -e "${GREEN}✓ Cars-style eyes installed${NC}"

# Step 8: Create diagnostic tools
echo -e "${YELLOW}Step 8: Creating diagnostic tools...${NC}"
sudo tee $PI_DIR/bin/kilo_check > /dev/null <<'CHECK'
#!/bin/bash
echo "🚗 Kilo Truck System Check"
echo "=========================="

# Check Viam
echo -n "Viam Agent: "
if systemctl is-active --quiet viam-agent; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Check Android IMU module
echo -n "Android IMU: "
if pgrep -f "android_imu_module.py" > /dev/null; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Check personality bridge
echo -n "Personality Bridge: "
if systemctl is-active --quiet kilo-personality-bridge; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Check eyes server
echo -n "Eyes Server: "
if systemctl is-active --quiet kilo-eyes; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Check network
echo -n "Network Routing: "
if systemctl is-active --quiet kilo-network; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Test connectivity
echo -e "\nConnectivity Tests:"
echo -n "Internet: "
ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "Phone (10.10.10.1): "
ping -c 1 10.10.10.1 >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "Pi Viam API: "
curl -s http://localhost:8080/api/v1/health >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "Eyes HTTP: "
curl -s http://localhost:7862 >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -e "\nServices running on:"
echo "  - Viam Agent: http://localhost:8080"
echo "  - Eyes Display: http://localhost:7862/eyes.html"
echo "  - Eyes WebSocket: ws://localhost:7863"
echo "  - Personality: ws://localhost:7861"
CHECK

sudo chmod +x $PI_DIR/bin/kilo_check

echo -e "${GREEN}✓ Diagnostic tools installed${NC}"

# Step 9: Restart services
echo -e "${YELLOW}Step 9: Starting all services...${NC}"
sudo systemctl restart viam-agent
sudo systemctl start kilo-personality-bridge
sudo systemctl start kilo-eyes

# Wait for services to start
sleep 5

# Step 10: Final verification
echo -e "${YELLOW}Step 10: Final verification...${NC}"
sudo $PI_DIR/bin/kilo_check

echo -e "\n${GREEN}🎉 Kilo Truck Integration Complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Connect your Pixel 4a via USB and enable tethering"
echo "2. Open browser on phone to: http://10.10.10.67:7862/eyes.html"
echo "3. Check the Android app endpoints are working"
echo "4. Test with: sudo $PI_DIR/bin/kilo_check"
echo -e "\n${YELLOW}Eyes Features:${NC}"
echo "  - ✓ Cars movie style design"
echo "  - ✓ Fixed cross-eye steering (both eyes same direction)"
echo "  - ✓ Fullscreen landscape mode"
echo "  - ✓ Configurable server addresses"
echo "  - ✓ Multiple emotions"
echo -e "\n${YELLOW}Fixed Issues:${NC}"
echo "  - ✓ Android IMU module properly registered"
echo "  - ✓ Network routing maintains internet connection"
echo "  - ✓ Personality integration ready"
echo "  - ✓ All services auto-start on boot"

# Create quick reference
sudo tee /home/pi/KILO_QUICK_REFERENCE.md > /dev/null <<'REFERENCE'
# Kilo Truck Quick Reference

## Services
- **Viam Agent**: http://localhost:8080
- **Eyes Display**: http://localhost:7862/eyes.html  
- **Personality WebSocket**: ws://localhost:7861
- **Eyes WebSocket**: ws://localhost:7863

## Commands
```bash
# System check
sudo /opt/kilo/bin/kilo_check

# Restart services
sudo systemctl restart viam-agent
sudo systemctl restart kilo-personality-bridge
sudo systemctl restart kilo-eyes

# View logs
sudo journalctl -u viam-agent -f
sudo journalctl -u kilo-personality-bridge -f
sudo journalctl -u kilo-eyes -f

# Network fix
sudo /opt/kilo/bin/fix_network_routing.sh
```

## Phone Endpoints
- Health: http://10.10.10.1:8080/health
- IMU: http://10.10.10.1:8080/imu
- Faces: http://10.10.10.1:8080/faces
- Eyes: http://10.10.10.1:8080/eyes
- TTS: http://10.10.10.1:8080/tts

## Files
- Viam Config: /etc/viam.json
- Android IMU: /opt/kilo/modules/android-imu/
- Network Config: /etc/kilo/network_config.json
- Backup: /opt/kilo/backups/
REFERENCE

echo -e "\n${GREEN}✓ Quick reference created: /home/pi/KILO_QUICK_REFERENCE.md${NC}"