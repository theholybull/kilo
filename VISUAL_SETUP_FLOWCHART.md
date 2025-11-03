# 📊 Visual Setup Flowchart

## 🗺️ Your Journey from Zero to Working App

```
START HERE
    ↓
┌─────────────────────────────────────┐
│  PART 1: INSTALL SOFTWARE           │
│  ⏱️ Time: 30-45 minutes             │
└─────────────────────────────────────┘
    ↓
    ├─→ Install Android Studio (15 min)
    │   └─→ Download from developer.android.com
    │       └─→ Run installer, choose "Standard"
    │           └─→ Wait for component download
    │
    ├─→ Install Flutter (10 min)
    │   └─→ Download SDK
    │       └─→ Extract to C:\flutter
    │           └─→ Add to PATH
    │               └─→ Test: flutter --version
    │
    └─→ Install Git (5 min)
        └─→ Download from git-scm.com
            └─→ Run installer with defaults
                └─→ Test: git --version
    ↓
✅ CHECKPOINT: All three commands work in Command Prompt
    ↓
┌─────────────────────────────────────┐
│  PART 2: SETUP YOUR PHONE           │
│  ⏱️ Time: 5-10 minutes              │
└─────────────────────────────────────┘
    ↓
    ├─→ Enable Developer Options
    │   └─→ Settings → About phone
    │       └─→ Tap "Build number" 7 times
    │
    ├─→ Enable USB Debugging
    │   └─→ Settings → System → Developer options
    │       └─→ Toggle "USB debugging" ON
    │
    └─→ Connect to Computer
        └─→ Plug in USB cable
            └─→ Allow USB debugging popup
                └─→ Test: adb devices
    ↓
✅ CHECKPOINT: Phone shows in adb devices
    ↓
┌─────────────────────────────────────┐
│  PART 3: DOWNLOAD PROJECT           │
│  ⏱️ Time: 5 minutes                 │
└─────────────────────────────────────┘
    ↓
    ├─→ Create workspace folder
    │   └─→ Documents\AndroidProjects
    │
    └─→ Clone from GitHub
        └─→ git clone https://github.com/theholybull/kilo.git
            └─→ cd kilo
                └─→ git checkout viam-pixel-integration
                    └─→ cd viam_pixel_integration
    ↓
✅ CHECKPOINT: You're in the project folder
    ↓
┌─────────────────────────────────────┐
│  PART 4: SETUP IN ANDROID STUDIO    │
│  ⏱️ Time: 10-15 minutes             │
└─────────────────────────────────────┘
    ↓
    ├─→ Open Project
    │   └─→ Android Studio → Open
    │       └─→ Select viam_pixel_integration folder
    │           └─→ Wait for indexing
    │
    ├─→ Install Dependencies
    │   └─→ Terminal: flutter pub get
    │       └─→ Wait for "Got dependencies!"
    │
    ├─→ Fix AndroidManifest.xml
    │   └─→ Remove package="..." from first line
    │       └─→ Save file (Ctrl+S)
    │
    └─→ Fix build.gradle
        └─→ Add: namespace "com.example.viam_pixel4a_sensors"
            └─→ Save and sync
    ↓
✅ CHECKPOINT: Gradle sync shows "BUILD SUCCESSFUL"
    ↓
┌─────────────────────────────────────┐
│  PART 5: BUILD THE APP              │
│  ⏱️ Time: 10-15 minutes (first time)│
└─────────────────────────────────────┘
    ↓
    ├─→ Clean Project
    │   └─→ Build → Clean Project
    │
    └─→ Build APK
        └─→ Terminal: flutter build apk --release
            └─→ Wait 10-15 minutes
                └─→ Look for "Built build\app\outputs\..."
    ↓
✅ CHECKPOINT: APK file created successfully
    ↓
┌─────────────────────────────────────┐
│  PART 6: INSTALL ON PHONE           │
│  ⏱️ Time: 2-3 minutes               │
└─────────────────────────────────────┘
    ↓
    └─→ Install via Flutter
        └─→ Terminal: flutter install
            └─→ App appears on phone
                └─→ Tap to open
    ↓
✅ CHECKPOINT: App opens on phone
    ↓
┌─────────────────────────────────────┐
│  PART 7: GRANT PERMISSIONS          │
│  ⏱️ Time: 1 minute                  │
└─────────────────────────────────────┘
    ↓
    └─→ Allow all permissions
        ├─→ Camera
        ├─→ Microphone
        ├─→ Location
        └─→ Files
    ↓
✅ CHECKPOINT: App runs with all features
    ↓
┌─────────────────────────────────────┐
│  🎉 SUCCESS! APP IS WORKING!        │
└─────────────────────────────────────┘
```

---

## 🚦 Traffic Light System

Use this to know if you're on track:

### 🟢 GREEN - Everything is Good
- Commands return version numbers
- No error messages
- Progress bars complete
- "BUILD SUCCESSFUL" messages
- App installs and opens

### 🟡 YELLOW - Minor Issues (Usually Fixable)
- Slow downloads (just wait)
- "Indexing..." taking a while (normal)
- First build taking 15+ minutes (normal)
- Need to restart Android Studio (common)

### 🔴 RED - Need to Troubleshoot
- "Command not found" errors
- "SDK not found" errors
- Phone not showing in adb devices
- Build fails with errors
- App crashes immediately

**If you see RED:** Go to the Troubleshooting section in the main guide!

---

## 📍 Where Am I? Quick Check

### If you just started:
→ You should be in **PART 1: Install Software**

### If Android Studio is open:
→ You should be in **PART 4: Setup in Android Studio**

### If you see "BUILD SUCCESSFUL":
→ You should be in **PART 5: Build the App**

### If app is on your phone:
→ You're in **PART 7: Grant Permissions** or **DONE!**

---

## ⏱️ Time Estimates

| Part | Task | Time | Can Skip? |
|------|------|------|-----------|
| 1 | Install Android Studio | 15 min | ❌ No |
| 1 | Install Flutter | 10 min | ❌ No |
| 1 | Install Git | 5 min | ❌ No |
| 2 | Setup Phone | 10 min | ❌ No |
| 3 | Download Project | 5 min | ❌ No |
| 4 | Setup in Android Studio | 15 min | ❌ No |
| 5 | Build APK | 15 min | ❌ No |
| 6 | Install on Phone | 3 min | ❌ No |
| 7 | Grant Permissions | 1 min | ❌ No |
| **TOTAL** | **First Time** | **~80 min** | |
| **TOTAL** | **Subsequent Builds** | **~5 min** | |

---

## 🎯 Decision Tree: "What Should I Do?"

```
Do you have Android Studio installed?
├─ NO → Go to Part 1, Step 1.1
└─ YES ↓

Do you have Flutter installed?
├─ NO → Go to Part 1, Step 1.2
└─ YES ↓

Can you see your phone in "adb devices"?
├─ NO → Go to Part 2
└─ YES ↓

Do you have the project downloaded?
├─ NO → Go to Part 3
└─ YES ↓

Is the project open in Android Studio?
├─ NO → Go to Part 4, Step 4.1
└─ YES ↓

Did "flutter pub get" work?
├─ NO → Go to Part 4, Step 4.2
└─ YES ↓

Did you fix AndroidManifest.xml?
├─ NO → Go to Part 4, Step 4.3
└─ YES ↓

Did you fix build.gradle?
├─ NO → Go to Part 4, Step 4.4
└─ YES ↓

Did the build succeed?
├─ NO → Go to Part 5
└─ YES ↓

Is the app installed on your phone?
├─ NO → Go to Part 6
└─ YES ↓

🎉 YOU'RE DONE! Test the app!
```

---

## 🔄 "I Need to Start Over" Reset Guide

**If something went really wrong and you want to start fresh:**

### Full Reset (Nuclear Option):
1. Uninstall Android Studio
2. Delete `C:\flutter` folder
3. Delete `Documents\AndroidProjects` folder
4. Restart computer
5. Start from Part 1, Step 1.1

### Partial Reset (Project Only):
1. Close Android Studio
2. Delete `Documents\AndroidProjects\kilo` folder
3. Start from Part 3

### Soft Reset (Build Only):
1. In Android Studio Terminal: `flutter clean`
2. Build → Clean Project
3. Start from Part 5

---

## 📱 Phone Connection Troubleshooting Flowchart

```
Phone not showing in "adb devices"?
    ↓
Is USB debugging enabled?
├─ NO → Enable it in Developer Options
└─ YES ↓
    ↓
Did you allow USB debugging popup?
├─ NO → Unplug and replug, tap "Allow"
└─ YES ↓
    ↓
Try different USB cable
    ↓
Still not working?
    ↓
Try different USB port on computer
    ↓
Still not working?
    ↓
On phone: Swipe down → USB notification → "File Transfer"
    ↓
Still not working?
    ↓
Restart both phone and computer
    ↓
Still not working?
    ↓
In Command Prompt:
    adb kill-server
    adb start-server
    adb devices
```

---

## 🎓 Learning Path

**After you get the app working, here's what to learn next:**

```
Level 1: Basic User
└─→ Install and run the app
    └─→ Grant permissions
        └─→ Test basic features

Level 2: Tester
└─→ Connect to Raspberry Pi
    └─→ Test sensor data
        └─→ Test camera features

Level 3: Modifier
└─→ Open code in Android Studio
    └─→ Make small changes
        └─→ Rebuild and test

Level 4: Developer
└─→ Understand Flutter code
    └─→ Add new features
        └─→ Debug issues
```

**You're starting at Level 1!** That's perfect. 🎯

---

## 💡 Pro Tips

### Tip 1: Save Time on Rebuilds
After the first build, subsequent builds are MUCH faster (2-5 minutes instead of 15).

### Tip 2: Keep Android Studio Open
Don't close Android Studio between builds. It stays "warm" and builds faster.

### Tip 3: Use USB 3.0 Ports
Blue USB ports are faster for transferring the app to your phone.

### Tip 4: Charge Your Phone
Building and installing drains battery. Keep phone plugged in.

### Tip 5: Close Other Programs
Android Studio uses a lot of RAM. Close Chrome, games, etc. while building.

---

## 🎯 Success Metrics

**You know you're successful when:**

✅ All commands work in Command Prompt  
✅ Phone shows in adb devices  
✅ Android Studio opens without errors  
✅ Gradle sync completes  
✅ Build completes with "BUILD SUCCESSFUL"  
✅ App installs on phone  
✅ App opens without crashing  
✅ Sensors show data  
✅ Camera preview works  

**If you have all 9 checkmarks, you're 100% successful!** 🎉