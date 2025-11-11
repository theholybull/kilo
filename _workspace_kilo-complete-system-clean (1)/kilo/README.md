# Kilo Truck - Autonomous RC Car System

A comprehensive autonomous RC car system built with Raspberry Pi, Viam robotics platform, and Android integration. Features real-time control, modern web interface, and advanced navigation capabilities.

## 🚀 System Overview

Kilo Truck is a sophisticated autonomous vehicle platform that combines:
- **Ackermann Steering Base**: Physics-based vehicle kinematics with PWM servo control
- **Modern Web UI**: Real-time control interface with WebSocket updates
- **Android Integration**: Phone-based sensors, face detection, and display
- **Viam Platform**: Professional robotics control and SLAM navigation
- **Personality System**: Interactive AI with voice and emotion responses

## 📁 Project Structure

```
kilo/
├── modules/
│   └── ackermann-pwm-base/          # Core motor control module
│       ├── main.go                  # Module entry point
│       ├── base.go                  # Ackermann steering implementation
│       ├── go.mod                   # Go module dependencies
│       ├── go.sum                   # Dependency checksums
│       ├── ackermann                # Compiled binary
│       └── README.md                # Module documentation
├── ui/
│   └── modern/                      # Modern web interface
│       ├── kilo_ui_modern.py        # Main Flask server
│       ├── kilo_ui_realtime.py      # WebSocket real-time server
│       ├── kilo_ui_enhanced.html    # Enhanced web interface
│       ├── deploy_complete_ui.sh    # Complete deployment script
│       └── README_Modern_UI.md      # UI documentation
└── README.md                        # This file
```

## 🎮 Core Components

### 1. Ackermann PWM Base Module
**Location**: `modules/ackermann-pwm-base/`

A Viam module providing realistic vehicle kinematics:
- **Steering Control**: PWM servo with configurable turning radius
- **Drive Control**: Variable speed with safety limits
- **Physics Model**: Proper Ackermann steering geometry
- **Viam Integration**: Modular component for robot configuration

**Key Features**:
- Configurable wheelbase and turning radius
- Servo position feedback and control
- Safety speed limits
- Invert options for mounting flexibility

### 2. Modern Web Interface
**Location**: `ui/modern/`

Next-generation control system replacing legacy UIs:
- **Real-time Updates**: WebSocket-based live data streaming
- **Android Integration**: Complete phone sensor bridge
- **Responsive Design**: Mobile-friendly with modern styling
- **Remote Access**: Secure web-based management

**Key Features**:
- Live IMU data visualization (10Hz)
- Face detection monitoring (2Hz)
- Real-time system status
- Interactive motor controls
- Personality system management

### 3. Android Integration
**Phone Features**:
- **IMU Sensor Bridge**: High-precision accelerometer/gyroscope data
- **Face Detection**: Personalized greetings and responses
- **Eyes Display**: Animated emotional states
- **Audio Bridge**: TTS output and microphone input
- **USB Tethering**: Automatic network discovery

## 🛠️ Installation & Setup

### Prerequisites
- Raspberry Pi 4 with Debian Trixie or later
- Viam agent installed and configured
- Android phone with Kilo app
- PCA9685 servo controller
- PWM servos for steering and drive

### Quick Deploy

#### 1. Deploy Modern UI System
```bash
cd ui/modern
chmod +x deploy_complete_ui.sh
sudo ./deploy_complete_ui.sh
```

#### 2. Build and Install Ackermann Module
```bash
cd modules/ackermann-pwm-base
go build -o ackermann
sudo cp ackermann /opt/kilo/bin/
```

#### 3. Configure Viam Robot
Add to your Viam robot configuration:

```json
{
  "modules": [
    {
      "executable_path": "/opt/kilo/bin/ackermann",
      "name": "ackermann-module"
    }
  ],
  "components": [
    {
      "name": "drive",
      "type": "base",
      "model": "viam-labs:base:ackermann-pwm-base",
      "attributes": {
        "steer": "steerServo",
        "drive": "driveServo",
        "turning_radius_meters": 0.2,
        "wheelbase_mm": 300,
        "max_speed_meters_per_second": 2.5
      }
    }
  ]
}
```

### Service Configuration
```bash
# Enable and start services
sudo systemctl enable kilo-ui-modern kilo-ui-realtime
sudo systemctl start kilo-ui-modern kilo-ui-realtime

# Enable remote access if needed
sudo /opt/kilo/bin/kilo-remote-manager enable
```

## 🌐 Access Points

After deployment:
- **Basic UI**: http://localhost:8080
- **Enhanced UI**: http://localhost:8080/enhanced
- **WebSocket**: ws://localhost:8081
- **Remote Access**: Configure via management tools

## 📱 Android Setup

1. **Install Kilo App** on your Android phone
2. **Enable USB Tethering** and connect to Raspberry Pi
3. **Run Phone Discovery**: `/opt/kilo/bin/discover-android-ip`
4. **Access Enhanced UI** for real-time integration

## 🎮 Usage

### Web Interface Controls

#### Motor Control
- **Manual Driving**: Virtual joystick and keyboard controls
- **Velocity Control**: Precise linear and angular velocity
- **Safety Toggle**: Enable/disable actuation
- **Emergency Stop**: Immediate motor cutoff

#### Android Integration
- **Phone Discovery**: Automatic USB tethering detection
- **Eyes Control**: Emotion states and steering visualization
- **IMU Monitoring**: Real-time sensor data visualization
- **Face Detection**: Live monitoring and response system

#### System Management
- **Service Control**: Start/stop/restart all components
- **Configuration**: Real-time settings updates
- **Monitoring**: Live status and resource usage
- **Logs**: Real-time console output

### API Integration

#### WebSocket API
```javascript
const ws = new WebSocket('ws://localhost:8081');

// Motor control
ws.send(JSON.stringify({
    type: 'set_velocity',
    linear: {x: 0, y: 100, z: 0},
    angular: {x: 0, y: 0, z: 15}
}));

// Android eyes control
ws.send(JSON.stringify({
    type: 'eyes_command',
    emotion_type: 'emotion',
    emotion: 'happy'
}));
```

#### REST API
```bash
# Set velocity
curl -X POST http://localhost:8080/api/viam/set_velocity \
  -H "Content-Type: application/json" \
  -d '{"linear": {"x": 0, "y": 100, "z": 0}, "angular": {"x": 0, "y": 0, "z": 15}}'

# Emergency stop
curl -X POST http://localhost:8080/api/viam/stop

# Get system status
curl http://localhost:8080/api/status
```

## 🔧 Configuration

### Ackermann Base Configuration
```json
{
  "steer": "steerServo",              // Steering servo name
  "drive": "driveServo",              // Drive servo name
  "turning_radius_meters": 0.2,       // Vehicle turning radius
  "wheelbase_mm": 300,               // Front-to-rear wheel distance
  "max_speed_meters_per_second": 2.5, // Maximum forward speed
  "invert_steer": false,             // Invert steering direction
  "invert_drive": false              // Invert drive direction
}
```

### UI Configuration
**Location**: `/etc/kilo/personality.json`

```json
{
  "modern_ui_enabled": true,
  "modern_ui_port": 8080,
  "websocket_port": 8081,
  "remote_access_enabled": false,
  "android_phone_ip": "10.10.10.1",
  "android_port": "8080",
  "snark_level": 2,
  "wake_words": ["kilo", "hey kilo"]
}
```

## 📊 Performance Specifications

### Motor Control
- **Servo Range**: 0-180° PWM control
- **Steering Resolution**: 1° precision
- **Speed Control**: 0.1% increments
- **Response Time**: <50ms

### Real-time Data
- **IMU Updates**: 10Hz (100ms intervals)
- **Face Detection**: 2Hz (500ms intervals)
- **System Status**: 0.2Hz (5 second intervals)
- **Phone Health**: 0.1Hz (10 second intervals)

### System Resources
- **Memory Usage**: ~50MB for UI services
- **CPU Usage**: <5% during normal operation
- **Network**: Minimal overhead
- **Storage**: ~50MB total installation

## 🛡️ Safety Features

### Motor Safety
- **Speed Limits**: Configurable maximum velocities
- **Actuation Toggle**: Manual enable/disable switch
- **Emergency Stop**: Immediate motor cutoff
- **Collision Detection**: Integration with SLAM maps

### System Safety
- **Service Monitoring**: Automatic restart on failure
- **Network Security**: Configurable access controls
- **Data Validation**: Input sanitization and limits
- **Graceful Degradation**: Fallback modes for failures

## 🔍 Troubleshooting

### Common Issues

#### Services Not Starting
```bash
# Check service status
sudo systemctl status kilo-ui-modern
sudo journalctl -u kilo-ui-modern --no-pager

# Check for port conflicts
sudo netstat -tlnp | grep :8080
```

#### Android Phone Not Connected
```bash
# Discover phone
sudo /opt/kilo/bin/discover-android-ip

# Check USB tethering
lsusb | grep -i android
ip addr show | grep -A 5 usb

# Test phone connectivity
curl http://10.10.10.1:8080/health
```

#### Motor Control Issues
```bash
# Check Viam configuration
cat /etc/viam.json | jq '.components[] | select(.type=="base")'

# Test servo connection
viam-client debug

# Check module logs
sudo journalctl -u viam-agent -f
```

### Log Locations
- **Modern UI**: `sudo journalctl -u kilo-ui-modern -f`
- **WebSocket**: `sudo journalctl -u kilo-ui-realtime -f`
- **Viam Agent**: `sudo journalctl -u viam-agent -f`
- **System**: `/var/log/syslog`

## 🤝 Contributing

### Development Setup
```bash
# Clone repository
gh repo clone theholybull/kilo
cd kilo

# Build ackermann module
cd modules/ackermann-pwm-base
go build -o ackermann

# Run development UI servers
cd ../../ui/modern
python3 kilo_ui_modern.py &
python3 kilo_ui_realtime.py &
```

### Code Standards
- Go code follows standard formatting and best practices
- Python code uses PEP 8 style guidelines
- Web interface uses modern HTML5 and Tailwind CSS
- All components include comprehensive documentation

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

## 🙏 Acknowledgments

- **Viam Robotics**: Core robotics platform and framework
- **Viam Labs**: Ackermann steering base module
- **Raspberry Pi Foundation**: Hardware platform support
- **Android Developers**: Mobile integration capabilities

---

**Kilo Truck** - Professional-grade autonomous RC car platform with advanced control systems and real-time integration.