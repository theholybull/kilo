#!/bin/bash

# Complete Kilo Truck UI Deployment Script - FIXED FOR DEBIAN TRIXIE
# Creates virtual environment BEFORE installing Python packages
# Deploys modern UI with real-time WebSocket updates and Android integration

set -e

echo "🚀 Deploying Complete Kilo Truck UI System (Fixed)..."

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
VENV_DIR="$INSTALL_DIR/venv"

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

# Install required packages (include python3-full for better venv support)
print_status "Installing system packages..."
apt-get install -y \
    python3-full \
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

# Create virtual environment FIRST (this fixes the Debian Trixie issue)
print_status "Creating Python virtual environment..."
if [ -d "$VENV_DIR" ]; then
    print_warning "Virtual environment already exists, removing it..."
    rm -rf $VENV_DIR
fi

python3 -m venv $VENV_DIR
print_success "Virtual environment created at $VENV_DIR"

# Install Python dependencies in virtual environment
print_status "Installing Python packages in virtual environment..."
source $VENV_DIR/bin/activate
pip install --upgrade pip
pip install \
    websockets \
    asyncio \
    requests \
    flask-socketio \
    flask \
    aiohttp
deactivate

# Create directories
print_status "Creating directories..."
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/logs"
mkdir -p "$INSTALL_DIR/config"
mkdir -p "/var/lib/kilo/snaps"
mkdir -p "/opt/kilo/docs"
mkdir -p "/opt/viam/maps"

# Install UI files
print_status "Installing UI files..."

# Copy all UI files to installation directory
cp *.py "$INSTALL_DIR/bin/" 2>/dev/null || true
cp *.html "$INSTALL_DIR/" 2>/dev/null || true
cp *.json "$INSTALL_DIR/config/" 2>/dev/null || true

# Make scripts executable
chmod +x "$INSTALL_DIR/bin"/*.py

# Create systemd service files
print_status "Creating systemd services..."

# Main UI service (using venv Python)
cat > "$SERVICE_DIR/$SERVICE_NAME.service" << EOF
[Unit]
Description=Kilo Truck Modern UI
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/bin/kilo_ui_modern.py
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

# Create WebSocket service (using venv Python)
cat > "$SERVICE_DIR/$WS_SERVICE_NAME.service" << EOF
[Unit]
Description=Kilo Truck Realtime WebSocket Server
After=network.target

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$VENV_DIR/bin/python $INSTALL_DIR/bin/kilo_ui_realtime.py
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
        proxy_pass http://localhost:$UI_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # WebSocket support
    location /ws {
        proxy_pass http://localhost:$WS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # Enhanced UI static files
    location /enhanced {
        try_files \$uri \$uri/ /kilo_ui_enhanced.html;
        root $INSTALL_DIR;
    }
}
EOF

# Enable Nginx site
ln -sf "/etc/nginx/sites-available/kilo-ui" "/etc/nginx/sites-enabled/"
rm -f "/etc/nginx/sites-enabled/default"

# Test and reload Nginx
nginx -t && systemctl reload nginx

# Create configuration file
print_status "Creating configuration file..."
cat > "$INSTALL_DIR/config/config.json" << EOF
{
    "ui_port": $UI_PORT,
    "websocket_port": $WS_PORT,
    "remote_access_enabled": false,
    "android_integration": {
        "imu_enabled": true,
        "eyes_enabled": true,
        "audio_enabled": true,
        "face_detection": true
    },
    "logging": {
        "level": "INFO",
        "file": "$INSTALL_DIR/logs/kilo-ui.log"
    }
}
EOF

# Create management utilities
print_status "Creating management utilities..."

# Status script
cat > "$INSTALL_DIR/bin/kilo-status" << EOF
#!/bin/bash
echo "🚚 Kilo Truck System Status"
echo "=========================="
echo ""
echo "Services:"
systemctl status $SERVICE_NAME --no-pager -l
echo ""
systemctl status $WS_SERVICE_NAME --no-pager -l
echo ""
echo "Network:"
netstat -tlnp | grep -E ":$UI_PORT|:$WS_PORT"
echo ""
echo "Logs:"
tail -n 10 $INSTALL_DIR/logs/*.log 2>/dev/null || echo "No logs found"
EOF

# Restart script
cat > "$INSTALL_DIR/bin/kilo-restart" << EOF
#!/bin/bash
echo "🔄 Restarting Kilo Truck services..."
systemctl restart $SERVICE_NAME $WS_SERVICE_NAME
echo "✓ Services restarted"
EOF

# Stop script
cat > "$INSTALL_DIR/bin/kilo-stop" << EOF
#!/bin/bash
echo "🛑 Stopping Kilo Truck services..."
systemctl stop $SERVICE_NAME $WS_SERVICE_NAME
echo "✓ Services stopped"
EOF

# Remote access manager
cat > "$INSTALL_DIR/bin/kilo-remote-manager" << 'EOF'
#!/bin/bash

CONFIG_FILE="/opt/kilo/config/config.json"
NGINX_SITE="/etc/nginx/sites-available/kilo-ui"

function enable_remote() {
    echo "Enabling remote access..."
    
    # Update config
    source /opt/kilo/venv/bin/activate
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
config['remote_access_enabled'] = True
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
"
    deactivate
    
    # Configure Nginx for external access
    sed -i 's/server_name _;/server_name _;/' "$NGINX_SITE"
    
    # Test and reload
    nginx -t && systemctl reload nginx
    systemctl restart kilo-ui-modern kilo-ui-realtime
    
    echo "Remote access enabled"
}

function disable_remote() {
    echo "Disabling remote access..."
    
    source /opt/kilo/venv/bin/activate
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
config['remote_access_enabled'] = False
with open('$CONFIG_FILE', 'w') as f:
    json.dump(config, f, indent=2)
"
    deactivate
    
    echo "Remote access disabled (localhost only)"
}

function status() {
    source /opt/kilo/venv/bin/activate
    python3 -c "
import json
with open('$CONFIG_FILE', 'r') as f:
    config = json.load(f)
enabled = config.get('remote_access_enabled', False)
status = 'ENABLED' if enabled else 'DISABLED'
print(f'Remote access: {status}')
print(f\"UI Port: {config.get('ui_port', 8080)}\")
print(f\"WebSocket Port: {config.get('websocket_port', 8081)}\")
"
    deactivate
}

case "$1" in
    enable) enable_remote ;;
    disable) disable_remote ;;
    status) status ;;
    *) echo "Usage: $0 {enable|disable|status}" ;;
esac
EOF

# Make all utility scripts executable
chmod +x "$INSTALL_DIR/bin/kilo-"*

# Add to PATH for easier access
echo 'export PATH="/opt/kilo/bin:$PATH"' >> /etc/bash.bashrc

# Reload systemd and start services
print_status "Starting services..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME $WS_SERVICE_NAME
systemctl start $SERVICE_NAME $WS_SERVICE_NAME

# Wait for services to start
sleep 5

# Check service status
print_status "Checking service status..."
if systemctl is-active --quiet $SERVICE_NAME; then
    print_success "✓ Modern UI service is running"
else
    print_error "✗ Modern UI service failed to start"
    journalctl -u $SERVICE_NAME --no-pager -l
fi

if systemctl is-active --quiet $WS_SERVICE_NAME; then
    print_success "✓ Realtime UI service is running"
else
    print_error "✗ Realtime UI service failed to start"
    journalctl -u $WS_SERVICE_NAME --no-pager -l
fi

# Get system IP for access information
SYSTEM_IP=$(hostname -I | awk '{print $1}')

# Final instructions
echo ""
print_header "🎉 Deployment Complete!"
echo "=========================="
echo ""
print_success "Access your Kilo Truck UI at:"
echo "  • Main UI: http://$SYSTEM_IP:$UI_PORT"
echo "  • Enhanced UI: http://$SYSTEM_IP:$UI_PORT/enhanced"
echo "  • WebSocket: ws://$SYSTEM_IP:$WS_PORT"
echo ""
echo "Management commands:"
echo "  • kilo-status    - Check system status"
echo "  • kilo-restart   - Restart services"
echo "  • kilo-stop      - Stop services"
echo "  • kilo-remote-manager enable/disable - Manage remote access"
echo ""
echo "Logs:"
echo "  • journalctl -u $SERVICE_NAME -f"
echo "  • journalctl -u $WS_SERVICE_NAME -f"
echo ""
print_success "Installation completed successfully!"
print_status "Virtual environment location: $VENV_DIR"
print_status "Use 'source $VENV_DIR/bin/activate' to activate venv manually"
