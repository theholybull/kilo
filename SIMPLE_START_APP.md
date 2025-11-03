# 🎯 Simple Start App - Get Running in 10 Minutes

## 🚀 Goal: Get a Basic App on Your Pixel 4a

This guide creates the simplest possible version first - no Viam, no complex features, just a working app.

---

## 📋 Prerequisites

Make sure you've completed these from the main guide:
- [ ] Android Studio installed
- [ ] Flutter installed
- [ ] Pixel 4a connected with USB debugging enabled

---

## ⚡ Quick Start (10 Minutes)

### 1. Create the Project
```bash
# Open Command Prompt/PowerShell
cd Desktop
flutter create simple_viam_app
cd simple_viam_app
```

### 2. Test Basic App
```bash
# Make sure phone is connected
adb devices

# Run the default app
flutter run
```
You should see the Flutter counter app on your phone!

---

## 📱 Minimal App Code

Replace `lib/main.dart` with this simplified version:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viam Pixel Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _connectionStatus = 'Not Connected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Viam Pixel Test App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Basic Test App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Status: $_connectionStatus',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            const Text(
              'Button presses:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _testConnection,
              child: const Text('Test Connection'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _testConnection() {
    setState(() {
      _connectionStatus = 'Testing...';
    });
    
    // Simulate connection test
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _connectionStatus = 'Connected! ✅';
      });
    });
  }
}
```

### 3. Update pubspec.yaml (Minimal Version)

```yaml
name: simple_viam_app
description: A simple Viam test app.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

### 4. Run the Simple App
```bash
flutter run
```

---

## ✅ Success Checkpoints

You should see:
1. ✅ App launches on your Pixel 4a
2. ✅ Title shows "Viam Pixel Test App"
3. ✅ Counter button works (tap + button)
4. ✅ "Test Connection" button changes status

If all 4 work, your environment is ready!

---

## 🔄 Next Steps After Success

Once the simple app works:

### Add Basic Permissions
Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Basic permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <application
        android:label="Simple Viam Test"
        android:icon="@mipmap/ic_launcher">
        
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
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### Add First Real Feature (Camera Test)
Update pubspec.yaml to add camera:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  camera: ^0.10.5+2
  permission_handler: ^10.4.3
```

Then run:
```bash
flutter pub get
flutter run
```

---

## 🚨 Troubleshooting

### App Won't Install:
```bash
flutter clean
flutter pub get
flutter run
```

### Phone Not Detected:
1. Check USB cable (use original if possible)
2. Enable "File transfer" mode on phone
3. Restart ADB: `adb kill-server && adb start-server`

### Build Errors:
1. Check Android Studio SDK Manager for updates
2. Make sure you're using API level 33
3. Restart Android Studio

---

## 🎯 When to Move On

Move to the full Viam app when:
- ✅ Simple app runs without crashes
- ✅ Hot reload works (press 'r' in terminal)
- ✅ You can build APK (`flutter build apk`)
- ✅ Basic permissions don't cause crashes

---

## 💡 Pro Tips

### Development Workflow:
1. Keep terminal open while developing
2. Use 'r' for hot reload
3. Use 'R' for hot restart
4. Use 'q' to quit

### Testing Strategy:
1. Test on real device, not emulator
2. Uninstall/reinstall if you get weird crashes
3. Check logcat: `adb logcat`

---

## 📞 If You Get Stuck

Tell me:
1. **What command** you ran
2. **Exact error message**
3. **What you expected** to happen
4. **What actually happened**

Example:
> "I ran `flutter run` and got 'No connected devices'. I expect to see my Pixel 4a, but it says no devices. I've enabled USB debugging and the phone is connected."

This simple start approach gets you to a working app quickly, then we can add the Viam features step by step!