# Complete Build and Deploy Guide for Pixel 4a 5G

## Overview
This guide will take you from the current state (Flutter Doctor issues) to a working app on your Pixel 4a 5G.

**Your Current Setup:**
- ✅ Flutter 3.35.7 installed
- ✅ Android Studio 2025.2.1 installed
- ✅ Pixel 4a 5G connected (Device ID: 0B261JECB06991)
- ✅ Android SDK 36.1.0 installed
- ❌ Android licenses not accepted
- ❌ pubspec.yaml has wrong package name

**Estimated Time:** 20-30 minutes total

---

## Step 1: Accept Android Licenses (5 minutes)

### Quick Method - Command Line
1. Open **Command Prompt** or **PowerShell**
2. Navigate to your project:
   ```bash
   cd C:\Users\jbates\develop\viam_pixel_integration
   ```
3. Run:
   ```bash
   flutter doctor --android-licenses
   ```
4. Type `y` and press Enter for each license (there are usually 5-7)

### If That Doesn't Work
See **ANDROID_LICENSE_FIX.md** for detailed troubleshooting.

### Verify
```bash
flutter doctor
```
Should show: `[√] Android toolchain`

---

## Step 2: Fix pubspec.yaml (2 minutes)

### The Problem
Your local `pubspec.yaml` has `viam: any` but it should be `viam_sdk: ^0.11.0`

### Quick Fix
1. Open `pubspec.yaml` in Android Studio
2. Press `Ctrl+F` to search
3. Search for: `viam:`
4. If you find `viam: any`, replace with: `viam_sdk: ^0.11.0`
5. Save (`Ctrl+S`)

### Alternative: Use Correct Version
1. Open `CORRECT_PUBSPEC_REFERENCE.yaml` (in your project)
2. Copy all content
3. Open your `pubspec.yaml`
4. Select All (`Ctrl+A`) and paste
5. Save

---

## Step 3: Get Dependencies (3 minutes)

### Method A: Android Studio (GUI)
1. Right-click on `pubspec.yaml`
2. Select **Flutter** → **Pub Get**
3. Wait for completion (you'll see "Process finished" at bottom)

### Method B: Command Line
```bash
cd C:\Users\jbates\develop\viam_pixel_integration
flutter pub get
```

### Expected Output
```
Resolving dependencies...
+ viam_sdk 0.11.0
+ sensors_plus 4.0.2
+ camera 0.10.5+5
... (many more packages)
Got dependencies!
```

### If It Fails
See **FIX_VIAM_SDK_ERROR.md** for detailed troubleshooting.

---

## Step 4: Enable USB Debugging on Pixel 4a (2 minutes)

Your phone is already connected, but let's verify USB debugging is enabled:

1. On your **Pixel 4a 5G**, go to **Settings**
2. Scroll to **About phone**
3. Tap **Build number** 7 times (enables Developer options)
4. Go back to **Settings** → **System** → **Developer options**
5. Enable **USB debugging**
6. When prompted on phone, tap **Allow** for this computer

### Verify Connection
```bash
flutter devices
```

Should show:
```
Pixel 4a 5G (mobile) • 0B261JECB06991 • android-arm64 • Android 14 (API 34)
```

---

## Step 5: Build the APK (5-10 minutes)

### Method A: Android Studio (GUI - RECOMMENDED)
1. In Android Studio, click the **device dropdown** at the top
2. Select **Pixel 4a 5G (0B261JECB06991)**
3. Click the green **Run** button (▶️) or press `Shift+F10`
4. Wait for build to complete (first build takes 5-10 minutes)
5. App will automatically install and launch on your phone

### Method B: Command Line
```bash
cd C:\Users\jbates\develop\viam_pixel_integration
flutter run
```

### What You'll See
```
Launching lib\main.dart on Pixel 4a 5G in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk (XX.XMB).
Installing build\app\outputs\flutter-apk\app.apk...
Syncing files to device Pixel 4a 5G...
Flutter run key commands.
```

---

## Step 6: Test the App (5 minutes)

Once the app launches on your Pixel 4a:

### Basic Tests
1. **Check USB Connection Status**
   - Should show "Searching for Pi..." or "Connected to Pi"
   
2. **Test Sensors**
   - Tilt your phone - should see IMU data updating
   
3. **Test Camera**
   - Point at a face - should detect and show bounding box
   
4. **Test Emotional Display**
   - Eyes should animate and show emotions
   
5. **Check Logs**
   - In Android Studio, check the **Run** tab for logs
   - Should see sensor data, connection attempts, etc.

### Expected Behavior
- App should start automatically
- Should attempt to connect to Pi at 10.10.10.67
- Sensors should start reporting data
- Camera should initialize
- Eyes should display on screen

---

## Step 7: Install APK for Production (Optional)

If you want to install the app without Android Studio:

### Build Release APK
```bash
flutter build apk --release
```

### Find the APK
Location: `C:\Users\jbates\develop\viam_pixel_integration\build\app\outputs\flutter-apk\app-release.apk`

### Install on Phone
1. Copy `app-release.apk` to your phone
2. Open file manager on phone
3. Tap the APK file
4. Tap **Install**
5. Grant permissions when prompted

---

## Troubleshooting

### Build Fails with Gradle Error
**Solution:**
1. In Android Studio: **File** → **Invalidate Caches**
2. Check "Clear file system cache"
3. Click **Invalidate and Restart**
4. Try building again

### App Crashes on Launch
**Solution:**
1. Check Android Studio **Logcat** tab for errors
2. Look for permission errors
3. Manually grant permissions in phone settings:
   - Settings → Apps → Viam Pixel Integration → Permissions
   - Enable: Camera, Microphone, Location, Sensors

### Can't Find Device
**Solution:**
1. Unplug and replug USB cable
2. On phone, tap **Allow** for USB debugging
3. Run: `flutter devices`
4. If still not showing, try different USB cable/port

### Build Takes Forever
**Solution:**
- First build takes 5-10 minutes (normal)
- Subsequent builds are much faster (1-2 minutes)
- Make sure you have good internet (downloads dependencies)

### "Execution failed for task ':app:processDebugResources'"
**Solution:**
1. Clean the project:
   ```bash
   flutter clean
   flutter pub get
   ```
2. Try building again

---

## Success Checklist

Before considering the build complete, verify:

- [ ] Flutter Doctor shows no critical errors
- [ ] Android licenses accepted
- [ ] pubspec.yaml has `viam_sdk: ^0.11.0`
- [ ] `flutter pub get` completes successfully
- [ ] Pixel 4a 5G shows in `flutter devices`
- [ ] App builds without errors
- [ ] App installs on phone
- [ ] App launches successfully
- [ ] Sensors are working
- [ ] Camera initializes
- [ ] No critical crashes in logs

---

## Next Steps After Successful Build

1. **Connect to Raspberry Pi**
   - Connect phone to Pi via USB
   - App should auto-discover Pi at 10.10.10.67
   
2. **Configure Viam**
   - Update Viam config on Pi to use phone sensors
   - Replace OAK IMU with phone IMU
   
3. **Test Integration**
   - Verify sensor data flows to Viam
   - Test face detection
   - Test audio communication
   
4. **Enable Auto-Start**
   - App should start on phone boot
   - Test by rebooting phone

---

## Getting Help

If you encounter issues:

1. **Check the error message carefully**
2. **Look in these guides:**
   - ANDROID_LICENSE_FIX.md
   - FIX_VIAM_SDK_ERROR.md
   - TROUBLESHOOTING_FAQ.md
3. **Share with me:**
   - Screenshot of error
   - Output from `flutter doctor -v`
   - Relevant log messages

---

## Build Time Estimates

| Step | First Time | Subsequent Times |
|------|-----------|------------------|
| Accept Licenses | 5 min | N/A (one-time) |
| Fix pubspec.yaml | 2 min | N/A (one-time) |
| Pub Get | 3 min | 30 sec |
| First Build | 10 min | N/A |
| Subsequent Builds | N/A | 1-2 min |
| **Total First Build** | **20 min** | **2-3 min** |

---

## Important Notes

1. **First build is slow** - This is normal! Flutter downloads and compiles everything.
2. **Subsequent builds are fast** - Only changed files are recompiled.
3. **Debug vs Release** - Debug builds are larger but easier to test. Release builds are optimized.
4. **Hot Reload** - Once running, you can make code changes and press `r` in terminal for instant updates!
5. **USB Debugging** - Keep this enabled on your phone for development.

---

## Ready to Build?

Follow the steps in order:
1. ✓ Accept Android licenses
2. ✓ Fix pubspec.yaml
3. ✓ Run pub get
4. ✓ Verify device connection
5. ✓ Build and run
6. ✓ Test on device

**Let's get your app running on that Pixel 4a! 🚀**