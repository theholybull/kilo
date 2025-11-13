# Viam Pixel 4a Integration Project

## 🎯 Project Purpose

This project transforms a Google Pixel 4a smartphone into a comprehensive robotics module that integrates with Viam robotics platform running on a Raspberry Pi. The phone replaces problematic OAK-D IMU sensors and adds advanced capabilities including face recognition, emotional display, and voice communication.

## 🔑 Key Features

### 1. USB Connection to Raspberry Pi
- Direct USB tethering connection (10.10.10.67 ↔ 10.10.10.1)
- Auto-discovery and connection on boot
- Persistent foreground service for reliability
- Health monitoring with automatic reconnection

### 2. IMU Sensor Replacement
- Replaces OAK-D BMI270 IMU with phone's high-precision sensors
- 100Hz sampling rate for real-time data
- Accelerometer, gyroscope, and magnetometer data
- Direct integration with Viam sensor components

### 3. Face Recognition & Tracking
- Google ML Kit integration for real-time face detection
- Person tracking during conversations
- Emotion detection from facial expressions
- Dual camera system (phone + OAK-D)

### 4. Emotional Display System
- Dynamic eye animations showing robot emotions
- 10+ emotion states (happy, sad, curious, thinking, etc.)
- Steering wheel direction visualization on eyes
- Person tracking with eye movement

### 5. Voice Communication
- Professional microphone integration
- High-quality speaker output
- Audio recording and playback modules
- Viam audio component integration

### 6. Local Viam Integration
- Direct gRPC connection to viam-agent (port 8080)
- No cloud dependency - fully local operation
- Auto-reconnection and health monitoring
- Seamless integration with existing Viam setup

## 📁 Project Structure

```
viam_pixel_integration/
├── android/                    # Android native code
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/
│               ├── BootReceiver.kt
│               ├── ViamBackgroundService.kt
│               └── UsbReceiver.kt
├── lib/                        # Flutter application code
│   ├── main.dart              # App entry point
│   ├── providers/             # State management
│   │   ├── pi_connection_provider.dart
│   │   ├── emotion_display_provider.dart
│   │   ├── face_detection_provider.dart
│   │   ├── sensor_provider.dart
│   │   ├── audio_provider.dart
│   │   ├── camera_provider.dart
│   │   └── viam_provider.dart
│   ├── screens/               # UI screens
│   │   └── dashboard_screen.dart
│   ├── widgets/               # Reusable UI components
│   │   ├── emotion_display_widget.dart
│   │   ├── sensor_display_widget.dart
│   │   └── connection_status_widget.dart
│   └── services/              # Background services
├── test/                      # Unit tests
├── BUILD_INSTRUCTIONS.md      # Build and deployment guide
├── PC_ANDROID_SETUP_GUIDE.md  # PC development setup
├── QUICK_START_CHECKLIST.md   # Step-by-step checklist
├── SIMPLE_START_APP.md        # Quick start guide
├── README.md                  # Main documentation
├── pi_integration_config.md   # Raspberry Pi configuration
├── pubspec.yaml               # Flutter dependencies
└── analysis_options.yaml      # Code analysis rules
```

## 🚀 Getting Started

### For PC Development
1. Follow `PC_ANDROID_SETUP_GUIDE.md` to set up your development environment
2. Use `QUICK_START_CHECKLIST.md` to track your progress
3. Try `SIMPLE_START_APP.md` for a quick test
4. Read `BUILD_INSTRUCTIONS.md` for full build process

### For Raspberry Pi Setup
1. Follow `pi_integration_config.md` for Pi configuration
2. Configure USB networking (10.10.10.67 ↔ 10.10.10.1)
3. Update Viam configuration to use phone sensors
4. Test connection and sensor data flow

## 🔧 Technical Requirements

### Hardware
- Google Pixel 4a smartphone
- Raspberry Pi (with Viam installed)
- USB cable for Pi connection
- OAK-D camera (optional, for dual camera setup)

### Software
- Android 11+ on Pixel 4a
- Viam robotics platform on Raspberry Pi
- Flutter SDK 3.0+
- Android Studio (for development)

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Google Pixel 4a                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │           Flutter Application                     │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐ │  │
│  │  │  Sensors   │  │   Camera   │  │   Audio    │ │  │
│  │  │  Provider  │  │  Provider  │  │  Provider  │ │  │
│  │  └────────────┘  └────────────┘  └────────────┘ │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐ │  │
│  │  │   Face     │  │  Emotion   │  │    Viam    │ │  │
│  │  │ Detection  │  │  Display   │  │  Provider  │ │  │
│  │  └────────────┘  └────────────┘  └────────────┘ │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │        Android Background Service                 │  │
│  │  - Boot on startup                                │  │
│  │  - USB connection management                      │  │
│  │  - Foreground service for reliability             │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                    USB Connection
                    (10.10.10.67)
                          │
┌─────────────────────────────────────────────────────────┐
│                   Raspberry Pi                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Viam Agent (port 8080)               │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐ │  │
│  │  │   Phone    │  │   Phone    │  │   Phone    │ │  │
│  │  │    IMU     │  │   Camera   │  │   Audio    │ │  │
│  │  │ Component  │  │ Component  │  │ Component  │ │  │
│  │  └────────────┘  └────────────┘  └────────────┘ │  │
│  │  ┌────────────┐  ┌────────────┐                  │  │
│  │  │   OAK-D    │  │   Other    │                  │  │
│  │  │   Camera   │  │ Components │                  │  │
│  │  └────────────┘  └────────────┘                  │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 🎨 Features in Detail

### Emotion Display System
The phone displays animated eyes that show the robot's emotional state:
- **Happy**: Wide eyes with sparkles
- **Sad**: Drooping eyes with tears
- **Curious**: Wide eyes looking around
- **Thinking**: Eyes looking up with thought bubble
- **Surprised**: Very wide eyes
- **Sleepy**: Half-closed eyes
- **Angry**: Narrowed eyes with furrowed brows
- **Confused**: Asymmetric eyes with question mark
- **Excited**: Bouncing eyes with stars
- **Neutral**: Standard eye position

### Face Recognition Features
- Real-time face detection using ML Kit
- Facial landmark detection (eyes, nose, mouth)
- Emotion recognition from expressions
- Person tracking during conversations
- Multiple face detection support

### Sensor Data
- **Accelerometer**: Linear acceleration in X, Y, Z axes
- **Gyroscope**: Rotational velocity around X, Y, Z axes
- **Magnetometer**: Magnetic field strength in X, Y, Z axes
- **Sampling Rate**: 100Hz for real-time responsiveness
- **Data Format**: Standard Viam sensor readings

## 🔐 Security & Privacy

- All data processing happens locally on the device
- No cloud connectivity required for core functionality
- USB connection is direct and secure
- Face recognition data is not stored permanently
- Audio data is processed in real-time only

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

## 📞 Support

For issues, questions, or contributions:
1. Check the documentation files in this repository
2. Review the troubleshooting sections in the guides
3. Open an issue on GitHub with detailed information

## 🎯 Roadmap

Future enhancements planned:
- [ ] Additional emotion states
- [ ] Voice command recognition
- [ ] Gesture recognition
- [ ] Multi-language support
- [ ] Enhanced person tracking
- [ ] Battery optimization
- [ ] Performance monitoring dashboard

## 🙏 Acknowledgments

- Viam Robotics for the robotics platform
- Google ML Kit for face detection
- Flutter team for the cross-platform framework
- Open source community for various libraries used