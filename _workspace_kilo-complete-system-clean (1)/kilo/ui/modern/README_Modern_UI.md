# Kilo Truck Modern UI System

A comprehensive, modern web-based control interface for the Kilo Truck autonomous RC car system with real-time updates, Android integration, and remote access capabilities.

## 🚀 Features

### Core Functionality
- **Modern Web Interface**: Responsive, mobile-friendly design using Tailwind CSS
- **Real-time Updates**: WebSocket-based live data streaming
- **Android Integration**: Complete phone sensor and display integration
- **Remote Access**: Secure remote management with Nginx reverse proxy
- **Unified Control**: Single interface replacing multiple legacy UIs

### Real-time Monitoring
- **IMU Data Visualization**: Live accelerometer and gyroscope data at 10Hz
- **Face Detection**: Real-time face detection monitoring from phone camera
- **System Status**: Live service status and resource monitoring
- **Network Monitoring**: Dual-network (WiFi + USB tethering) status
- **Phone Health**: Continuous Android phone connectivity monitoring

### Android Integration
- **Phone Discovery**: Automatic detection of Android phone on USB tethering
- **IMU Sensor Bridge**: High-precision sensor data replacing OAK-D IMU
- **Face Detection**: Personalized greetings and emotion responses
- **Eyes Display**: Animated emotional states on phone screen
- **Audio Bridge**: Pi TTS → Phone speaker, Phone mic → Pi ASR

### Control Features
- **Personality Management**: Web-based personality system configuration
- **Viam Control**: Complete Viam agent management
- **Navigation Controls**: SLAM mapping and wander mode
- **Service Management**: Start/stop/restart all system services
- **Configuration Management**: Real-time configuration updates

## 📦 Installation

### Prerequisites
- Raspberry Pi 4 with Debian Trixie or later
- Python 3.8+ with pip
- Systemd service manager
- Nginx web server
- Android phone with Kilo app

### Quick Deploy

```bash
# Make deployment script executable
chmod +x deploy_complete_ui.sh

# Run deployment with sudo
sudo ./deploy_complete_ui.sh
```

### Manual Installation

1. **Install Dependencies**
```bash
sudo apt-get update
sudo apt-get install python3 python3-pip nginx nmap jq
pip3 install websockets requests flask
```

2. **Install UI Components**
```bash
# Copy files to installation directory
sudo cp kilo_ui_modern.py /opt/kilo/bin/
sudo cp kilo_ui_realtime.py /opt/kilo/bin/
sudo cp kilo_ui_enhanced.html /opt/kilo/www/
sudo chmod +x /opt/kilo/bin/kilo_ui_*.py
```

3. **Configure Services**
```bash
# Install systemd services
sudo cp kilo-ui-modern.service /etc/systemd/system/
sudo cp kilo-ui-realtime.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable kilo-ui-modern kilo-ui-realtime
```

4. **Start Services**
```bash
sudo systemctl start kilo-ui-modern kilo-ui-realtime
```

## 🌐 Access

### Local Access
- **Basic UI**: http://localhost:8080
- **Enhanced UI**: http://localhost:8080/enhanced
- **WebSocket**: ws://localhost:8081

### Remote Access
```bash
# Enable remote access
sudo /opt/kilo/bin/kilo-remote-manager enable

# Check status
sudo /opt/kilo/bin/kilo-remote-manager status

# Disable remote access
sudo /opt/kilo/bin/kilo-remote-manager disable
```

### Network Configuration
- **Main UI Port**: 8080
- **WebSocket Port**: 8081
- **Phone App Port**: 8080
- **Nginx Proxy**: 80/443

## 📱 Android Integration Setup

### Phone Configuration
1. Install Kilo Truck app on Android phone
2. Enable USB tethering on phone
3. Connect phone to Raspberry Pi via USB

### Phone Discovery
```bash
# Discover phone IP address
/opt/kilo/bin/discover-android-ip

# Manual IP configuration if needed
sudo nano /etc/kilo/personality.json
```

### Phone App Endpoints
```
GET  /health     - Status check
GET  /imu        - IMU sensor data
GET  /faces      - Face detection data
POST /eyes       - Eyes control
POST /tts        - Text-to-speech
```

## 🎮 Usage

### Enhanced UI Features

#### Real-time Dashboard
- Live IMU data visualization with charts
- Face detection monitoring
- System resource monitoring
- Service status indicators

#### Android Controls
- Phone discovery and connection
- Eyes emotion control (happy, sad, angry)
- Eyes steering control (left, center, right)
- Live eyes preview

#### Personality Management
- Snark level adjustment (0-5)
- Wake word configuration
- Service start/stop/restart
- Real-time configuration updates

#### Viam Integration
- Agent status monitoring
- Service restart capabilities
- SLAM map saving
- Wander mode control

### WebSocket API

#### Connection
```javascript
const ws = new WebSocket('ws://localhost:8081');
```

#### Message Types
- `system_status` - System monitoring data
- `imu_data` - IMU sensor readings
- `faces_detected` - Face detection results
- `phone_health` - Phone connection status
- `eyes_response` - Eyes command response

#### Commands
```javascript
// Discover phone
ws.send(JSON.stringify({type: 'discover_phone'}));

// Send eyes command
ws.send(JSON.stringify({
    type: 'eyes_command',
    emotion_type: 'emotion',
    emotion: 'happy'
}));

// Update configuration
ws.send(JSON.stringify({
    type: 'update_config',
    data: {snark_level: 3}
}));
```

## 🔧 Configuration

### Main Configuration File
Location: `/etc/kilo/personality.json`

```json
{
  "snark_level": 2,
  "wake_words": ["kilo", "hey kilo"],
  "eyes_url": "http://localhost:7007",
  "offline_ok": true,
  "allow_actuation": false,
  "tts_mode": "online",
  "piper_model": "/opt/piper/en_US-amy-medium.onnx",
  "modern_ui_enabled": true,
  "modern_ui_port": 8080,
  "websocket_port": 8081,
  "remote_access_enabled": false,
  "android_phone_ip": "10.10.10.1",
  "android_port": "8080",
  "enhanced_ui_enabled": true,
  "nginx_proxy": true
}
```

### Network Configuration
- **WiFi Interface**: Primary network connection
- **USB Tethering**: Secondary network for phone
- **Static IPs**: Configurable locked addresses
- **Failover**: Automatic network switching

## 🛠️ Management

### Service Management
```bash
# Check status
sudo systemctl status kilo-ui-modern
sudo systemctl status kilo-ui-realtime

# View logs
sudo journalctl -u kilo-ui-modern -f
sudo journalctl -u kilo-ui-realtime -f

# Restart services
sudo systemctl restart kilo-ui-modern kilo-ui-realtime
```

### Configuration Updates
Configuration can be updated:
- Via web interface in real-time
- By editing `/etc/kilo/personality.json`
- Through WebSocket API commands

### Remote Access Management
```bash
# Enable remote access (open to all IPs)
sudo /opt/kilo/bin/kilo-remote-manager enable

# Disable remote access (localhost only)
sudo /opt/kilo/bin/kilo-remote-manager disable

# Check current status
sudo /opt/kilo/bin/kilo-remote-manager status
```

## 📊 Monitoring

### System Metrics
- CPU load and memory usage
- Disk space availability
- Service health status
- Network interface status
- System uptime

### Android Integration Metrics
- Phone connection status
- IMU data rate (10Hz)
- Face detection rate (2Hz)
- Health check intervals (10s)
- Command response times

### Performance Monitoring
- WebSocket connection health
- Real-time data streaming
- API response times
- Error rates and recovery

## 🔒 Security

### Access Control
- Local-only access by default
- Configurable remote access
- Nginx reverse proxy
- Firewall configuration
- Service isolation

### Network Security
- USB tethering isolation
- Static IP assignment
- Network priority system
- Failover protection

## 🐛 Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check service status
sudo systemctl status kilo-ui-modern
sudo journalctl -u kilo-ui-modern --no-pager

# Check port conflicts
sudo netstat -tlnp | grep :8080
```

#### WebSocket Connection Issues
```bash
# Check WebSocket service
sudo systemctl status kilo-ui-realtime
sudo journalctl -u kilo-ui-realtime -f

# Test WebSocket manually
curl -i -N -H "Connection: Upgrade" \
     -H "Upgrade: websocket" \
     -H "Sec-WebSocket-Key: test" \
     -H "Sec-WebSocket-Version: 13" \
     http://localhost:8081/
```

#### Android Phone Not Found
```bash
# Run phone discovery
sudo /opt/kilo/bin/discover-android-ip

# Check USB tethering
lsusb | grep -i android
ip addr show | grep -A 5 usb

# Test phone connectivity
curl http://10.10.10.1:8080/health
```

#### Nginx Proxy Issues
```bash
# Test Nginx configuration
sudo nginx -t

# Check Nginx logs
sudo journalctl -u nginx -f

# Reload Nginx
sudo systemctl reload nginx
```

### Log Locations
- **Modern UI**: `sudo journalctl -u kilo-ui-modern -f`
- **WebSocket**: `sudo journalctl -u kilo-ui-realtime -f`
- **Nginx**: `sudo journalctl -u nginx -f`
- **System**: `/var/log/syslog`

## 🔄 Migration from Legacy UIs

### Legacy Services to Replace
- `kilo-ui.service` (port 7860) → `kilo-ui-modern.service` (port 8080)
- `kilo-ui-adv.service` (port 7861) → Integrated into modern UI
- `commands_panel.py` (Gradio) → Integrated web interface

### Migration Steps
1. Backup existing configurations
2. Deploy modern UI system
3. Update bookmarks and shortcuts
4. Disable legacy services
5. Verify all functionality

### Configuration Migration
```bash
# Backup old configs
sudo cp /etc/kilo/personality.json /etc/kilo/personality.json.backup

# Migration happens automatically during deployment
# Manual verification recommended
```

## 📈 Performance

### Data Rates
- **IMU Updates**: 10Hz (100ms intervals)
- **Face Detection**: 2Hz (500ms intervals)
- **System Status**: 0.2Hz (5 second intervals)
- **Phone Health**: 0.1Hz (10 second intervals)

### Resource Usage
- **Memory**: ~50MB for UI services
- **CPU**: <5% during normal operation
- **Network**: Minimal overhead
- **Storage**: ~10MB installation size

### Optimization
- WebSocket connection pooling
- Efficient data serialization
- Client-side caching
- Lazy loading of components

## 🤝 Contributing

### Development Setup
```bash
# Clone development environment
git clone <repository>
cd kilo-ui-modern

# Install development dependencies
pip3 install -r requirements-dev.txt

# Run development servers
python3 kilo_ui_modern.py &
python3 kilo_ui_realtime.py &
```

### Code Structure
- `kilo_ui_modern.py` - Main HTTP server with API endpoints
- `kilo_ui_realtime.py` - WebSocket server for real-time updates
- `kilo_ui_enhanced.html` - Enhanced web interface
- `deploy_complete_ui.sh` - Complete deployment script

## 📄 License

This project is part of the Kilo Truck autonomous RC car system.

## 🆘 Support

For issues and support:
1. Check troubleshooting section
2. Review system logs
3. Verify service status
4. Test network connectivity
5. Check Android phone connection

---

**Kilo Truck Modern UI** - Next-generation control interface for autonomous robotics.