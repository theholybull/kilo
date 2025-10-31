# 🔧 Troubleshooting FAQ - Common Problems & Solutions

## 📖 How to Use This Guide

1. Find your problem in the list below
2. Try the solutions in order (easiest first)
3. If solution works, continue with the main guide
4. If nothing works, see "Still Stuck?" section at bottom

---

## 🚨 CRITICAL ERRORS (Stop Everything!)

### ❌ "Flutter SDK not found"

**What it means:** Your computer can't find Flutter.

**Solutions (try in order):**

1. **Check if Flutter is installed:**
   - Open Command Prompt
   - Type: `flutter --version`
   - If you see version info → Flutter is installed, but PATH is wrong
   - If you see "command not found" → Flutter is not installed

2. **If Flutter is installed but not found:**
   - Close Android Studio completely
   - Close all Command Prompt windows
   - Restart your computer
   - Open Command Prompt
   - Try: `flutter --version` again

3. **If still not working, fix PATH:**
   - Press Windows key
   - Type "environment variables"
   - Click "Edit the system environment variables"
   - Click "Environment Variables" button
   - In "User variables", find "Path"
   - Click "Edit"
   - Look for `C:\flutter\bin`
   - If not there, click "New" and add it
   - Click OK on all windows
   - Restart computer

4. **If PATH is correct but still not working:**
   - Flutter might not be installed correctly
   - Delete `C:\flutter` folder
   - Re-download and extract Flutter
   - Add to PATH again

**✅ Fixed when:** `flutter --version` shows version number

---

### ❌ "Android SDK not found"

**What it means:** Android Studio didn't install the SDK properly.

**Solutions:**

1. **Open Android Studio**
   - Click "Tools" → "SDK Manager"
   - Check if "Android SDK Location" is shown at top
   - If empty → SDK not installed

2. **Install SDK:**
   - In SDK Manager, check these boxes:
     - Android 13.0 (API level 33)
     - Android SDK Build-Tools 33.0.0
     - Android SDK Platform-Tools
   - Click "Apply"
   - Click "OK" on popup
   - Wait for download (5-10 minutes)

3. **If SDK Manager won't open:**
   - Close Android Studio
   - Delete `C:\Users\YourName\.android` folder
   - Restart Android Studio
   - It will recreate the folder and download SDK

**✅ Fixed when:** SDK Manager shows installed components

---

### ❌ "Gradle sync failed"

**What it means:** Android Studio can't download or configure build tools.

**Solutions:**

1. **Check internet connection:**
   - Make sure you're online
   - Try opening a website in browser

2. **Retry sync:**
   - In Android Studio: File → Sync Project with Gradle Files
   - Wait 2-3 minutes

3. **Clear Gradle cache:**
   - Close Android Studio
   - Delete: `C:\Users\YourName\.gradle` folder
   - Restart Android Studio
   - Open project again
   - Wait for sync (will take longer, downloading everything)

4. **Invalidate caches:**
   - In Android Studio: File → Invalidate Caches / Restart
   - Choose "Invalidate and Restart"
   - Wait for restart
   - Try sync again

5. **Nuclear option:**
   - Close Android Studio
   - Delete these folders:
     - `C:\Users\YourName\.gradle`
     - `C:\Users\YourName\.android`
     - `Documents\AndroidProjects\kilo\viam_pixel_integration\.gradle`
     - `Documents\AndroidProjects\kilo\viam_pixel_integration\build`
   - Restart Android Studio
   - Open project
   - Wait for complete rebuild (10-15 minutes)

**✅ Fixed when:** Bottom of Android Studio shows "BUILD SUCCESSFUL"

---

## 📱 PHONE CONNECTION PROBLEMS

### ❌ Phone not showing in "adb devices"

**What it means:** Computer can't see your phone.

**Solutions:**

1. **Basic checks:**
   - Is USB cable plugged in both ends?
   - Is phone screen unlocked?
   - Did you tap "Allow" on USB debugging popup?

2. **Try different USB mode:**
   - On phone: Swipe down from top
   - Tap USB notification
   - Try each option:
     - File Transfer
     - PTP
     - MIDI

3. **Restart ADB:**
   - Open Command Prompt
   - Type: `adb kill-server`
   - Press Enter
   - Type: `adb start-server`
   - Press Enter
   - Type: `adb devices`
   - Press Enter

4. **Try different USB cable:**
   - Some cables are charge-only (no data)
   - Use the cable that came with your phone
   - Or try a different cable

5. **Try different USB port:**
   - Try USB 3.0 port (blue inside)
   - Try port on back of computer (not front)
   - Try all available ports

6. **Revoke and re-allow:**
   - On phone: Settings → Developer options
   - Tap "Revoke USB debugging authorizations"
   - Unplug and replug USB cable
   - Tap "Allow" on popup
   - Check "Always allow from this computer"

7. **Install USB drivers (Windows only):**
   - Go to: https://developer.android.com/studio/run/win-usb
   - Download Google USB Driver
   - Install it
   - Restart computer

8. **Last resort:**
   - Restart phone
   - Restart computer
   - Try again

**✅ Fixed when:** `adb devices` shows your phone's serial number

---

### ❌ "Unauthorized" in adb devices

**What it means:** You didn't allow USB debugging on phone.

**Solution:**
1. Look at your phone screen
2. You should see "Allow USB debugging?" popup
3. Check "Always allow from this computer"
4. Tap "OK"
5. Run `adb devices` again

**If no popup appears:**
1. Unplug USB cable
2. On phone: Settings → Developer options
3. Turn USB debugging OFF then ON again
4. Plug in USB cable
5. Popup should appear now

**✅ Fixed when:** `adb devices` shows "device" (not "unauthorized")

---

## 🏗️ BUILD PROBLEMS

### ❌ "flutter pub get" fails

**What it means:** Can't download dependencies.

**Solutions:**

1. **Check internet:**
   - Make sure you're online
   - Try: `ping google.com` in Command Prompt

2. **Clear pub cache:**
   - In Terminal: `flutter pub cache repair`
   - Wait for it to finish
   - Try: `flutter pub get` again

3. **Check you're in right folder:**
   - In Terminal, you should see path ending in `viam_pixel_integration`
   - If not: `cd Documents\AndroidProjects\kilo\viam_pixel_integration`

4. **Delete pubspec.lock:**
   - In project folder, delete `pubspec.lock` file
   - Try: `flutter pub get` again

**✅ Fixed when:** Terminal shows "Got dependencies!"

---

### ❌ "flutter build apk" fails

**What it means:** Build process encountered an error.

**Solutions:**

1. **Read the error message:**
   - Scroll up in Terminal
   - Look for lines starting with "ERROR" or "FAILURE"
   - This tells you what went wrong

2. **Common error: "Execution failed for task ':app:processReleaseResources'"**
   - Solution: Clean and rebuild
   - `flutter clean`
   - `flutter pub get`
   - `flutter build apk --release`

3. **Common error: "Namespace not specified"**
   - Solution: Check build.gradle
   - Make sure it has: `namespace "com.example.viam_pixel4a_sensors"`
   - Save and try build again

4. **Common error: "SDK location not found"**
   - Solution: Set ANDROID_HOME
   - Windows key → "environment variables"
   - Add new variable:
     - Name: `ANDROID_HOME`
     - Value: `C:\Users\YourName\AppData\Local\Android\Sdk`
   - Restart Command Prompt
   - Try build again

5. **Generic solution:**
   - `flutter clean`
   - Close Android Studio
   - Delete `build` folder in project
   - Restart Android Studio
   - `flutter pub get`
   - `flutter build apk --release`

**✅ Fixed when:** Build completes with "Built build\app\outputs\flutter-apk\app-release.apk"

---

### ❌ Build takes forever (30+ minutes)

**What it means:** Something is slowing down the build.

**Solutions:**

1. **First build is always slow:**
   - 10-15 minutes is normal for first build
   - Be patient!

2. **Check internet speed:**
   - Slow internet = slow download of dependencies
   - Try: speedtest.net
   - If slow, wait it out

3. **Close other programs:**
   - Close Chrome, games, video players
   - Free up RAM for Android Studio

4. **Check disk space:**
   - Need at least 10GB free
   - Windows key → "disk cleanup"
   - Delete temporary files

5. **Disable antivirus temporarily:**
   - Some antivirus software scans every file during build
   - Temporarily disable it
   - Try build again
   - Re-enable after build

**✅ Fixed when:** Build completes in reasonable time (10-15 min first time, 2-5 min after)

---

## 📲 INSTALLATION PROBLEMS

### ❌ "flutter install" fails

**What it means:** Can't install app on phone.

**Solutions:**

1. **Check phone is connected:**
   - Run: `adb devices`
   - Phone should be listed

2. **Check USB debugging:**
   - On phone: Settings → Developer options
   - Make sure "USB debugging" is ON

3. **Try manual install:**
   - Find APK: `build\app\outputs\flutter-apk\app-release.apk`
   - Copy to phone's Downloads folder
   - On phone: Open Files app → Downloads
   - Tap the APK file
   - Tap "Install"

4. **Enable "Install unknown apps":**
   - On phone: Settings → Apps
   - Find "Files" app
   - Tap "Install unknown apps"
   - Enable it
   - Try installing APK again

**✅ Fixed when:** App appears on phone's home screen

---

### ❌ App crashes immediately on startup

**What it means:** Something wrong with the app or permissions.

**Solutions:**

1. **Grant all permissions:**
   - On phone: Settings → Apps → Viam Pixel 4a Sensors
   - Tap "Permissions"
   - Allow ALL permissions:
     - Camera
     - Microphone
     - Location
     - Files

2. **Clear app data:**
   - Settings → Apps → Viam Pixel 4a Sensors
   - Tap "Storage"
   - Tap "Clear data"
   - Open app again

3. **Reinstall app:**
   - Uninstall app from phone
   - In Android Studio: `flutter clean`
   - Build again: `flutter build apk --release`
   - Install again: `flutter install`

4. **Check Android version:**
   - App requires Android 5.0 or higher
   - On phone: Settings → About phone
   - Check "Android version"
   - If below 5.0, phone is too old

**✅ Fixed when:** App opens and stays open

---

## 🔍 ANDROID STUDIO PROBLEMS

### ❌ Android Studio won't open

**Solutions:**

1. **Wait longer:**
   - First launch can take 5 minutes
   - Be patient

2. **Check if already running:**
   - Press Ctrl+Alt+Delete
   - Open Task Manager
   - Look for "studio64.exe"
   - If found, end task
   - Try opening again

3. **Restart computer:**
   - Sometimes Windows needs a restart
   - Restart and try again

4. **Reinstall Android Studio:**
   - Uninstall Android Studio
   - Delete `C:\Program Files\Android\Android Studio`
   - Download and install again

**✅ Fixed when:** Android Studio welcome screen appears

---

### ❌ "Project not found" or "Invalid project"

**What it means:** Android Studio can't find or recognize the project.

**Solutions:**

1. **Check you're opening the right folder:**
   - Should open: `Documents\AndroidProjects\kilo\viam_pixel_integration`
   - NOT: `Documents\AndroidProjects\kilo`

2. **Re-download project:**
   - Delete `Documents\AndroidProjects\kilo` folder
   - Open Command Prompt
   - `cd Documents\AndroidProjects`
   - `git clone https://github.com/theholybull/kilo.git`
   - `cd kilo`
   - `git checkout viam-pixel-integration`
   - Open `viam_pixel_integration` folder in Android Studio

**✅ Fixed when:** Project opens and shows file structure on left

---

### ❌ "Indexing" never finishes

**What it means:** Android Studio is stuck analyzing files.

**Solutions:**

1. **Wait longer:**
   - First indexing can take 10-15 minutes
   - Check bottom right corner for progress

2. **Restart indexing:**
   - File → Invalidate Caches / Restart
   - Choose "Invalidate and Restart"

3. **Close other projects:**
   - File → Close Project
   - Only open one project at a time

**✅ Fixed when:** Bottom bar shows "Indexing complete"

---

## 💾 DISK SPACE PROBLEMS

### ❌ "No space left on device"

**What it means:** Your hard drive is full.

**Solutions:**

1. **Check disk space:**
   - Open File Explorer
   - Right-click C: drive
   - Choose "Properties"
   - Need at least 10GB free

2. **Free up space:**
   - Windows key → "disk cleanup"
   - Check all boxes
   - Click "OK"
   - Wait for cleanup

3. **Delete old Android builds:**
   - Delete: `C:\Users\YourName\.gradle\caches`
   - Delete: `C:\Users\YourName\.android\build-cache`

4. **Move project to different drive:**
   - If you have D: drive with more space
   - Move `AndroidProjects` folder there
   - Update paths in commands

**✅ Fixed when:** You have 10GB+ free space

---

## 🌐 INTERNET PROBLEMS

### ❌ Downloads fail or timeout

**What it means:** Internet connection issues.

**Solutions:**

1. **Check internet:**
   - Open browser
   - Try loading google.com
   - If slow/fails, fix internet first

2. **Use mobile hotspot:**
   - If home internet is slow
   - Use phone's hotspot temporarily
   - Just for downloads

3. **Retry failed downloads:**
   - In Android Studio: File → Sync Project with Gradle Files
   - In Terminal: `flutter pub get`

4. **Use VPN if blocked:**
   - Some countries block developer sites
   - Use VPN to access
   - Try build again

**✅ Fixed when:** Downloads complete successfully

---

## 🔐 PERMISSION PROBLEMS

### ❌ "Permission denied" errors

**What it means:** Windows won't let you modify files.

**Solutions:**

1. **Run as Administrator:**
   - Right-click Android Studio icon
   - Choose "Run as administrator"

2. **Check folder permissions:**
   - Right-click project folder
   - Properties → Security
   - Make sure your user has "Full control"

3. **Disable antivirus temporarily:**
   - Some antivirus blocks file modifications
   - Temporarily disable
   - Try again
   - Re-enable after

**✅ Fixed when:** Operations complete without permission errors

---

## 🆘 STILL STUCK?

If none of these solutions work:

### Option 1: Start Fresh
1. Uninstall everything
2. Restart computer
3. Follow the beginner guide from step 1
4. Don't skip any steps

### Option 2: Check Your Setup
Run these commands and note the output:
```cmd
flutter doctor -v
adb devices
java -version
```

### Option 3: Common Mistakes Checklist
- [ ] Did you add Flutter to PATH?
- [ ] Did you enable USB debugging on phone?
- [ ] Did you allow USB debugging popup on phone?
- [ ] Did you open the correct folder in Android Studio?
- [ ] Did you run `flutter pub get`?
- [ ] Did you fix AndroidManifest.xml?
- [ ] Did you fix build.gradle?
- [ ] Is your phone connected via USB?
- [ ] Do you have 10GB+ free disk space?
- [ ] Is your internet working?

### Option 4: Error Message Analysis
1. Take a screenshot of the error
2. Read the error message carefully
3. Google the exact error message
4. Look for solutions on Stack Overflow

### Option 5: System Requirements Check
- Windows 10 or 11 (64-bit)
- 8GB RAM minimum (16GB recommended)
- 10GB free disk space
- Android phone with Android 5.0+
- Working USB cable
- Internet connection

---

## 📞 Getting Help

When asking for help, provide:
1. **What step you're on** (e.g., "Part 4, Step 4.3")
2. **Exact error message** (screenshot or copy-paste)
3. **What you tried** (list solutions you attempted)
4. **Your system** (Windows version, RAM, disk space)
5. **Output of these commands:**
   ```cmd
   flutter doctor -v
   adb devices
   ```

**Good help request example:**
> "I'm stuck on Part 5 (Build the App). When I run `flutter build apk --release`, I get error: 'Namespace not specified'. I tried adding namespace to build.gradle but still fails. I'm on Windows 11 with 16GB RAM. Output of flutter doctor shows all green checkmarks."

This gives all the info needed to help you! 🎯

---

## ✅ Success Stories

**Remember:** Everyone struggles with this at first!

- First build taking 20 minutes? **Normal!**
- Had to restart 3 times? **Normal!**
- Googled 10 error messages? **Normal!**
- Took 3 hours total? **Normal!**

**You're not alone!** Keep trying, follow the steps, and you'll get there! 🚀