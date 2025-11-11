#!/bin/bash
# Kilo Truck Network Configuration Script
# Configures dual WiFi + USB tethering with proper failover

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root (sudo $0)"
fi

# Configuration
WIFI_INTERFACE="wlan0"
USB_INTERFACE="usb0"
PI_STATIC_IP="192.168.42.42"
PHONE_GATEWAY="192.168.42.129"
DNS_SERVERS="192.168.42.129 8.8.8.8 1.1.1.1"

log "Starting Kilo Truck network configuration..."

# Backup existing configuration
BACKUP_DIR="/etc/kilo/backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f /etc/dhcpcd.conf ]; then
    cp /etc/dhcpcd.conf "$BACKUP_DIR/dhcpcd.conf.backup"
    log "Backed up dhcpcd.conf to $BACKUP_DIR"
fi

# Configure static IP for USB tethering
log "Configuring static IP for USB tethering interface..."

# Create USB interface configuration
USB_CONFIG="# Kilo Truck USB Tethering Configuration
interface $USB_INTERFACE
static ip_address=$PI_STATIC_IP/24
static routers=$PHONE_GATEWAY
static domain_name_servers=$DNS_SERVERS
# Lower metric to prefer WiFi when available
metric 200"

# Add USB config to dhcpcd.conf if not already present
if ! grep -q "interface $USB_INTERFACE" /etc/dhcpcd.conf; then
    echo "$USB_CONFIG" >> /etc/dhcpcd.conf
    log "Added USB tethering configuration to dhcpcd.conf"
else
    warn "USB configuration already exists in dhcpcd.conf"
fi

# Configure WiFi interface with higher priority
log "Configuring WiFi interface priority..."

# Ensure WiFi has higher priority (lower metric number)
if ! grep -q "metric 100" /etc/dhcpcd.conf; then
    echo "# WiFi priority configuration" >> /etc/dhcpcd.conf
    echo "interface $WIFI_INTERFACE" >> /etc/dhcpcd.conf
    echo "metric 100" >> /etc/dhcpcd.conf
    log "Added WiFi priority configuration"
fi

# Enable IP forwarding
log "Enabling IP forwarding..."
if grep -q "#net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
elif ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi

# Apply IP forwarding immediately
sysctl -w net.ipv4.ip_forward=1

# Configure routing for failover
log "Configuring routing rules..."

# Create network configuration script
cat > /usr/local/bin/kilo-network-manager.sh << 'EOF'
#!/bin/bash
# Kilo Truck Network Manager

WIFI_INTERFACE="wlan0"
USB_INTERFACE="usb0"
PHONE_GATEWAY="192.168.42.129"

check_interface() {
    local interface=$1
    if ip link show "$interface" &>/dev/null; then
        if [ "$interface" = "$USB_INTERFACE" ]; then
            # Check if phone is reachable
            ping -c 1 -W 2 "$PHONE_GATEWAY" &>/dev/null
        else
            # Check if WiFi has internet
            ping -c 1 -W 2 8.8.8.8 &>/dev/null
        fi
    else
        return 1
    fi
}

setup_routing() {
    log "Setting up network routing priorities..."
    
    # Remove existing default routes
    ip route del default 2>/dev/null || true
    
    # Add WiFi as primary (lower metric = higher priority)
    if check_interface "$WIFI_INTERFACE"; then
        WIFI_GATEWAY=$(ip route show dev "$WIFI_INTERFACE" | awk '/default/ {print $3}')
        if [ -n "$WIFI_GATEWAY" ]; then
            ip route add default via "$WIFI_GATEWAY" dev "$WIFI_INTERFACE" metric 100
            echo "WiFi configured as primary gateway"
        fi
    fi
    
    # Add USB as secondary (higher metric = lower priority)
    if check_interface "$USB_INTERFACE"; then
        ip route add default via "$PHONE_GATEWAY" dev "$USB_INTERFACE" metric 200
        echo "USB tethering configured as secondary gateway"
    fi
}

# Run setup
setup_routing

echo "Network routing configured"
EOF

chmod +x /usr/local/bin/kilo-network-manager.sh

# Create systemd service for network management
cat > /etc/systemd/system/kilo-network-manager.service << EOF
[Unit]
Description=Kilo Truck Network Manager
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/kilo-network-manager.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable kilo-network-manager.service
systemctl start kilo-network-manager.service

# Create phone detection script
log "Creating phone detection utility..."

cat > /usr/local/bin/discover-android-ip << 'EOF'
#!/bin/bash
# Discover Android phone IP on USB tethering

USB_INTERFACE="usb0"
DEFAULT_PHONE_IP="192.168.42.129"

echo "Scanning for Android phone on USB tethering..."

# Check if USB interface exists
if ! ip link show "$USB_INTERFACE" &>/dev/null; then
    echo "USB tethering interface ($USB_INTERFACE) not found"
    echo "Please:"
    echo "1. Connect Android phone via USB"
    echo "2. Enable USB tethering on phone"
    exit 1
fi

# Try to ping the default phone IP
if ping -c 1 -W 2 "$DEFAULT_PHONE_IP" &>/dev/null; then
    echo "Phone found at: $DEFAULT_PHONE_IP"
    
    # Test if IMU endpoint is available
    if curl -s --connect-timeout 2 "http://$DEFAULT_PHONE_IP:8080/health" &>/dev/null; then
        echo "Phone IMU service is accessible"
        echo "Phone IP: $DEFAULT_PHONE_IP"
        exit 0
    else
        echo "Phone found but IMU service not accessible"
        echo "Check if the Flutter app is running on the phone"
        exit 2
    fi
else
    echo "Phone not found at default IP ($DEFAULT_PHONE_IP)"
    echo "Scanning USB network..."
    
    # Scan the USB network for potential phone IPs
    for ip in 192.168.42.{1..254}; do
        if [ "$ip" != "192.168.42.42" ]; then  # Skip our own IP
            if ping -c 1 -W 1 "$ip" &>/dev/null; then
                echo "Potential device found at: $ip"
                if curl -s --connect-timeout 1 "http://$ip:8080/health" &>/dev/null; then
                    echo "Phone IMU service found at: $ip"
                    echo "Phone IP: $ip"
                    exit 0
                fi
            fi
        fi
    done
    
    echo "No phone with IMU service found on USB network"
    exit 1
fi
EOF

chmod +x /usr/local/bin/discover-android-ip

# Create network diagnostic script
cat > /usr/local/bin/kilo-network-diag << 'EOF'
#!/bin/bash
# Kilo Truck Network Diagnostic

echo "=== Kilo Truck Network Diagnostic ==="
echo "Timestamp: $(date)"
echo

echo "=== Interface Status ==="
ip addr show | grep -E "(wlan0|usb0)" -A 3
echo

echo "=== Routing Table ==="
ip route show
echo

echo "=== Default Gateways ==="
ip route show | grep default
echo

echo "=== USB Tethering Test ==="
if discover-android-ip; then
    echo "✓ Phone connectivity: OK"
else
    echo "✗ Phone connectivity: FAILED"
fi
echo

echo "=== Internet Connectivity Test ==="
if ping -c 1 8.8.8.8 &>/dev/null; then
    echo "✓ Internet connectivity: OK"
else
    echo "✗ Internet connectivity: FAILED"
fi
echo

echo "=== DNS Resolution Test ==="
if nslookup google.com &>/dev/null; then
    echo "✓ DNS resolution: OK"
else
    echo "✗ DNS resolution: FAILED"
fi
echo

echo "=== End Diagnostic ==="
EOF

chmod +x /usr/local/bin/kilo-network-diag

# Restart networking services
log "Restarting networking services..."
systemctl restart dhcpcd
sleep 5

# Apply routing
/usr/local/bin/kilo-network-manager.sh

# Test configuration
log "Testing network configuration..."

echo
echo "=== Configuration Summary ==="
echo "USB Interface: $USB_INTERFACE"
echo "WiFi Interface: $WIFI_INTERFACE"
echo "Pi USB IP: $PI_STATIC_IP"
echo "Phone Gateway: $PHONE_GATEWAY"
echo

echo "=== Testing Phone Connectivity ==="
if discover-android-ip; then
    log "✓ Phone connectivity test: PASSED"
else
    warn "⚠ Phone connectivity test: FAILED - this is expected if phone not connected"
fi

echo
echo "=== Testing Internet Connectivity ==="
if ping -c 1 8.8.8.8 &>/dev/null; then
    log "✓ Internet connectivity test: PASSED"
else
    warn "⚠ Internet connectivity test: FAILED"
fi

echo
echo "=== Network Configuration Complete ==="
echo "Your system is now configured for:"
echo "• WiFi as primary internet connection"
echo "• USB tethering as backup/gateway to phone"
echo "• Automatic failover between interfaces"
echo
echo "Useful commands:"
echo "• discover-android-ip     - Find phone IP address"
echo "• kilo-network-diag        - Run network diagnostics"
echo "• kilo-network-manager.sh - Reapply routing rules"
echo
echo "Backup files saved to: $BACKUP_DIR"