# Viam Pixel 4a App - Usage Guide

## What the App Looks Like

### Main Dashboard
When the app launches, you'll see a comprehensive dashboard with multiple sections:

```
┌─────────────────────────────────────┐
│   Viam Pi Integration               │
├─────────────────────────────────────┤
│                                     │
│  📱 Pi Connection Status            │
│  ● Searching for Pi...              │
│  IP: 10.10.10.67                    │
│  [Disconnect]                       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🤖 Emotional Display               │
│  [Two animated eyes showing         │
│   current emotion state]            │
│  Current: Happy                     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📹 Camera Preview                  │
│  [Live camera feed]                 │
│  Face Detection: ON                 │
│  Faces Detected: 1                  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📊 Sensor Data                     │
│  Accelerometer: X:0.1 Y:0.2 Z:9.8   │
│  Gyroscope: X:0.0 Y:0.0 Z:0.0       │
│  Location: 37.7749, -122.4194       │
│  Battery: 85%                       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🎤 Audio Controls                  │
│  [Record] [Play] [Stop]             │
│  Status: Ready                      │
│                                     │
└─────────────────────────────────────┘
```

## How to Use the App

### 1. First Launch

**What Happens:**
- App requests permissions (Camera, Microphone, Location, etc.)
- Tap "Allow" for each permission
- App starts all sensors automatically
- Begins searching for Raspberry Pi via USB

**What You'll See:**
- Permission dialogs (tap Allow on each)
- "Searching for Pi..." status
- Sensor data starts updating
- Camera preview activates

### 2. Connect to Raspberry Pi

**USB Connection:**
1. Connect Pixel 4a to Raspberry Pi via USB cable
2. Enable USB tethering on phone:
   - Settings → Network & Internet → Hotspot & Tethering → USB Tethering
3. App automatically discovers Pi at 10.10.10.67
4. Connection status changes to "Connected"

**What You'll See:**
- "Searching for Pi..." → "Connected to Pi"
- Green indicator light
- Pi IP address displayed
- Viam connection status updates

### 3. Using Features

#### A. Emotional Display (Robot Eyes)
**Purpose:** Shows robot's emotional state

**How It Works:**
- Eyes animate automatically based on:
  - Face detection (looks at detected faces)
  - Conversation state
  - Robot personality
  - Steering wheel direction

**Emotions Available:**
- 😊 Happy
- 😢 Sad
- 😮 Surprised
- 😠 Angry
- 😴 Sleepy
- 🤔 Thinking
- 😐 Neutral
- 😨 Scared
- 😍 Love
- 🤪 Silly

**Controls:**
- Tap emotion name to change manually
- Auto mode follows face tracking

#### B. Face Detection
**Purpose:** Detects and tracks faces for interaction

**How It Works:**
- Camera continuously scans for faces
- Draws bounding boxes around detected faces
- Tracks face position and movement
- Eyes follow the detected face

**What You'll See:**
- Green boxes around detected faces
- Face count displayed
- Confidence score (0-100%)
- Eyes tracking face movement

**Controls:**
- Toggle face detection ON/OFF
- Switch between front/back camera
- Adjust detection sensitivity

#### C. Sensor Data
**Purpose:** Provides IMU and environmental data to Viam

**Sensors Active:**
- **Accelerometer:** Motion and orientation (100Hz)
- **Gyroscope:** Rotation rate (100Hz)
- **Magnetometer:** Compass heading
- **GPS:** Location coordinates
- **Battery:** Charge level and status
- **Network:** Connection status

**What You'll See:**
- Real-time sensor values updating
- Graphs showing sensor trends
- Data rate (updates per second)
- Connection status to Viam

**No Controls Needed:**
- Sensors run automatically
- Data streams to Viam continuously

#### D. Audio Communication
**Purpose:** Professional microphone and speaker interface

**Features:**
- High-quality audio recording
- Playback through phone speakers
- Voice command processing
- Two-way communication

**Controls:**
- 🔴 **Record:** Start recording audio
- ⏹️ **Stop:** Stop recording
- ▶️ **Play:** Play recorded audio
- 🔊 **Volume:** Adjust playback volume

**What You'll See:**
- Recording duration timer
- Audio waveform visualization
- Volume level meter
- Recording status

#### E. Camera Controls
**Purpose:** Manage camera for face detection and vision

**Controls:**
- 🔄 **Switch Camera:** Toggle front/back
- ⚡ **Flash:** Auto/On/Off/Torch
- 📸 **Capture:** Take photo
- 🎥 **Record:** Record video
- 🔍 **Zoom:** Pinch to zoom

**What You'll See:**
- Live camera preview
- Flash mode indicator
- Recording indicator (red dot)
- Zoom level

### 4. Background Operation

**Auto-Start on Boot:**
- App starts automatically when phone boots
- Connects to Pi automatically if USB connected
- Runs in background continuously

**Foreground Service:**
- Notification shows "Viam Pi Integration Running"
- Tap notification to open app
- Service keeps sensors active
- Maintains Pi connection

**Battery Optimization:**
- Request to disable battery optimization
- Ensures app stays running
- Prevents Android from killing service

### 5. Viam Integration

**What Gets Exposed to Viam:**

1. **IMU Sensor Component:**
   - Replaces OAK-D BMI270 IMU
   - Provides accelerometer, gyroscope, magnetometer
   - 100Hz update rate
   - More accurate than OAK IMU

2. **Camera Component:**
   - Dual camera support (front + back)
   - Face detection data
   - Image capture
   - Video streaming

3. **Audio Component:**
   - Microphone input
   - Speaker output
   - Voice commands
   - Two-way communication

4. **Emotion Display Component:**
   - Eye animation control
   - Emotion state
   - Face tracking
   - Personality expression

5. **Location Component:**
   - GPS coordinates
   - Movement tracking
   - Navigation data

**Accessing from Viam:**
```python
# Example: Access phone sensors from Viam
from viam.components.movement_sensor import MovementSensor

# Get IMU data
imu = MovementSensor.from_robot(robot, "pixel_imu")
linear_accel = await imu.get_linear_acceleration()
angular_vel = await imu.get_angular_velocity()

# Get location
position = await imu.get_position()
```

### 6. Typical Usage Scenarios

#### Scenario A: Robot Navigation
1. Connect phone to Pi via USB
2. Phone IMU provides orientation data
3. GPS provides location
4. Viam uses data for navigation
5. Eyes show direction robot is looking

#### Scenario B: Human Interaction
1. Face detection identifies person
2. Eyes track and look at person
3. Microphone captures voice
4. Emotion changes based on interaction
5. Speaker responds with audio

#### Scenario C: Remote Monitoring
1. App runs in background
2. Sensors stream data continuously
3. Camera provides vision
4. All data available in Viam dashboard
5. Control robot remotely

### 7. Troubleshooting

#### "Searching for Pi..." Never Connects
**Fix:**
1. Check USB cable is connected
2. Enable USB tethering on phone
3. Verify Pi is at 10.10.10.67
4. Restart app
5. Check Pi's viam-agent is running

#### Sensors Not Updating
**Fix:**
1. Grant all permissions
2. Disable battery optimization
3. Check app is in foreground or service running
4. Restart app

#### Face Detection Not Working
**Fix:**
1. Grant camera permission
2. Ensure good lighting
3. Face camera toward face
4. Check camera preview is active

#### Audio Not Recording
**Fix:**
1. Grant microphone permission
2. Check volume is up
3. Test with phone's voice recorder
4. Restart app

### 8. Settings & Configuration

**Access Settings:**
- Tap ⚙️ icon in top right
- Or swipe from right edge

**Available Settings:**
- **Connection:**
  - Pi IP address (default: 10.10.10.67)
  - Auto-connect on USB
  - Reconnection attempts
  
- **Sensors:**
  - Update rate (Hz)
  - Enable/disable individual sensors
  - Calibration
  
- **Camera:**
  - Resolution
  - Frame rate
  - Face detection sensitivity
  
- **Audio:**
  - Sample rate
  - Bit rate
  - Channels (mono/stereo)
  
- **Emotions:**
  - Auto mode ON/OFF
  - Default emotion
  - Animation speed
  
- **Advanced:**
  - Debug logging
  - Developer mode
  - Reset to defaults

### 9. Status Indicators

**Connection Status:**
- 🔴 Red: Disconnected
- 🟡 Yellow: Searching
- 🟢 Green: Connected

**Sensor Status:**
- ✅ Active and streaming
- ⏸️ Paused
- ❌ Error or disabled

**Battery Status:**
- 🔋 Charging
- 🪫 Low battery warning
- ⚡ Full charge

### 10. Performance Tips

**For Best Performance:**
1. Keep phone charged (or charging)
2. Close other apps
3. Use good USB cable (USB 3.0+)
4. Keep phone cool
5. Disable battery optimization
6. Use Wi-Fi for updates (not cellular)

**Battery Life:**
- Continuous use: 4-6 hours
- With charging: Unlimited
- Background only: 8-12 hours

### 11. Data Privacy

**What Data is Collected:**
- Sensor readings (IMU, GPS, etc.)
- Camera images (for face detection)
- Audio recordings (when recording)
- Device info (battery, network)

**Where Data Goes:**
- Directly to your Raspberry Pi
- NOT sent to cloud (unless you configure Viam cloud)
- Stored locally on Pi
- You control all data

**Permissions Required:**
- Camera: Face detection and vision
- Microphone: Audio recording
- Location: GPS coordinates
- Storage: Save recordings
- Network: Connect to Pi
- Boot: Auto-start

### 12. Updates & Maintenance

**Updating the App:**
1. Pull latest code from GitHub
2. Rebuild and install
3. App data preserved

**Backing Up:**
- Settings saved automatically
- Recordings saved to phone storage
- Export data from Viam dashboard

**Resetting:**
- Settings → Advanced → Reset to Defaults
- Or uninstall and reinstall app

---

## Quick Start Checklist

After app installs:
- [ ] Grant all permissions
- [ ] Disable battery optimization
- [ ] Connect USB cable to Pi
- [ ] Enable USB tethering
- [ ] Wait for "Connected" status
- [ ] Verify sensors updating
- [ ] Test camera preview
- [ ] Test face detection
- [ ] Test audio recording
- [ ] Check Viam dashboard

**You're ready to use your Pixel 4a as a Viam robot module!** 🎉