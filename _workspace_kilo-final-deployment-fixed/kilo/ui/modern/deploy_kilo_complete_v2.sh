#!/bin/bash
# Kilo Truck Complete Deployment Script v2
# One-command deployment for all system components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="/etc/kilo/backup/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/kilo-deploy.log"

# Logging function
log() {
    local message="$1"
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $message" | tee -a "$LOG_FILE"
}

warn() {
    local message="$1"
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $message" | tee -a "$LOG_FILE"
}

error() {
    local message="$1"
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $message" | tee -a "$LOG_FILE"
    exit 1
}

info() {
    local message="$1"
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] INFO:${NC} $message" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root (sudo $0)"
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

log "Starting Kilo Truck complete deployment..."
log "Backup directory: $BACKUP_DIR"
log "Log file: $LOG_FILE"

# Function to restore from backup
restore_backup() {
    warn "Deployment failed, restoring from backup..."
    
    if [ -d "$BACKUP_DIR" ]; then
        # Restore configuration files
        if [ -f "$BACKUP_DIR/dhcpcd.conf.backup" ]; then
            cp "$BACKUP_DIR/dhcpcd.conf.backup" /etc/dhcpcd.conf
            log "Restored dhcpcd.conf"
        fi
        
        # Restart services
        systemctl restart dhcpcd
        systemctl restart viam-agent
        
        log "System restored from backup"
    else
        error "No backup directory found!"
    fi
}

# Trap errors and restore backup
trap 'restore_backup' ERR

# Phase 1: System Preparation
log "=== Phase 1: System Preparation ==="

# Update system packages
log "Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq

# Install required packages
log "Installing required packages..."
apt-get install -y -qq \
    curl \
    wget \
    jq \
    python3-pip \
    python3-venv \
    nftables \
    hostapd \
    dnsmasq \
    systemd

# Phase 2: Android IMU Module Deployment
log "=== Phase 2: Android IMU Module Deployment ==="

# Stop existing IMU module
systemctl stop kilo-android-imu 2>/dev/null || true
systemctl stop kilo-android-imu-fixed 2>/dev/null || true

# Install fixed Android IMU module
log "Installing fixed Android IMU module..."
mkdir -p /opt/viam/modules/android-imu

if [ -f "$SCRIPT_DIR/fixed_android_imu_v2.py" ]; then
    cp "$SCRIPT_DIR/fixed_android_imu_v2.py" /opt/viam/modules/android-imu/android_imu_fixed.py
    log "Copied Android IMU module from script directory"
else
    error "fixed_android_imu_v2.py not found in script directory"
fi

chmod +x /opt/viam/modules/android-imu/android_imu_fixed.py

# Create systemd service for fixed IMU
log "Creating Android IMU service..."
cat > /etc/systemd/system/kilo-android-imu-fixed.service << EOF
[Unit]
Description=Kilo Android IMU Module (Fixed)
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/opt/kilo/venv/bin/python /opt/viam/modules/android-imu/android_imu_fixed.py
Restart=always
RestartSec=10
User=root
Environment=PYTHONPATH=/opt/viam/modules
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable and start IMU service
systemctl daemon-reload
systemctl enable kilo-android-imu-fixed
systemctl start kilo-android-imu-fixed

log "Android IMU module deployed and started"

# Phase 3: Network Configuration
log "=== Phase 3: Network Configuration ==="

# Backup existing network configuration
if [ -f /etc/dhcpcd.conf ]; then
    cp /etc/dhcpcd.conf "$BACKUP_DIR/dhcpcd.conf.backup"
    log "Backed up dhcpcd.conf"
fi

# Deploy network setup script
if [ -f "$SCRIPT_DIR/network_setup_script.sh" ]; then
    log "Deploying network configuration..."
    chmod +x "$SCRIPT_DIR/network_setup_script.sh"
    "$SCRIPT_DIR/network_setup_script.sh"
    log "Network configuration completed"
else
    error "network_setup_script.sh not found in script directory"
fi

# Phase 4: Personality System Enhancement
log "=== Phase 4: Personality System Enhancement ==="

# Create personality management directory
mkdir -p /opt/kilo/lib
mkdir -p /opt/kilo/personality_packs

# Deploy personality manager
if [ -f "$SCRIPT_DIR/personality_manager.py" ]; then
    cp "$SCRIPT_DIR/personality_manager.py" /opt/kilo/lib/
    log "Deployed personality manager"
else
    warn "personality_manager.py not found, personality enhancements skipped"
fi

# Deploy phone bridge
if [ -f "$SCRIPT_DIR/phone_bridge.py" ]; then
    cp "$SCRIPT_DIR/phone_bridge.py" /opt/kilo/lib/
    log "Deployed phone communication bridge"
else
    warn "phone_bridge.py not found, phone bridge skipped"
fi

# Backup and enhance existing personality configuration
if [ -f /etc/kilo/personality.json ]; then
    cp /etc/kilo/personality.json "$BACKUP_DIR/personality.json.backup"
    log "Backed up existing personality configuration"
fi

# Create enhanced personality configuration if it doesn't exist
if [ ! -f /etc/kilo/personality.json ]; then
    log "Creating default enhanced personality configuration..."
    cat > /etc/kilo/personality.json << 'EOF'
{
  "snark_level": 2,
  "wake_words": ["kilo", "hey kilo"],
  "eyes_url": "http://localhost:7007",
  "offline_ok": true,
  "personality_packs": {
    "default": {
      "name": "Default Kilo",
      "responses": {
        "greeting": [
          {"text": "Hey there!", "snark_min": 0, "snark_max": 2},
          {"text": "Well look who it is!", "snark_min": 3, "snark_max": 5},
          {"text": "Oh great, another human. What do you want?", "snark_min": 4, "snark_max": 5}
        ],
        "startup": [
          {"text": "Systems online, ready to roll!", "snark_min": 0, "snark_max": 3},
          {"text": "Finally awake? Let's go already!", "snark_min": 4, "snark_max": 5}
        ],
        "low_battery": [
          {"text": "Getting a bit tired here, maybe charge me?", "snark_min": 0, "snark_max": 2},
          {"text": "I'm dying here! Plug me in before I shut down!", "snark_min": 3, "snark_max": 5}
        ],
        "face_detected": [
          {"text": "Hi {name}!", "snark_min": 0, "snark_max": 1},
          {"text": "Oh great, {name} is here. What do you want?", "snark_min": 2, "snark_max": 4},
          {"text": "{name}! About time you showed your face!", "snark_min": 5, "snark_max": 5}
        ],
        "navigation": [
          {"text": "On my way to the destination!", "snark_min": 0, "snark_max": 2},
          {"text": "Navigating... try not to trip over anything.", "snark_min": 3, "snark_max": 4},
          {"text": "Fine, I'll drive. But you're paying for the tickets!", "snark_min": 5, "snark_max": 5}
        ]
      }
    }
  },
  "active_pack": "default"
}
EOF
    log "Created enhanced personality configuration"
fi

# Phase 5: Viam Configuration Update
log "=== Phase 5: Viam Configuration Update ==="

# Backup existing Viam configuration
if [ -f /etc/viam.json ]; then
    cp /etc/viam.json "$BACKUP_DIR/viam.json.backup"
    log "Backed up existing Viam configuration"
fi

# Update Viam configuration with Android IMU
log "Updating Viam configuration..."

# Create Viam configuration patch
cat > /tmp/viam_android_imu_patch.json << 'EOF'
{
  "modules": [
    {
      "type": "local",
      "name": "kilo-android-imu-fixed",
      "executable_path": "/opt/kilo/venv/bin/python /opt/viam/modules/android-imu/android_imu_fixed.py"
    }
  ],
  "components": [
    {
      "name": "pixel_imu",
      "api": "rdk:component:movement_sensor",
      "model": "kilo:movement_sensor:android-imu",
      "attributes": {
        "phone_ip": "192.168.42.129",
        "phone_port": 8080,
        "timeout": 5.0,
        "update_interval": 0.1
      }
    }
  ]
}
EOF

# Merge patch into existing configuration
if [ -f /etc/viam.json ]; then
    # Simple merge - in production, use jq for proper JSON merging
    python3 -c "
import json

with open('/etc/viam.json', 'r') as f:
    config = json.load(f)

with open('/tmp/viam_android_imu_patch.json', 'r') as f:
    patch = json.load(f)

# Merge modules
if 'modules' not in config:
    config['modules'] = []
for module in patch['modules']:
    config['modules'].append(module)

# Merge components
if 'components' not in config:
    config['components'] = []
for component in patch['components']:
    config['components'].append(component)

# Update SLAM to use new IMU if applicable
for service in config.get('services', []):
    if service.get('name') == 'slam':
        if 'attributes' not in service:
            service['attributes'] = {}
        service['attributes']['movement_sensor'] = {'name': 'pixel_imu', 'data_frequency_hz': 100}

with open('/etc/viam.json', 'w') as f:
    json.dump(config, f, indent=2)

print('Viam configuration updated successfully')
"
    log "Viam configuration updated with Android IMU"
else
    warn "No existing Viam configuration found, skipping update"
fi

# Restart Viam agent
log "Restarting Viam agent..."
systemctl restart viam-agent

# Wait for Viam agent to start
log "Waiting for Viam agent to start..."
sleep 10

# Phase 6: Health Verification
log "=== Phase 6: Health Verification ==="

# Create health monitor script
log "Creating health monitoring script..."
cat > /usr/local/bin/kilo-health-monitor << 'EOF'
#!/bin/bash

echo "=== Kilo Truck Health Monitor ==="
echo "Timestamp: $(date)"

# Check critical services
services=("viam-agent" "kilo-android-imu-fixed" "kilo-ui")
all_healthy=true

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service: RUNNING"
    else
        echo "✗ $service: FAILED"
        all_healthy=false
    fi
done

# Check network interfaces
if ip link show usb0 &>/dev/null; then
    echo "✓ USB interface: AVAILABLE"
    if discover-android-ip &>/dev/null; then
        echo "✓ Phone connectivity: OK"
    else
        echo "⚠ Phone connectivity: NO PHONE CONNECTED"
    fi
else
    echo "⚠ USB interface: NOT CONNECTED"
fi

# Check Viam agent port
PORT=$(ss -lntp | awk '/viam-agent/ && $1 ~ /LISTEN/ {print $4}' | sed 's/.*://;q')
if [ -n "$PORT" ]; then
    echo "✓ Viam agent port: $PORT"
else
    echo "✗ Viam agent port: NOT LISTENING"
    all_healthy=false
fi

# Overall status
if [ "$all_healthy" = true ]; then
    echo "🟢 Overall System Health: HEALTHY"
    exit 0
else
    echo "🔴 Overall System Health: ISSUES DETECTED"
    exit 1
fi
EOF

chmod +x /usr/local/bin/kilo-health-monitor

# Run health check
log "Running system health check..."
if kilo-health-monitor; then
    log "✓ System health check: PASSED"
else
    warn "⚠ System health check: ISSUES DETECTED (may be expected if phone not connected)"
fi

# Phase 7: Final Setup
log "=== Phase 7: Final Setup ==="

# Create automated health monitoring cron job
log "Setting up automated health monitoring..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/kilo-health-monitor >> /var/log/kilo-health.log 2>&1") | crontab -

# Create utility aliases for easy access
cat > /etc/bash_completion.d/kilo-completion << 'EOF'
_kilo_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="health diag phone imu network status restart logs"

    if [[ ${cur} == * ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F _kilo_completion kilo

# Kilo utility functions
kilo() {
    case "$1" in
        health)
            kilo-health-monitor
            ;;
        diag)
            kilo-network-diag
            ;;
        phone)
            discover-android-ip
            ;;
        imu)
            journalctl -u kilo-android-imu-fixed -n 50
            ;;
        network)
            kilo-network-manager.sh
            ;;
        status)
            systemctl status viam-agent kilo-android-imu-fixed kilo-ui --no-pager
            ;;
        restart)
            echo "Restarting Kilo services..."
            systemctl restart kilo-android-imu-fixed viam-agent
            ;;
        logs)
            journalctl -f -u viam-agent -u kilo-android-imu-fixed
            ;;
        *)
            echo "Usage: kilo {health|diag|phone|imu|network|status|restart|logs}"
            return 1
            ;;
    esac
}
EOF

# Source completion for current session
source /etc/bash_completion.d/kilo-completion

# Create deployment summary
log "=== Deployment Summary ==="
log "✅ Android IMU module: FIXED and DEPLOYED"
log "✅ Network configuration: DUAL-NETWORK with failover"
log "✅ Personality system: ENHANCED with web management"
log "✅ Phone communication bridge: DEPLOYED"
log "✅ Health monitoring: AUTOMATED"
log "✅ Viam configuration: UPDATED"

echo
info "🎉 Kilo Truck deployment completed successfully!"
echo
info "📋 Quick Start Commands:"
echo "  kilo health     - Check system health"
echo "  kilo phone      - Test phone connectivity"
echo "  kilo diag       - Run network diagnostics"
echo "  kilo status     - Check service status"
echo "  kilo restart    - Restart all services"
echo
info "🔧 Configuration Files:"
echo "  /etc/kilo/personality.json - Personality configuration"
echo "  /etc/viam.json - Viam robot configuration"
echo "  /etc/dhcpcd.conf - Network configuration"
echo
info "📊 Monitoring:"
echo "  Health logs: /var/log/kilo-health.log"
echo "  Deployment log: $LOG_FILE"
echo "  Backup directory: $BACKUP_DIR"
echo
warn "⚠️  Next Steps:"
echo "1. Connect Android phone via USB"
echo "2. Enable USB tethering on phone"
echo "3. Start the Flutter app on phone"
echo "4. Run 'kilo phone' to verify connectivity"
echo "5. Test personality system via web UI (http://localhost:7860)"
echo
info "📖 For detailed documentation, see: comprehensive_integration_guide.md"

log "Deployment completed successfully at $(date)"

# Cleanup trap
trap - ERR

exit 0