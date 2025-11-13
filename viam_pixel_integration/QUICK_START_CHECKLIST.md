# 🚀 Quick Start Checklist

## ✅ Step-by-Step Progress Tracker

### Phase 1: Install Required Tools
- [ ] **Android Studio installed**
  - Download from https://developer.android.com/studio
  - Run installer with "Standard" settings
  - Verify: Open Android Studio

- [ ] **Flutter SDK installed**
  - Windows: Download from https://flutter.dev/docs/get-started/install/windows
  - Extract to `C:\flutter\`
  - Add `C:\flutter\bin` to PATH
  - Verify: Open Command Prompt, type `flutter --version`

- [ ] **Android SDK configured**
  - Open Android Studio → Tools → SDK Manager
  - Install Android 13 (API level 33)
  - Install Build-Tools 33.0.0
  - Verify: `flutter doctor` shows green Android toolchain

### Phase 2: Setup Your Pixel 4a
- [ ] **Developer Options enabled**
  - Settings → About phone → Tap "Build number" 7 times
  - Settings → System → Developer options

- [ ] **USB Debugging enabled**
  - In Developer options: Enable "USB debugging"
  - When prompted: Check "Always allow from this computer"

- [ ] **Connection tested**
  - Connect phone to PC via USB
  - Open Command Prompt: `adb devices`
  - Should see your device listed

### Phase 3: Create Project
- [ ] **Flutter project created**
  - Option A: Android Studio → New Flutter Project
  - Option B: Command line: `flutter create viam_pixel_integration`
  - Verify: Project folder exists

- [ ] **Dependencies installed**
  - Open `pubspec.yaml` and replace contents
  - Run: `flutter pub get`
  - Verify: No error messages

- [ ] **Android permissions configured**
  - Edit `android/app/src/main/AndroidManifest.xml`
  - Copy the provided permissions
  - Save file

### Phase 4: Test Basic App
- [ ] **App runs on device**
  - Connect Pixel 4a to PC
  - In project folder: `flutter run`
  - Verify: App opens on phone

- [ ] **Basic functionality works**
  - Should see Flutter counter app
  - Can tap button to increment counter
  - Hot reload works (press 'r' in terminal)

---

## 🎯 Where to Start Right Now

**If you're completely new to this:**
1. Start with "Install Android Studio" in Phase 1
2. Don't skip the "Verify" steps - they confirm each installation worked
3. Follow the checklist in order

**If you already have some tools:**
1. Run `flutter doctor` to see what's missing
2. Jump to the first unchecked item in the checklist

---

## 🚨 Common Sticking Points

### Most Common Issues:
1. **PATH not set correctly** → Flutter commands not found
2. **USB debugging not enabled** → `adb devices` shows nothing
3. **Android SDK missing** → `flutter doctor` shows red marks
4. **Permission denied** → Need to allow USB debugging on phone

### Quick Fixes:
- **PATH issues:** Restart Command Prompt after setting PATH
- **ADB issues:** `adb kill-server && adb start-server`
- **Build issues:** `flutter clean && flutter pub get`

---

## 💡 Pro Tips for Success

### Before You Start:
1. Make sure you have admin rights on your PC
2. Close all other Android development tools
3. Use a good quality USB cable
4. Keep phone unlocked during development

### During Setup:
1. Follow the checklist exactly - don't skip steps
2. Run the "Verify" commands after each major installation
3. Take screenshots of any error messages
4. Restart your PC if things seem weird

---

## 🆘 If You Get Stuck

### Tell Me:
1. **Which step** you're on (e.g., "Phase 2, USB Debugging")
2. **Exact error message** you're seeing
3. **What you tried** so far
4. **Your operating system** (Windows 10/11, macOS, etc.)

### Quick Commands to Run:
```bash
# Check Flutter installation
flutter doctor -v

# Check Android device connection
adb devices

# Check Android SDK
adb version

# Clean and rebuild
flutter clean
flutter pub get
```

---

## ⏱️ Time Estimates

- **Complete beginner:** 2-3 hours total
- **Some experience:** 1-2 hours
- **Android dev experienced:** 30-45 minutes

---

## 🎉 Success Indicators

You know it's working when:
1. ✅ `flutter doctor` shows all green checkmarks
2. ✅ `adb devices` lists your Pixel 4a
3. ✅ `flutter run` shows app on your phone
4. ✅ You can tap the counter button and see it work

Once you hit these 4 checkpoints, you're ready for the Viam integration!

---

## 📞 Getting Help

**Best way to ask for help:**
> "I'm stuck on Phase 2, Step 3 (USB Debugging). When I run `adb devices`, I get 'no devices'. I've already enabled developer options and USB debugging, but my phone doesn't show up. I'm using Windows 11."

This gives me everything I need to help you specifically!

---

Good luck! 🚀 Let me know which step you're starting with!