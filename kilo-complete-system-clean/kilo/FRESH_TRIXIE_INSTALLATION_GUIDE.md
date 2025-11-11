# Kilo Truck - Fresh Trixie Installation Guide

## 🚀 Complete System Setup for Debian Trixie

This guide provides step-by-step instructions for installing the complete Kilo Truck system on a fresh Debian Trixie installation.

---

## 📋 Prerequisites

### Hardware Requirements
- Raspberry Pi 4 (8GB recommended)
- MicroSD card (32GB+ Class 10)
- PCA9685 servo controller board
- OAK-D camera (optional, phone IMU used instead)
- Pixel 4a Android phone with USB cable
- Power supply for Pi and phone

### Software Requirements
- Fresh Debian Trixie installation
- Internet connection for initial setup
- GitHub access (`theholybull/kilo` repository)

---

## 🔧 System Preparation

### 1. Update System Packages
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget vim htop
```

### 2. Clone Repository
```bash
# Clone the complete Kilo Truck repository
cd /opt
sudo git clone https://github.com/theholybull/kilo.git
sudo chown -R $USER:$USER /opt/kilo
cd /opt/kilo
```

### 3. Install Python Dependencies
```bash
sudo apt install -y python3 python3-pip python3-venv
python3 -m venv /opt/kilo/venv
source /opt/kilo/venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt  # If requirements.txt exists
```

---

## 🤖 Viam Installation

### 1. Install Viam Agent
```bash
# Add Viam repository
curl -sSL https://storage.googleapis.com/packages.viam.com/debian/public.key | sudo apt-key add -
echo "deb https://storage.googleapis.com/packages.viam.com/debian stable main" | sudo tee /etc/apt/sources.list.d/viam.list

# Install Viam
sudo apt update
sudo apt install -y viam-agent
```

### 2. Configure Viam
```bash
# Create Viam directories
sudo mkdir -p /etc/viam /opt/viam/maps

# Copy Viam configuration
sudo cp /opt/kilo/viam_json_patch.json /etc/viam/robot.json
```

---

## 📱 Android Integration Setup

### 1. Install Android IMU Module
```bash
# Create module directory
sudo mkdir -p /opt/kilo/modules/android-imu

# Copy fixed Android IMU module
sudo cp /opt/kilo/fixed_android_imu_v2.py /opt/kilo/modules/android-imu/android_imu.py
sudo chmod +x /opt/kilo/modules/android-imu/android_imu.py

# Create systemd service
sudo tee /etc/systemd/system/kilo-android-imu.service > /dev/null <<EOF
[Unit]
Description=Kilo Android IMU Module
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/kilo/venv/bin/python /opt/kilo/modules/android-imu/android_imu.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable kilo-android-imu
sudo systemctl start kilo-android-imu
```

### 2. Install Phone Discovery Utility
```bash
sudo cp /opt/kilo/discover-android-ip /opt/kilo/bin/discover-android-ip
sudo chmod +x /opt/kilo/bin/discover-android-ip
sudo mkdir -p /opt/kilo/bin
```

---

## 🎭 Personality System Installation

### 1. Install Personality Daemon
```bash
# Create personality directories
sudo mkdir -p /opt/kilo/personality
sudo mkdir -p /var/lib/kilo/snaps
sudo mkdir -p /opt/kilo/docs

# Copy personality files
sudo cp /opt/kilo/personality/personalityd.py /opt/kilo/personality/
sudo cp /opt/kilo/personality/persona.json /opt/kilo/personality/
sudo cp /opt/kilo/personality/people.json /opt/kilo/personality/
sudo cp /opt/kilo/personality/quips.yaml /opt/kilo/personality/

# Install TTS system (kilosay)
sudo cp /opt/kilo/kilosay /usr/local/bin/kilosay
sudo chmod +x /usr/local/bin/kilosay

# Create personality service
sudo tee /etc/systemd/system/kilo-personality.service > /dev/null <<EOF
[Unit]
Description=Kilo Personality Daemon
After=network.target

[Service]
Type=simple
User=kilo
ExecStart=/opt/kilo/venv/bin/python /opt/kilo/personality/personalityd.py
Restart=always
RestartSec=5
Environment=KILO_PERSONALITY_DIR=/opt/kilo/personality
Environment=KILO_AUTOSPEAK=1

[Install]
WantedBy=multi-user.target
EOF

# Create kilo user if needed
sudo useradd -r -s /bin/false kilo 2>/dev/null || true
sudo chown -R kilo:kilo /opt/kilo/personality /var/lib/kilo /opt/kilo/docs

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable kilo-personality
sudo systemctl start kilo-personality
```

---

## 🌐 Modern UI System Installation

### 1. Install Modern UI
```bash
# Copy UI files
sudo cp /opt/kilo/kilo/ui/modern/kilo_ui_modern.py /opt/kilo/bin/
sudo cp /opt/kilo/kilo/ui/modern/kilo_ui_realtime.py /opt/kilo/bin/
sudo cp /opt/kilo/kilo/ui/modern/kilo_ui_enhanced.html /opt/kilo/www/
sudo chmod +x /opt/kilo/bin/kilo_ui_modern.py
sudo chmod +x /opt/kilo/bin/kilo_ui_realtime.py

# Create web directory
sudo mkdir -p /opt/kilo/www

# Install UI dependencies
sudo apt install -y nginx

# Configure UI services
sudo tee /etc/systemd/system/kilo-ui-modern.service > /dev/null <<EOF
[Unit]
Description=Kilo Modern UI
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/kilo/venv/bin/python /opt/kilo/bin/kilo_ui_modern.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/kilo-ui-realtime.service > /dev/null <<EOF
[Unit]
Description=Kilo Realtime UI
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/kilo/venv/bin/python /opt/kilo/bin/kilo_ui_realtime.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable kilo-ui-modern kilo-ui-realtime
sudo systemctl start kilo-ui-modern kilo-ui-realtime
```

### 2. Configure Nginx
```bash
# Create Nginx configuration
sudo tee /etc/nginx/sites-available/kilo-ui > /dev/null <<EOF
server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /ws {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/kilo-ui /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx
```

---

## 📡 Network Configuration

### 1. Setup Network with Failover
```bash
# Make network setup script executable
sudo chmod +x /opt/kilo/network_setup_script.sh

# Run network configuration
sudo /opt/kilo/network_setup_script.sh

# Configure static USB tethering
sudo tee /etc/network/interfaces.d/usb-tethering > /dev/null <<EOF
auto usb0
iface usb0 inet static
    address 192.168.42.42
    netmask 255.255.255.0
    gateway 192.168.42.129
EOF
```

---

## 🔗 App Communication Bridges

### 1. Install Android Bridges
```bash
# Copy bridge scripts
sudo cp /opt/kilo/android_*bridge*.py /opt/kilo/bin/
sudo chmod +x /opt/kilo/bin/android_*bridge*.py

# Create bridge services
sudo tee /etc/systemd/system/kilo-android-eyes.service > /dev/null <<EOF
[Unit]
Description=Kilo Android Eyes Bridge
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/kilo/venv/bin/python /opt/kilo/bin/android_eyes_bridge.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/kilo-android-face.service > /dev/null <<EOF
[Unit]
Description=Kilo Android Face Bridge
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/kilo/venv/bin/python /opt/kilo/bin/android_face_bridge.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable kilo-android-eyes kilo-android-face
sudo systemctl start kilo-android-eyes kilo-android-face
```

---

## 🎛️ Ackermann Steering Module

### 1. Install Go Dependencies
```bash
# Install Go
sudo apt install -y golang-go

# Build Ackermann module
cd /opt/kilo/kilo/modules/ackermann-pwm-base
go build -o ackermann
sudo cp ackermann /opt/kilo/bin/
```

### 2. Configure Module for Viam
```bash
# Create module directory structure
sudo mkdir -p /opt/kilo/modules/ackermann-pwm-base
sudo cp -r /opt/kilo/kilo/modules/ackermann-pwm-base/* /opt/kilo/modules/ackermann-pwm-base/

# Update Viam configuration to include ackermann module
# This is already included in viam_json_patch.json
```

---

## 🔥 Firewall and Security

### 1. Configure Firewall
```bash
# Install and configure UFW
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow necessary ports
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 8080  # Kilo UI
sudo ufw allow 8081  # Kilo Realtime

# Enable firewall
sudo ufw enable
```

---

## 🚀 Final System Startup

### 1. Start All Services
```bash
# Start Viam agent
sudo systemctl start viam-agent
sudo systemctl enable viam-agent

# Start all Kilo services
sudo systemctl start kilo-android-imu
sudo systemctl start kilo-personality
sudo systemctl start kilo-ui-modern
sudo systemctl start kilo-ui-realtime
sudo systemctl start kilo-android-eyes
sudo systemctl start kilo-android-face

# Enable all services to start on boot
sudo systemctl enable viam-agent
sudo systemctl enable kilo-android-imu
sudo systemctl enable kilo-personality
sudo systemctl enable kilo-ui-modern
sudo systemctl enable kilo-ui-realtime
sudo systemctl enable kilo-android-eyes
sudo systemctl enable kilo-android-face
```

### 2. Verify Installation
```bash
# Check service status
sudo systemctl status viam-agent kilo-android-imu kilo-personality kilo-ui-modern

# Check network connectivity
ping -c 3 8.8.8.8

# Check Android phone connection
sudo /opt/kilo/bin/discover-android-ip

# Access web interface
echo "Access Kilo Truck UI at: http://$(hostname -I | awk '{print $1}'):8080"
```

---

## 📱 Android Phone Setup

### 1. Install Flutter App
1. Download the Kilo Truck Flutter app to your Pixel 4a
2. Enable USB tethering in Settings > Network & Internet > Hotspot & tethering
3. Connect phone to Pi via USB cable
4. Verify app is running on port 8080

### 2. Test Integration
```bash
# Test phone connectivity
curl http://$(/opt/kilo/bin/discover-android-ip):8080/health

# Test IMU data
curl http://$(/opt/kilo/bin/discover-android-ip):8080/imu

# Test face detection
curl http://$(/opt/kilo/bin/discover-android-ip):8080/faces
```

---

## 🔧 Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   sudo journalctl -u service-name -f  # Check logs
   sudo systemctl restart service-name  # Restart service
   ```

2. **Android phone not connecting**
   ```bash
   # Check USB tethering
   ip addr show usb0
   
   # Discover phone manually
   sudo nmap -p 8080 192.168.42.0/24
   ```

3. **Viam configuration issues**
   ```bash
   # Validate JSON
   cat /etc/viam/robot.json | jq .
   
   # Check Viam logs
   sudo journalctl -u viam-agent -f
   ```

4. **Web interface not accessible**
   ```bash
   # Check Nginx status
   sudo systemctl status nginx
   
   # Check UI service
   sudo systemctl status kilo-ui-modern
   
   # Check port binding
   sudo netstat -tlnp | grep 8080
   ```

### Log Locations
- Viam: `sudo journalctl -u viam-agent -f`
- Personality: `/opt/kilo/personality/kilo.sock` and state file
- Android IMU: `sudo journalctl -u kilo-android-imu -f`
- UI: `sudo journalctl -u kilo-ui-modern -f`

---

## 🎉 Installation Complete!

Your Kilo Truck system is now fully installed and ready for operation:

- **Web Interface**: http://your-pi-ip:8080
- **Real-time Updates**: WebSocket on port 8081
- **Android Integration**: Automatic phone discovery
- **Personality System**: Full voice and animation support
- **Viam Robotics**: Complete navigation and SLAM capabilities

### Next Steps
1. Connect your Pixel 4a via USB and enable tethering
2. Access the web interface to verify all systems
3. Configure your robot base and sensors in Viam
4. Start exploring with your fully autonomous Kilo Truck!

---

## 📞 Support

For issues or questions:
- Check logs with `journalctl`
- Verify configurations match this guide
- Ensure all services are running: `systemctl status`
- Consult the project documentation in `/opt/kilo/docs/`

**Enjoy your Kilo Truck! 🚚✨**