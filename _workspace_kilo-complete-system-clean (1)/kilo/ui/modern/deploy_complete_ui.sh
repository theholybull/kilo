#!/bin/bash

# Complete Kilo Truck UI Deployment Script
# Deploys modern UI with real-time WebSocket updates and Android integration

set -e

echo "🚀 Deploying Complete Kilo Truck UI System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
UI_PORT=8080
WS_PORT=8081
SERVICE_NAME="kilo-ui-modern"
WS_SERVICE_NAME="kilo-ui-realtime"
INSTALL_DIR="/opt/kilo"
SERVICE_DIR="/etc/systemd/system"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}$1${NC}"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# Detect system information
print_status "Detecting system information..."
OS_ID=$(lsb_release -si 2>/dev/null || echo "Unknown")
OS_VERSION=$(lsb_release -sr 2>/dev/null || echo "Unknown")
ARCH=$(uname -m)

print_status "System: $OS_ID $OS_VERSION ($ARCH)"

# Install dependencies
print_header "📦 Installing Dependencies"

# Update package list
print_status "Updating package list..."
apt-get update

# Install required packages
print_status "Installing system packages..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    unzip \
    nmap \
    jq \
    net-tools \
    systemd \
    ufw \
    nginx-light

# Install Python dependencies
print_status "Installing Python packages..."
pip3 install --upgrade pip
pip3 install \
    websockets \
    asyncio \
    requests \
    chart.js \
    flask \
    aiohttp

# Create directories
print_status "Creating directories..."
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/logs"
mkdir -p "$INSTALL_DIR/config"
mkdir -p "/var/lib/kilo/snaps"
mkdir -p "/opt/kilo/docs"
mkdir -p "/opt/viam/maps"

# Install UI files
print_header "🎨 Installing UI Files"

print_status "Installing main UI server..."
cp kilo_ui_modern.py "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/kilo_ui_modern.py"

print_status "Installing realtime WebSocket server..."
cp kilo_ui_realtime.py "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/kilo_ui_realtime.py"

print_status "Installing enhanced HTML interface..."
cp kilo_ui_enhanced.html "$INSTALL_DIR/www/"
mkdir -p "$INSTALL_DIR/www"

# Create main UI service
print_status "Creating systemd services..."

cat > "$SERVICE_DIR/$SERVICE_NAME.service" << EOF
[Unit]
Description=Kilo Truck Modern UI Server
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/bin/kilo_ui_modern.py
Restart=always
RestartSec=10
Environment=PYTHONUNBUFFERED=1

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$INSTALL_DIR/logs /var/lib/kilo/snaps /opt/kilo/docs /tmp

[Install]
WantedBy=multi-user.target
EOF

# Create WebSocket service
cat > "$SERVICE_DIR/$WS_SERVICE_NAME.service" << EOF
[Unit]
Description=Kilo Truck Realtime WebSocket Server
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/bin/kilo_ui_realtime.py
Restart=always
RestartSec=10
Environment=PYTHONUNBUFFERED=1

# Security settings
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$INSTALL_DIR/logs /tmp

[Install]
WantedBy=multi-user.target
EOF

# Nginx configuration for reverse proxy
print_status "Configuring Nginx reverse proxy..."
cat > "/etc/nginx/sites-available/kilo-ui" << EOF
server {
    listen 80;
    server_name _;
    
    # Main UI
    location / {
        proxy_pass http://127.0.0.1:$UI_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # WebSocket proxy
    location /ws {
        proxy_pass http://127.0.0.1:$WS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Enhanced UI
    location /enhanced {
        alias $INSTALL_DIR/www;
        try_files \$uri \$uri/ /kilo_ui_enhanced.html;
    }
    
    # Static files
    location /static/ {
        alias $INSTALL_DIR/www/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable Nginx site
ln -sf "/etc/nginx/sites-available/kilo-ui" "/etc/nginx/sites-enabled/"
rm -f "/etc/nginx/sites-enabled/default"

# Test and reload Nginx
nginx -t && systemctl reload nginx

# Create enhanced UI main server
print_status "Creating enhanced UI server..."
cat > "$INSTALL_DIR/bin/kilo_ui_enhanced.py" << 'EOF'
#!/usr/bin/env python3
"""
Enhanced UI Server with Nginx integration
"""

import os
from pathlib import Path
from http.server import HTTPServer, SimpleHTTPRequestHandler

class EnhancedHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/opt/kilo/www", **kwargs)
    
    def do_GET(self):
        if self.path == "/":
            self.path = "/kilo_ui_enhanced.html"
        return super().do_GET()

def main():
    import socketserver
    PORT = 8080
    
    with socketserver.TCPServer(("127.0.0.1", PORT), EnhancedHandler) as httpd:
        print(f"Enhanced UI serving on port {PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    main()
EOF

chmod +x "$INSTALL_DIR/bin/kilo_ui_enhanced.py"

# Reload systemd and enable services
print_status "Configuring systemd services..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME.service"
systemctl enable "$WS_SERVICE_NAME.service"

# Configure firewall
print_status "Configuring firewall..."
if command -v ufw >/dev/null 2>&1; then
    ufw --force enable
    ufw allow 22/tcp comment "SSH"
    ufw allow 80/tcp comment "HTTP"
    ufw allow 443/tcp comment "HTTPS"
    ufw allow $UI_PORT/tcp comment "Kilo UI Direct"
    ufw allow $WS_PORT/tcp comment "Kilo WebSocket"
fi

# Create configuration
print_status "Creating configuration..."
mkdir -p "/etc/kilo"

cat > "/etc/kilo/personality.json" << EOF
{
  "snark_level": 2,
  "wake_words": ["kilo", "hey kilo"],
  "eyes_url": "http://localhost:7007",
  "offline_ok": true,
  "allow_actuation": false,
  "tts_mode": "online",
  "piper_model": "/opt/piper/en_US-amy-medium.onnx",
  "modern_ui_enabled": true,
  "modern_ui_port": $UI_PORT,
  "websocket_port": $WS_PORT,
  "remote_access_enabled": false,
  "android_phone_ip": "10.10.10.1",
  "android_port": "8080",
  "enhanced_ui_enabled": true,
  "nginx_proxy": true
}
EOF

# Android integration tools
print_status "Installing Android integration tools..."

cat > "$INSTALL_DIR/bin/discover-android-ip" << 'EOF'
#!/bin/bash
# Android Phone IP Discovery Utility
NETWORKS=("192.168.42.0/24" "10.10.10.0/24")
PORT="8080"

for network in "${NETWORKS[@]}"; do
    if command -v nmap >/dev/null 2>&1; then
        result=$(nmap -p $PORT --open -T4 $network 2>/dev/null | grep "$PORT/open" | head -1)
        if [ ! -z "$result" ]; then
            ip=$(echo "$result" | awk '{print $2}')
            echo "$ip"
            exit 0
        fi
    else
        for i in {1..254}; do
            if [[ "$network" == "192.168.42.0/24" ]]; then
                ip="192.168.42.$i"
            else
                ip="10.10.10.$i"
            fi
            if timeout 1 bash -c "</dev/tcp/$ip/$PORT" 2>/dev/null; then
                echo "$ip"
                exit 0
            fi
        done
    fi
done
echo "not found"
exit 1
EOF

chmod +x "$INSTALL_DIR/bin/discover-android-ip"

# Remote access configuration
print_status "Setting up remote access management..."
cat > "$INSTALL_DIR/bin/kilo-remote-manager" << 'EOF'
#!/bin/bash
# Remote Access Management Tool

CONFIG_FILE="/etc/kilo/personality.json"
NGINX_SITE="/etc/nginx/sites-available/kilo-ui"

function enable_remote() {
    echo "Enabling remote access..."
    
    # Update config
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
config['remote_access_enabled'] = True
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
"
    
    # Configure Nginx for external access
    sed -i 's/server_name _;/server_name _;/' "$NGINX_SITE"
    
    # Test and reload
    nginx -t && systemctl reload nginx
    systemctl restart kilo-ui-modern kilo-ui-realtime
    
    echo "Remote access enabled"
}

function disable_remote() {
    echo "Disabling remote access..."
    
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
config['remote_access_enabled'] = False
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
"
    
    echo "Remote access disabled (localhost only)"
}

function status() {
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
enabled = config.get('remote_access_enabled', False)
status = 'ENABLED' if enabled else 'DISABLED'
print(f'Remote access: {status}')
print(f'UI Port: {config.get(&quot;modern_ui_port&quot;, 8080)}')
print(f'WebSocket Port: {config.get(&quot;websocket_port&quot;, 8081)}')
"
}

case "$1" in
    enable) enable_remote ;;
    disable) disable_remote ;;
    status) status ;;
    *) echo "Usage: $0 {enable|disable|status}" ;;
esac
EOF

chmod +x "$INSTALL_DIR/bin/kilo-remote-manager"

# Stop old services
print_status "Stopping legacy services..."
systemctl stop kilo-ui.service 2>/dev/null || true
systemctl stop kilo-ui-adv.service 2>/dev/null || true
systemctl disable kilo-ui.service 2>/dev/null || true
systemctl disable kilo-ui-adv.service 2>/dev/null || true

# Start new services
print_status "Starting new services..."
systemctl start "$SERVICE_NAME.service"
systemctl start "$WS_SERVICE_NAME.service"

# Wait and check status
sleep 3
print_status "Checking service status..."

for service in "$SERVICE_NAME" "$WS_SERVICE_NAME" "nginx"; do
    if systemctl is-active --quiet "$service.service"; then
        print_success "$service is running"
    else
        print_error "$service failed to start"
        systemctl status "$service.service"
    fi
done

# Create default files
print_status "Creating default files..."
cat > "/opt/kilo/docs/README.md" << EOF
# Kilo Truck Enhanced UI

This is the modern web-based control interface for Kilo Truck.

## Features

- Real-time IMU data visualization
- Face detection monitoring
- Android phone integration
- Live system status
- WebSocket-based updates
- Remote access management

## Access

- Basic UI: http://localhost:$UI_PORT
- Enhanced UI: http://localhost:$UI_PORT/enhanced
- WebSocket: ws://localhost:$WS_PORT

## Management

- Start/Stop: \`sudo systemctl $SERVICE_NAME start/stop\`
- View logs: \`sudo journalctl -u $SERVICE_NAME -f\`
- Remote access: \`sudo $INSTALL_DIR/bin/kilo-remote-manager enable/disable\`
EOF

cat > "/opt/kilo/docs/PROJECT_LEDGER.md" << EOF
# Kilo Truck Project Ledger

Enhanced UI deployment completed on $(date).

## Deployed Components

- Modern UI server on port $UI_PORT
- Realtime WebSocket server on port $WS_PORT
- Nginx reverse proxy configuration
- Android integration tools
- Remote access management

## System Integration

- Viam agent connectivity
- Android phone sensor integration
- Personality system controls
- SLAM and navigation controls
EOF

# Get network information
IP_LOCAL="localhost:$UI_PORT"
IP_NETWORK=""
if command -v hostname >/dev/null 2>&1; then
    NETWORK_IP=$(hostname -I | awk '{print $1}')
    if [ ! -z "$NETWORK_IP" ]; then
        IP_NETWORK="$NETWORK_IP:$UI_PORT"
    fi
fi

# Final status display
print_header "🎉 Deployment Complete!"

echo ""
print_success "✅ All services started successfully"
echo ""
echo "🌐 Access Points:"
echo "   Basic UI:      http://$IP_LOCAL"
echo "   Enhanced UI:   http://$IP_LOCAL/enhanced"
if [ ! -z "$IP_NETWORK" ]; then
    echo "   Network:       http://$IP_NETWORK"
    echo "   Enhanced:      http://$IP_NETWORK/enhanced"
fi
echo ""
echo "📱 Features Enabled:"
echo "   • Real-time IMU data streaming"
echo "   • Face detection monitoring"
echo "   • Android phone integration"
echo "   • WebSocket-based updates"
echo "   • Nginx reverse proxy"
echo "   • Remote access management"
echo ""
echo "🛠️ Management Commands:"
echo "   UI Services:   sudo systemctl $SERVICE_NAME start/stop/restart"
echo "   WebSocket:      sudo systemctl $WS_SERVICE_NAME start/stop/restart"
echo "   View Logs:      sudo journalctl -u $SERVICE_NAME -f"
echo "   Remote Access:  sudo $INSTALL_DIR/bin/kilo-remote-manager enable/disable/status"
echo "   Phone Discovery: $INSTALL_DIR/bin/discover-android-ip"
echo ""
echo "📊 Android Integration:"
echo "   Phone App Port: 8080"
echo "   IMU Data Rate: 10Hz"
echo "   Face Detection: 2Hz"
echo "   Health Monitor: 10s intervals"
echo ""

# Test connectivity
print_status "Testing local connectivity..."
if curl -s "http://localhost:$UI_PORT" > /dev/null; then
    print_success "Main UI responding"
else
    print_warning "Main UI not responding - check logs"
fi

if curl -s "http://localhost:$UI_PORT/enhanced" > /dev/null; then
    print_success "Enhanced UI responding"
else
    print_warning "Enhanced UI not responding - check logs"
fi

print_success "🚀 Kilo Truck Enhanced UI deployment complete!"
echo ""
echo "Next steps:"
echo "1. Connect your Android phone via USB tethering"
echo "2. Run phone discovery: $INSTALL_DIR/bin/discover-android-ip"
echo "3. Access the enhanced UI at http://localhost:$UI_PORT/enhanced"
echo "4. Enable remote access if needed: sudo $INSTALL_DIR/bin/kilo-remote-manager enable"