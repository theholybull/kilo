# Quick Start Checklist - Get Your App Running NOW! ⚡

**Goal:** Get your Viam Pixel 4a app built and running in 20 minutes.

**Your Setup:**
- ✅ Flutter installed
- ✅ Android Studio installed  
- ✅ Pixel 4a 5G connected
- ❌ Need to fix 2 things

---

## The 5-Step Quick Start

### ☐ Step 1: Accept Android Licenses (2 minutes)
**Open Command Prompt and run:**
```bash
flutter doctor --android-licenses
```
Type `y` for each license and press Enter.

**Verify:**
```bash
flutter doctor
```
Should show `[√] Android toolchain`

---

### ☐ Step 2: Fix pubspec.yaml (1 minute)
**In Android Studio:**
1. Open `pubspec.yaml`
2. Press `Ctrl+F` and search for `viam:`
3. Replace `viam: any` with `viam_sdk: ^0.11.0`
4. Save (`Ctrl+S`)

**OR just copy from `CORRECT_PUBSPEC_REFERENCE.yaml`**

---

### ☐ Step 3: Get Dependencies (2 minutes)
**Right-click `pubspec.yaml` → Flutter → Pub Get**

Should see: `Got dependencies!`

---

### ☐ Step 4: Select Your Device (30 seconds)
**In Android Studio:**
1. Click device dropdown at top
2. Select **Pixel 4a 5G**

---

### ☐ Step 5: Build and Run (10 minutes first time)
**Click the green Run button (▶️) or press `Shift+F10`**

Wait for build... App will launch on your phone!

---

## That's It! 🎉

**Total Time:** ~15-20 minutes

**What Happens Next:**
- App installs on your Pixel 4a 5G
- App launches automatically
- You'll see the Viam interface
- Sensors start working
- Camera initializes
- Ready to connect to your Pi!

---

## If Something Goes Wrong

### "Android licenses not accepted"
→ See **ANDROID_LICENSE_FIX.md**

### "Could not find package viam"
→ See **FIX_VIAM_SDK_ERROR.md**

### Build fails
→ See **BUILD_AND_DEPLOY_GUIDE.md**

### Need detailed help
→ See **TROUBLESHOOTING_FAQ.md**

---

## After First Successful Build

**Subsequent builds are FAST (1-2 minutes)!**

You can:
- Make code changes
- Press `r` in terminal for hot reload (instant updates!)
- Test features
- Connect to your Raspberry Pi
- Deploy to production

---

## Quick Commands Reference

```bash
# Check Flutter setup
flutter doctor

# Accept licenses
flutter doctor --android-licenses

# Get dependencies
flutter pub get

# List connected devices
flutter devices

# Build and run
flutter run

# Build release APK
flutter build apk --release

# Clean project (if issues)
flutter clean
```

---

## Success Indicators

You'll know it worked when:
- ✅ No errors in Android Studio
- ✅ App appears on your phone
- ✅ App launches successfully
- ✅ You see the Viam interface
- ✅ Sensors show data
- ✅ Camera preview works

---

## Ready? Let's Go! 🚀

1. Open Command Prompt
2. Run: `flutter doctor --android-licenses`
3. Open Android Studio
4. Fix pubspec.yaml
5. Click Run

**You'll have a working app in 20 minutes!**