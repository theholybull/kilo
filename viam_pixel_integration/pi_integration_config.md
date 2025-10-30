# Pi Integration Configuration Guide

## Overview
This guide explains how to integrate the Android app with your Raspberry Pi for direct USB connection and Viam module replacement.

## USB Connection Setup

### Android Phone Configuration
1. Enable USB tethering on the Pixel 4a:
   - Settings → Network & Internet → Hotspot & tethering → USB tethering
   - This creates a network interface (usually `rndis0`)

2. Network Configuration:
   - Phone IP: 10.10.10.x (usually 10.10.10.1)
   - Pi IP: 10.10.10.67 (from your Pi info)
   - Subnet: 255.255.255.0

### Raspberry Pi Configuration
1. Update `/etc/network/interfaces` to handle USB connection:
   ```bash
   auto rndis0
   iface rndis0 inet static
   address 10.10.10.67
   netmask 255.255.255.0
   gateway 10.10.10.1
   ```

2. Restart networking:
   ```bash
   sudo systemctl restart networking
   ```

## Viam Configuration Updates

### Updated Viam JSON for Phone Integration
Replace your current `oak_imu` section with phone sensors and add new phone components:

```json
{
  "components": [
    // Keep existing components except oak_imu
    {
      "name": "phone_imu",
      "api": "rdk:component:movement_sensor",
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "phone_sensors",
        "data_source": "accelerometer,gyroscope,magnetometer"
      },
      "depends_on": ["phone_connection"]
    },
    
    {
      "name": "phone_front_camera",
      "api": "rdk:component:camera",
      "model": "rdk:builtin:webcam",
      "attributes": {
        "integration_type": "phone_camera",
        "camera_id": "front",
        "width_px": 1920,
        "height_px": 1080,
        "frame_rate": 30
      },
      "depends_on": ["phone_connection"]
    },
    
    {
      "name": "phone_rear_camera", 
      "api": "rdk:component:camera",
      "model": "rdk:builtin:webcam",
      "attributes": {
        "integration_type": "phone_camera",
        "camera_id": "rear",
        "width_px": 1920,
        "height_px": 1080,
        "frame_rate": 30
      },
      "depends_on": ["phone_connection"]
    },
    
    {
      "name": "phone_microphone",
      "api": "rdk:component:input",
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "phone_audio",
        "audio_type": "microphone",
        "sample_rate": 44100,
        "channels": 2
      },
      "depends_on": ["phone_connection"]
    },
    
    {
      "name": "phone_speaker",
      "api": "rdk:component:output", 
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "phone_audio",
        "audio_type": "speaker",
        "sample_rate": 44100,
        "channels": 2
      },
      "depends_on": ["phone_connection"]
    },
    
    {
      "name": "phone_display",
      "api": "rdk:component:board",
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "phone_display",
        "width_px": 1080,
        "height_px": 2340,
        "emotions": true,
        "face_tracking": true
      },
      "depends_on": ["phone_connection"]
    },
    
    {
      "name": "phone_connection",
      "api": "rdk:component:board",
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "usb_connection",
        "phone_ip": "10.10.10.1",
        "pi_ip": "10.10.10.67",
        "connection_port": 8080
      }
    }
  ],
  
  "services": [
    // Update existing services to use phone components
    
    {
      "name": "face_recognition",
      "api": "rdk:service:vision",
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "phone_face_detection",
        "camera_name": "phone_front_camera",
        "face_tracking": true,
        "emotion_detection": true
      },
      "depends_on": ["phone_front_camera", "phone_display"]
    },
    
    {
      "name": "phone_communication",
      "api": "rdk:service:generic",
      "model": "rdk:builtin:fake",
      "attributes": {
        "integration_type": "phone_communication",
        "microphone_name": "phone_microphone",
        "speaker_name": "phone_speaker",
        "speech_recognition": true,
        "text_to_speech": true
      },
      "depends_on": ["phone_microphone", "phone_speaker"]
    }
  ],
  
  "modules": [
    // Remove oak-bmi270-imu module since we're using phone sensors
    
    // Keep existing modules except the problematic one
    {
      "type": "registry",
      "name": "raspberry_pi_module",
      "module_id": "viam:raspberry-pi",
      "version": "latest"
    },
    
    // Add phone integration module (this would be the Android app)
    {
      "type": "local",
      "name": "phone_integration",
      "executable_path": "/opt/viam/phone_integration/phone_viam_module"
    }
  ]
}
```

## Android App Auto-Start Configuration

### Boot Configuration
The app includes:
- `BootReceiver.kt` - Handles BOOT_COMPLETED broadcast
- `ViamBackgroundService.kt` - Foreground service for persistent connection
- `UsbReceiver.kt` - Handles USB attach/detach events

### Required Android Permissions
- `FOREGROUND_SERVICE` - Background service
- `RECEIVE_BOOT_COMPLETED` - Auto-start on boot
- `USB_HOST` - USB device access
- `SYSTEM_ALERT_WINDOW` - Overlay permissions
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` - Prevent battery optimization

## Integration Workflow

### 1. Initial Setup
1. Install the app on Pixel 4a
2. Enable USB debugging
3. Connect phone to Pi via USB
4. Enable USB tethering

### 2. Connection Process
1. App auto-starts on boot
2. USB attachment triggers connection scan
3. Discovers Pi at 10.10.10.67
4. Establishes gRPC connection to viam-agent (port 8080)
5. Registers as Viam module
6. Exposes phone components to Viam

### 3. Component Replacement
- **IMU**: Phone sensors replace OAK IMU
- **Cameras**: Phone cameras work alongside OAK-D
- **Audio**: Phone mics/speakers for communication
- **Display**: Shows emotions and tracking visuals

## Testing the Integration

### 1. USB Connection Test
```bash
# On Pi, test phone connectivity
ping 10.10.10.1
telnet 10.10.10.1 8080
```

### 2. Viam Component Test
```bash
# Test if phone components are registered
curl http://localhost:8080/resources
```

### 3. Sensor Data Test
- Open the Android app
- Check Pi connection status
- Verify sensor data streaming
- Test face detection and emotion display

## Troubleshooting

### Common Issues

**USB Connection Not Working**
- Check USB cable is data-capable
- Verify USB tethering is enabled
- Check network interface: `ip addr show rndis0`

**Viam Connection Failed**
- Verify viam-agent is running: `systemctl status viam-agent`
- Check port 8080 is accessible: `netstat -tlnp | grep 8080`
- Check firewall settings

**Components Not Registered**
- Review Viam JSON syntax
- Check dependency chains
- Verify module execution path

**App Not Auto-Starting**
- Check boot receiver permissions
- Verify app is not optimized by battery settings
- Check Android system logs: `logcat | grep Viam`

## Performance Considerations

### Network Optimization
- Use wired USB connection for reliability
- Monitor latency: should be