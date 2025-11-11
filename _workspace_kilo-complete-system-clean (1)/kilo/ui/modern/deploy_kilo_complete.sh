#!/bin/bash
# Kilo Truck - Complete Clean Deployment
# One-command setup for Raspberry Pi + Pixel 4a integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚗 Kilo Truck - Complete Clean Deployment${NC}"
echo "=========================================="

# Configuration
PI_STATIC_IP="10.0.50.100"
PHONE_STATIC_IP="10.0.50.101"
VIAM_API_ID="f1a41a1c-49de-4c28-9e25-b10e71632536"
VIAM_API_KEY="xfmo4x2lux52aku0hllrale5lfztomhq"
VIAM_MACHINE="kilo-test-main.id4wy89fqq.viam.cloud"

echo -e "${YELLOW}Step 1: System Preparation${NC}"

# Update system
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essentials
echo "Installing essential packages..."
sudo apt install -y curl wget git jq python3 python3-pip python3-venv \
    build-essential i2c-tools raspi-config net-tools

# Enable I2C and Camera
echo "Enabling I2C and camera interfaces..."
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_camera 0

echo -e "${GREEN}✓ System preparation complete${NC}"

echo -e "${YELLOW}Step 2: Network Configuration${NC}"

# Backup original network config
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.backup.$(date +%s) 2>/dev/null || true

# Configure static IP for Pi
echo "Configuring static IP: $PI_STATIC_IP"
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF

# Kilo Truck Static Configuration
interface wlan0
static ip_address=$PI_STATIC_IP/24
static routers=10.0.50.1
static domain_name_servers=10.0.50.1 8.8.8.8
EOF

# Configure network routing for dual connectivity
echo "Setting up dual network routing..."
sudo tee /etc/systemd/system/kilo-network.service > /dev/null <<EOF
[Unit]
Description=Kilo Network Management
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'ip route add $PHONE_STATIC_IP/32 dev usb0 2>/dev/null || true; ip route replace default via 10.0.50.1 dev wlan0 2>/dev/null || true'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}✓ Network configuration complete${NC}"

echo -e "${YELLOW}Step 3: Viam Installation${NC}"

# Install Viam agent
echo "Installing Viam agent..."
curl -sSL https://docs.viam.com/get-started/try-viam.sh | bash

# Configure Viam credentials
echo "Configuring Viam credentials..."
sudo tee /etc/viam.json > /dev/null <<CONF
{
  "cloud": {
    "app_address": "https://app.viam.com:443",
    "id": "$VIAM_API_ID",
    "secret": "$VIAM_API_KEY"
  }
}
CONF

echo -e "${GREEN}✓ Viam installation complete${NC}"

echo -e "${YELLOW}Step 4: Android IMU Module${NC}"

# Create directory structure
echo "Creating module directories..."
sudo mkdir -p /opt/kilo/{modules,bin,config,logs,web}
sudo chown -R pi:pi /opt/kilo

# Install fixed Android IMU module
echo "Installing Android IMU module..."
sudo mkdir -p /opt/kilo/modules/android-imu

sudo tee /opt/kilo/modules/android-imu/android_imu_module.py > /dev/null <<'PY'
#!/usr/bin/env python3
import asyncio, os, time, logging
from typing import Optional
import aiohttp
from viam.module.module import Module
from viam.components.movement_sensor import MovementSensor
from viam.resource.base import ResourceBase
from viam.resource.registry import Registry, ResourceCreatorRegistration
from viam.proto.common import Vector3

logging.basicConfig(level=logging.INFO)
log=logging.getLogger("android-imu")

class AndroidIMU(MovementSensor, ResourceBase):
    MODEL="kilo:movement_sensor:android-imu"
    def __init__(self, name:str):
        super().__init__(name)
        self._latest={"ax":0.0,"ay":0.0,"az":9.8,"gx":0.0,"gy":0.0,"gz":0.0}
        self._task: Optional[asyncio.Task] = None
        self._session: Optional[aiohttp.ClientSession]=None
        self._host=os.getenv("ANDROID_HOST","10.0.50.101")
        self._port=os.getenv("ANDROID_PORT","8080")
        self._path=os.getenv("ANDROID_IMU_PATH","/imu")

    async def _poll(self):
        self._session=aiohttp.ClientSession()
        backoff=0.5
        while True:
            try:
                url=f"http://{self._host}:{self._port}{self._path}"
                async with self._session.get(url, timeout=aiohttp.ClientTimeout(total=2)) as r:
                    if r.status==200:
                        d=await r.json()
                        if "linear_acceleration" in d and "angular_velocity" in d:
                            la=d["linear_acceleration"]; av=d["angular_velocity"]
                            self._latest.update({
                                "ax":float(la.get("x",0.0)),"ay":float(la.get("y",0.0)),"az":float(la.get("z",9.8)),
                                "gx":float(av.get("x",0.0)),"gy":float(av.get("y",0.0)),"gz":float(av.get("z",0.0))})
                        else:
                            self._latest.update({
                                "ax":float(d.get("ax",0.0)),"ay":float(d.get("ay",0.0)),"az":float(d.get("az",9.8)),
                                "gx":float(d.get("gx",0.0)),"gy":float(d.get("gy",0.0)),"gz":float(d.get("gz",0.0))})
                        backoff=0.5
                    else:
                        log.warning("IMU HTTP %s", r.status)
            except Exception as e:
                log.warning("IMU poll error: %s", e)
                await asyncio.sleep(backoff)
                backoff=min(backoff*1.7,5.0)
                continue
            await asyncio.sleep(0.01)

    async def reconfigure(self, config, dependencies):
        attrs=(config.attributes or {})
        self._host=str(attrs.get("host", self._host))
        self._port=str(attrs.get("port", self._port))
        self._path=str(attrs.get("path", self._path))
        if not self._task:
            self._task=asyncio.create_task(self._poll())

    async def get_linear_acceleration(self, **kwargs)->Vector3:
        l=self._latest; return Vector3(x=l["ax"],y=l["ay"],z=l["az"])

    async def get_angular_velocity(self, **kwargs)->Vector3:
        l=self._latest; return Vector3(x=l["gx"],y=l["gy"],z=l["gz"])

    async def get_properties(self, **kwargs):
        return {"linear_acceleration_supported":True,"angular_velocity_supported":True,"orientation_supported":False}

async def factory(name, cfg, deps):
    obj=AndroidIMU(name)
    await obj.reconfigure(cfg, deps)
    return obj

def main():
    reg=Registry()
    reg.register_resource_creator(MovementSensor.get_resource_name("movement_sensor"), AndroidIMU.MODEL, ResourceCreatorRegistration(factory))
    Module.register(reg)
    Module.run()

if __name__=="__main__":
    main()
PY

# Create launcher
sudo tee /opt/kilo/modules/android-imu/android_imu > /dev/null <<'SH'
#!/usr/bin/env bash
exec python3 /opt/kilo/modules/android-imu/android_imu_module.py
SH

sudo chmod +x /opt/kilo/modules/android-imu/android_imu

# Install Python dependencies
echo "Installing Python dependencies..."
python3 -m pip install --user -U viam-sdk aiohttp websockets piper-tts pyyaml

echo -e "${GREEN}✓ Android IMU module complete${NC}"

echo -e "${YELLOW}Step 5: Personality Engine${NC}"

# Create personality environment
echo "Setting up personality environment..."
python3 -m venv /opt/kilo/personality
source /opt/kilo/personality/bin/activate
pip install -U viam-sdk aiohttp websockets piper-tts pyyaml
deactivate

# Create personality engine
sudo tee /opt/kilo/bin/kilo_personality.py > /dev/null <<'PY'
#!/usr/bin/env python3
"""
Clean Kilo Personality Engine
Integrates with Pixel 4a app for eyes, audio, and sensors
"""

import asyncio
import json
import logging
import os
from pathlib import Path
import aiohttp
import websockets
import grpc
from viam.rpc.dial import DialOptions
from viam.app.viam_client import ViamClient

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("kilo-personality")

class KiloPersonality:
    def __init__(self):
        self.phone_host = "10.0.50.101"
        self.phone_port = "8080"
        self.viam_client = None
        self.state = {
            "emotion": "happy",
            "snark_level": 0.0,
            "faces_seen": {}
        }
        
    async def connect_to_viam(self):
        """Connect to local Viam agent"""
        try:
            self.viam_client = await ViamClient.create_from_dial_options(
                dial_options=DialOptions(address="localhost:8080")
            )
            logger.info("Connected to Viam")
        except Exception as e:
            logger.error(f"Failed to connect to Viam: {e}")
            
    async def watch_phone_sensors(self):
        """Monitor phone sensors for triggers"""
        while True:
            try:
                # Check for face detection
                async with aiohttp.ClientSession() as session:
                    async with session.get(f"http://{self.phone_host}:{self.phone_port}/faces", timeout=2) as response:
                        if response.status == 200:
                            face_data = await response.json()
                            await self.handle_face_detection(face_data)
                await asyncio.sleep(1)
            except Exception as e:
                logger.debug(f"Sensor monitoring error: {e}")
                await asyncio.sleep(5)
                
    async def handle_face_detection(self, face_data):
        """Handle face detection from phone"""
        if face_data.get("faces"):
            face = face_data["faces"][0]
            face_id = face.get("id", "unknown")
            
            if face_id not in self.state["faces_seen"]:
                self.state["faces_seen"][face_id] = {
                    "name": face.get("name", "Person"),
                    "first_seen": asyncio.get_event_loop().time(),
                    "greeting_count": 0
                }
                
                await self.trigger_greeting(face.get("name", "Person"))
                
            self.state["faces_seen"][face_id]["last_seen"] = asyncio.get_event_loop().time()
            
    async def trigger_greeting(self, name):
        """Generate and send greeting"""
        self.state["snark_level"] = min(self.state["snark_level"] + 0.1, 1.0)
        
        if self.state["snark_level"] < 0.3:
            text = f"Hello {name}! Nice to see you!"
            emotion = "happy"
        elif self.state["snark_level"] < 0.6:
            text = f"Oh, {name} again. What do you want?"
            emotion = "confused"
        elif self.state["snark_level"] < 0.8:
            text = f"{name}. Seriously? Fine."
            emotion = "sad"
        else:
            text = f"You know what, {name}? Go away."
            emotion = "angry"
            
        await self.send_to_phone_eyes(emotion)
        await self.send_to_phone_tts(text)
        
    async def send_to_phone_eyes(self, emotion):
        """Send emotion to phone eyes display"""
        try:
            async with aiohttp.ClientSession() as session:
                payload = {"type": "emotion", "emotion": emotion}
                async with session.post(f"http://{self.phone_host}:{self.phone_port}/eyes", json=payload) as response:
                    if response.status == 200:
                        logger.info(f"Set eyes emotion to: {emotion}")
        except Exception as e:
            logger.error(f"Failed to send eyes command: {e}")
                    
    async def send_to_phone_tts(self, text):
        """Send text to phone TTS"""
        try:
            async with aiohttp.ClientSession() as session:
                payload = {"text": text, "voice": "default"}
                async with session.post(f"http://{self.phone_host}:{self.phone_port}/tts", json=payload) as response:
                    if response.status == 200:
                        logger.info(f"Spoke: {text}")
        except Exception as e:
            logger.error(f"Failed to send TTS command: {e}")
                    
    async def run(self):
        """Main event loop"""
        await asyncio.gather(
            self.connect_to_viam(),
            self.watch_phone_sensors()
        )

async def main():
    personality = KiloPersonality()
    await personality.run()

if __name__ == "__main__":
    asyncio.run(main())
PY

sudo chmod +x /opt/kilo/bin/kilo_personality.py

echo -e "${GREEN}✓ Personality engine complete${NC}"

echo -e "${YELLOW}Step 6: System Services${NC}"

# Create personality service
sudo tee /etc/systemd/system/kilo-personality.service > /dev/null <<'EOF'
[Unit]
Description=Kilo Personality Engine
After=viam-agent.service
Wants=viam-agent.service

[Service]
Type=simple
User=pi
WorkingDirectory=/opt/kilo
Environment=PYTHONPATH=/opt/kilo/personality/lib/python3.13/site-packages
ExecStart=/opt/kilo/personality/bin/python3 /opt/kilo/bin/kilo_personality.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable services
echo "Enabling system services..."
sudo systemctl daemon-reload
sudo systemctl enable kilo-personality kilo-network viam-agent

echo -e "${GREEN}✓ System services configured${NC}"

echo -e "${YELLOW}Step 7: Status Check${NC}"

# Create status check script
sudo tee /opt/kilo/bin/kilo_status > /dev/null <<'STATUS'
#!/bin/bash
echo "🚗 Kilo Truck Status Check"
echo "=========================="

# Check Viam
echo -n "Viam Agent: "
if systemctl is-active --quiet viam-agent; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Check personality
echo -n "Personality: "
if systemctl is-active --quiet kilo-personality; then
    echo "✓ Running"
else
    echo "✗ Stopped"
fi

# Check network
echo -n "Network: "
if systemctl is-active --quiet kilo-network; then
    echo "✓ Configured"
else
    echo "✗ Not configured"
fi

# Test connectivity
echo -e "\nConnectivity Tests:"
echo -n "Pi IP (10.0.50.100): "
if ping -c 1 10.0.50.100 >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -n "Phone IP (10.0.50.101): "
if ping -c 1 10.0.50.101 >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -n "Viam API: "
if curl -s http://localhost:8080/api/v1/health >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -n "Phone Health: "
if curl -s http://10.0.50.101:8080/health >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -e "\nServices running on:"
echo "  - Viam Agent: http://localhost:8080"
echo "  - Viam Cloud: https://app.viam.com/machines/kilo-test-main.id4wy89fqq.viam.cloud"
echo "  - Phone App: http://10.0.50.101:8080"
STATUS

sudo chmod +x /opt/kilo/bin/kilo_status

echo -e "${GREEN}✓ Status check script created${NC}"

echo -e "${YELLOW}Step 8: Starting Services${NC}"

# Start services
echo "Starting all services..."
sudo systemctl restart viam-agent
sudo systemctl start kilo-network
sudo systemctl start kilo-personality

# Wait for services to start
sleep 5

echo -e "${GREEN}✓ Services started${NC}"

echo -e "${YELLOW}Step 9: Final Verification${NC}"

# Run status check
echo "Running final status check..."
/opt/kilo/bin/kilo_status

echo -e "\n${GREEN}🎉 Kilo Truck Deployment Complete!${NC}"
echo -e "\n${BLUE}Next Steps:${NC}"
echo "1. Reboot the Pi to apply network configuration: ${YELLOW}sudo reboot${NC}"
echo "2. Configure your Pixel 4a with static USB IP: ${YELLOW}$PHONE_STATIC_IP${NC}"
echo "3. Install and run the Flutter app with the required HTTP endpoints"
echo "4. Go to Viam web UI and add the android-imu module"
echo "5. Add pixel_imu component with correct model and attributes"
echo -e "\n${BLUE}Required App Endpoints:${NC}"
echo "  GET  /health    - Status check"
echo "  GET  /imu       - IMU sensor data"
echo "  GET  /faces     - Face detection results"
echo "  POST /eyes      - Eye control (emotion)"
echo "  POST /tts       - Text-to-speech"
echo -e "\n${BLUE}Quick Commands:${NC}"
echo "  Check status: ${YELLOW}/opt/kilo/bin/kilo_status${NC}"
echo "  View logs: ${YELLOW}sudo journalctl -u kilo-personality -f${NC}"
echo "  Restart personality: ${YELLOW}sudo systemctl restart kilo-personality${NC}"

echo -e "\n${GREEN}System is now rebuildable from scratch!${NC}"