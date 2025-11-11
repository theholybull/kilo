#!/bin/bash

# Kilo Truck Modern UI Deployment Script
# Sets up the modern web interface with remote access and Android integration

set -e

echo "🚀 Deploying Kilo Truck Modern UI..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UI_PORT=8080
SERVICE_NAME="kilo-ui-modern"
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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# Create necessary directories
print_status "Creating directories..."
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/logs"
mkdir -p "/var/lib/kilo/snaps"
mkdir -p "/opt/kilo/docs"

# Install the modern UI
print_status "Installing modern UI..."
cp kilo_ui_modern.py "$INSTALL_DIR/bin/"
chmod +x "$INSTALL_DIR/bin/kilo_ui_modern.py"

# Install Python dependencies if needed
print_status "Checking Python dependencies..."
if ! python3 -c "import http.server" 2>/dev/null; then
    print_error "Python 3 http.server module not available"
    exit 1
fi

# Create systemd service
print_status "Creating systemd service..."
cat > "$SERVICE_DIR/$SERVICE_NAME.service" << EOF
[Unit]
Description=Kilo Truck Modern UI
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

# Reload systemd and enable service
print_status "Setting up systemd service..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME.service"

# Configure firewall if ufw is available
if command -v ufw >/dev/null 2>&1; then
    print_status "Configuring firewall..."
    ufw allow $UI_PORT/tcp comment "Kilo Modern UI" || print_warning "Failed to configure firewall"
fi

# Create remote access configuration
print_status "Setting up remote access configuration..."

# Check for existing configuration
if [ -f "/etc/kilo/personality.json" ]; then
    print_status "Updating existing configuration..."
    # Backup existing config
    cp "/etc/kilo/personality.json" "/etc/kilo/personality.json.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Update with modern UI settings
    python3 -c "
import json

config_file = '/etc/kilo/personality.json'
with open(config_file, 'r') as f:
    config = json.load(f)

# Add modern UI settings
config.update({
    'modern_ui_enabled': True,
    'modern_ui_port': $UI_PORT,
    'remote_access_enabled': False,  # Disabled by default for security
    'android_phone_ip': '10.10.10.1',
    'android_port': '8080'
})

with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print('Configuration updated successfully')
"
else
    print_status "Creating new configuration..."
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
  "remote_access_enabled": false,
  "android_phone_ip": "10.10.10.1",
  "android_port": "8080"
}
EOF
fi

# Create Android IP discovery utility
print_status "Installing Android discovery utility..."
cat > "$INSTALL_DIR/bin/discover-android-ip" << 'EOF'
#!/bin/bash

# Android Phone IP Discovery Utility
# Scans common USB tethering networks for the Kilo phone app

NETWORKS=("192.168.42.0/24" "10.10.10.0/24")
PORT="8080"

echo "Discovering Android phone..."

for network in "${NETWORKS[@]}"; do
    echo "Scanning $network..."
    
    # Use nmap if available, otherwise fallback to ping scan
    if command -v nmap >/dev/null 2>&1; then
        result=$(nmap -p $PORT --open -T4 $network 2>/dev/null | grep "$PORT/open" | head -1)
        if [ ! -z "$result" ]; then
            ip=$(echo "$result" | awk '{print $2}')
            echo "Found phone at: $ip"
            echo "$ip"
            exit 0
        fi
    else
        # Fallback: ping common IP addresses
        for i in {1..254}; do
            if [[ "$network" == "192.168.42.0/24" ]]; then
                ip="192.168.42.$i"
            else
                ip="10.10.10.$i"
            fi
            
            # Quick port check
            if timeout 1 bash -c "</dev/tcp/$ip/$PORT" 2>/dev/null; then
                echo "Found phone at: $ip"
                echo "$ip"
                exit 0
            fi
        done
    fi
done

echo "No phone found"
exit 1
EOF

chmod +x "$INSTALL_DIR/bin/discover-android-ip"

# Create remote access helper script
print_status "Creating remote access helper..."
cat > "$INSTALL_DIR/bin/remote-access-setup" << 'EOF'
#!/bin/bash

# Remote Access Setup Helper
# Configures secure remote access to the modern UI

CONFIG_FILE="/etc/kilo/personality.json"
PORT="8080"

function enable_remote_access() {
    echo "Enabling remote access..."
    
    # Update configuration
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
config['remote_access_enabled'] = True
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
"
    
    # Restart UI service
    systemctl restart kilo-ui-modern
    
    echo "Remote access enabled on port $PORT"
    echo "Access from: http://$(hostname -I | awk '{print $1}'):$PORT"
}

function disable_remote_access() {
    echo "Disabling remote access..."
    
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
config['remote_access_enabled'] = False
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
"
    
    echo "Remote access disabled - UI only accessible locally"
}

function status() {
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
enabled = config.get('remote_access_enabled', False)
status = 'ENABLED' if enabled else 'DISABLED'
print(f'Remote access: {status}')
"
    
    echo "Local access: http://localhost:$PORT"
    if command -v hostname >/dev/null 2>&1; then
        echo "Remote access: http://$(hostname -I | awk '{print $1}'):$PORT"
    fi
}

case "$1" in
    enable)
        enable_remote_access
        ;;
    disable)
        disable_remote_access
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {enable|disable|status}"
        echo ""
        echo "Commands:"
        echo "  enable   - Enable remote access (allows connections from any IP)"
        echo "  disable  - Disable remote access (localhost only)"
        echo "  status   - Show current remote access status"
        exit 1
        ;;
esac
EOF

chmod +x "$INSTALL_DIR/bin/remote-access-setup"

# Stop old UI services if they exist
print_status "Stopping old UI services..."
systemctl stop kilo-ui.service 2>/dev/null || true
systemctl stop kilo-ui-adv.service 2>/dev/null || true
systemctl disable kilo-ui.service 2>/dev/null || true
systemctl disable kilo-ui-adv.service 2>/dev/null || true

# Start the new modern UI
print_status "Starting modern UI service..."
systemctl start "$SERVICE_NAME.service"

# Wait a moment and check status
sleep 3
if systemctl is-active --quiet "$SERVICE_NAME.service"; then
    print_success "Modern UI service started successfully"
else
    print_error "Failed to start modern UI service"
    systemctl status "$SERVICE_NAME.service"
    exit 1
fi

# Get IP addresses
IP_LOCAL="localhost:$UI_PORT"
IP_NETWORK=""
if command -v hostname >/dev/null 2>&1; then
    NETWORK_IP=$(hostname -I | awk '{print $1}')
    if [ ! -z "$NETWORK_IP" ]; then
        IP_NETWORK="$NETWORK_IP:$UI_PORT"
    fi
fi

# Display access information
echo ""
print_success "🎉 Kilo Truck Modern UI deployment complete!"
echo ""
echo "📱 Access the modern web interface:"
echo "   Local:    http://$IP_LOCAL"
if [ ! -z "$IP_NETWORK" ]; then
    echo "   Network:  http://$IP_NETWORK"
fi
echo ""
echo "🛠️  Management commands:"
echo "   Start/Stop:   sudo systemctl $SERVICE_NAME start/stop/restart"
echo "   View logs:    sudo journalctl -u $SERVICE_NAME -f"
echo "   Remote access: sudo $INSTALL_DIR/bin/remote-access-setup enable|disable|status"
echo ""
echo "📱 Android Integration:"
echo "   Discover phone: $INSTALL_DIR/bin/discover-android-ip"
echo "   Phone app should run on port 8080"
echo ""
echo "🔧 Configuration:"
echo "   Config file: /etc/kilo/personality.json"
echo "   Service file: $SERVICE_DIR/$SERVICE_NAME.service"
echo ""

# Show current service status
print_status "Current service status:"
systemctl status "$SERVICE_NAME.service" --no-pager -l

print_success "Deployment complete! Access the UI to start using your Kilo Truck."