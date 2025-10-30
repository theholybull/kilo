# Android Development Setup Guide for PC

## 🎯 What You Need to Build This App

This guide will help you set up everything on your PC to build the Viam Pixel 4a integration app.

---

## 📋 Prerequisites Checklist

Before we start, make sure you have:
- [ ] Windows 10/11 or macOS/Linux
- [ ] At least 8GB RAM (16GB recommended)
- [ ] 10GB free disk space
- [ ] Google Pixel 4a phone with USB cable
- [ ] Raspberry Pi with Viam installed

---

## 🔧 Step 1: Install Android Studio

### Option A: Download Android Studio (Recommended)
1. Go to https://developer.android.com/studio
2. Download Android Studio for your operating system
3. Run the installer and follow the setup wizard
4. When prompted, select "Standard" installation

### Option B: Install Command Line Tools Only
If you prefer command line development:

#### For Windows:
1. Download Command Line Tools from https://developer.android.com/studio#command-tools
2. Extract to `C:\Android\cmdline-tools\latest\`
3. Add to PATH: `C:\Android\cmdline-tools\latest\bin` and `C:\Android\platform-tools`

#### For macOS:
```bash
brew install --cask android-studio
```

#### For Linux:
```bash
sudo snap install android-studio --classic
```

---

## 🐦 Step 2: Install Flutter

### For Windows:
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter\`
3. Add to PATH: `C:\flutter\bin`
4. Open Command Prompt and run:
```cmd
flutter doctor
```

### For macOS:
```bash
brew install flutter
```

### For Linux:
```bash
snap install flutter --classic
```

### Verify Installation:
```bash
flutter doctor
```
You should see green checkmarks for Android toolchain.

---

## 📱 Step 3: Setup Android SDK

### Using Android Studio:
1. Open Android Studio
2. Go to Tools → SDK Manager
3. Install:
   - Android SDK Platform 33 (Android 13)
   - Android SDK Build-Tools 33.0.0
   - Android SDK Platform-Tools
   - Android SDK Command-line Tools

### Using Command Line:
```bash
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

---

## 🔌 Step 4: Configure Your Pixel 4a

### Enable Developer Options:
1. Go to Settings → About phone
2. Tap "Build number" 7 times
3. Go back to Settings → System → Developer options

### Enable Required Settings:
1. ✅ USB debugging
2. ✅ Stay awake
3. ✅ USB tethering (for Pi connection)

### Test Connection:
```bash
adb devices
```
You should see your Pixel 4a listed.

---

## 📁 Step 5: Create the Flutter Project

### Method 1: Using Android Studio
1. Open Android Studio
2. Click "New Flutter Project"
3. Select "Flutter Application"
4. Name: `viam_pixel_integration`
5. Package: `com.example.viam_pixel_integration`
6. Choose a location on your PC

### Method 2: Using Command Line
```bash
cd C:\Users\YourUsername\Documents\
flutter create viam_pixel_integration
cd viam_pixel_integration
```

---

## 📦 Step 6: Install Dependencies

### Open the project and update `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  
  # Viam Integration
  viam: ^0.71.0
  
  # Camera and Face Detection
  camera: ^0.10.5+2
  google_ml_kit: ^0.14.0
  image: ^4.0.17
  
  # Audio
  flutter_sound: ^9.2.13
  permission_handler: ^10.4.3
  
  # Sensors
  sensors_plus: ^4.0.2
  
  # Network and USB
  usb_serial: ^0.4.0
  http: ^1.1.0
  
  # UI and State Management
  provider: ^6.0.5
  flutter/material.dart

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

### Install dependencies:
```bash
flutter pub get
```

---

## 🔧 Step 7: Configure Android Permissions

### Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Internet and Network -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Camera -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.front" android:required="false" />
    
    <!-- Audio -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    
    <!-- USB -->
    <uses-permission android:name="android.permission.USB_PERMISSION" />
    <uses-feature android:name="android.hardware.usb.host" />
    
    <!-- Sensors -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Storage -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- Boot Receiver -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

    <application
        android:label="Viam Pixel Integration"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Main Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Boot Receiver -->
        <receiver android:name=".BootReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.PACKAGE_REPLACED" />
                <data android:scheme="package" />
            </intent-filter>
        </receiver>
        
        <!-- USB Receiver -->
        <receiver android:name=".UsbReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
                <action android:name="android.hardware.usb.action.USB_DEVICE_DETACHED" />
            </intent-filter>
        </receiver>
        
        <!-- Background Service -->
        <service
            android:name=".ViamBackgroundService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="dataSync" />
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## 🏗️ Step 8: Build and Run the App

### Connect Your Phone:
1. Connect Pixel 4a to PC via USB
2. Enable USB debugging if prompted
3. Trust the computer on your phone

### Run the App:
```bash
flutter run
```
or in Android Studio: Click the green play button ▶️

### Build APK for Installation:
```bash
flutter build apk --release
```
The APK will be in `build/app/outputs/flutter-apk/app-release.apk`

---

## 🚨 Common Issues and Solutions

### Issue: "flutter command not found"
**Solution:** Add Flutter to your PATH environment variable

### Issue: "No devices available"
**Solution:** 
1. Enable USB debugging on Pixel 4a
2. Install Google USB drivers (Windows)
3. Try `adb devices` to verify connection

### Issue: "Gradle build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "USB Permission Denied"
**Solution:** 
1. Check "Always allow from this computer" when USB debugging prompt appears
2. Restart ADB: `adb kill-server && adb start-server`

---

## 📱 Step 9: Test the Basic App

Once the app runs successfully, you should see:
1. A Flutter app running on your Pixel 4a
2. The app title "Viam Pixel Integration"
3. Basic counter functionality (default Flutter app)

---

## 🔄 Next Steps

After the basic setup works:
1. We'll add the Viam SDK integration
2. Implement the sensor modules
3. Add the face detection features
4. Configure the USB connection to Raspberry Pi

---

## 💡 Pro Tips

### Development Workflow:
1. Use `flutter hot reload` for fast development
2. Test on real device, not just emulator
3. Use Android Studio's debugger for troubleshooting

### Performance:
1. Use `flutter run --profile` for performance testing
2. Monitor memory usage with Android Studio's profiler
3. Test battery impact during long runs

---

## 🆘 Getting Help

If you run into issues:
1. Run `flutter doctor -v` for detailed diagnostics
2. Check Android Studio's Event Log for errors
3. Look at the console output when running `flutter run`

---

## 📁 Project Structure

Your final project should look like this:
```
viam_pixel_integration/
├── android/
│   ├── app/
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/  (for native Android code)
│   │       └── res/
├── lib/
│   ├── main.dart
│   ├── providers/
│   ├── widgets/
│   └── screens/
├── pubspec.yaml
└── README.md
```

This guide will get you from zero to a running Flutter app on your Pixel 4a. Let me know which step you need help with!