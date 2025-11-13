# 🔧 Fix Your Local pubspec.yaml File

## 🎯 The Problem

Your **local** `pubspec.yaml` file on your computer still has the duplicate `network_info_plus` entry. The GitHub version is fixed, but you need to update your local copy.

---

## ✅ Quick Fix - Replace Your Local File

### Method 1: Manual Edit (Fastest)

1. **Open pubspec.yaml** in Android Studio (left panel)
2. **Press Ctrl+F** (Find)
3. **Search for:** `network_info_plus`
4. **You'll find it appears TWICE**
5. **Delete one of them** (keep only one)
6. **Save** (Ctrl+S)
7. **Right-click pubspec.yaml** → Flutter → Pub Get

---

### Method 2: Replace Entire File (Safest)

**Copy this EXACT content and replace your entire pubspec.yaml:**

```yaml
name: viam_pixel_integration
description: Viam Pixel 4a sensor integration app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # UI
  cupertino_icons: ^1.0.2
  
  # State Management
  provider: ^6.0.5
  
  # Permissions
  permission_handler: ^10.4.3
  
  # Camera & Vision
  camera: ^0.10.5+2
  google_ml_kit: ^0.14.0
  image: ^4.0.17
  
  # Audio
  flutter_sound: ^9.2.13
  
  # Sensors
  sensors_plus: ^4.0.2
  
  # Network & Connectivity
  http: ^1.1.0
  network_info_plus: ^4.0.2
  
  # USB
  usb_serial: ^0.4.0
  
  # Viam SDK
  viam: ^0.71.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

**Steps:**
1. Open `pubspec.yaml` in Android Studio
2. Select ALL (Ctrl+A)
3. Delete
4. Paste the content above
5. Save (Ctrl+S)
6. Right-click → Flutter → Pub Get

---

## 🔍 How to Find the Duplicate

**In Android Studio:**

1. Open `pubspec.yaml`
2. Press `Ctrl+F` (Find)
3. Type: `network_info_plus`
4. Press `F3` to find next occurrence
5. You'll see it appears **twice**
6. Delete one of them

**Look for something like this:**

```yaml
dependencies:
  network_info_plus: ^4.0.2  # First one
  # ... other packages ...
  network_info_plus: ^4.0.2  # Second one (DELETE THIS!)
```

---

## ✅ After Fixing

1. **Save the file** (Ctrl+S)
2. **Run Pub Get:**
   - Right-click `pubspec.yaml`
   - Flutter → Pub Get
   - Wait for "Got dependencies!"
3. **Try building for Android again:**
   - Click green play button ▶️
   - Select Pixel 4a
   - Should work now!

---

## 🚨 If You Still Get the Error

### Check Line 55

The error says line 55. Open `pubspec.yaml` and:

1. Go to line 55 (Ctrl+G, type 55)
2. Look at what's there
3. Search above and below for the same package name
4. Delete the duplicate

### Common Locations for Duplicates

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.0.5
  permission_handler: ^10.4.3
  camera: ^0.10.5+2
  google_ml_kit: ^0.14.0
  image: ^4.0.17
  flutter_sound: ^9.2.13
  sensors_plus: ^4.0.2
  http: ^1.1.0
  network_info_plus: ^4.0.2  # ← Should only appear ONCE
  usb_serial: ^0.4.0
  viam: ^0.71.0
  # Check below - is network_info_plus listed again?
```

---

## 💡 Pro Tip

**To avoid this in the future:**

Before adding a package, search for it first:
1. Press Ctrl+F
2. Type the package name
3. If it's already there, just update the version
4. Don't add it again!

---

## ✅ Verification

After fixing, you should be able to:

1. ✅ Save pubspec.yaml without errors
2. ✅ Run "Pub Get" successfully
3. ✅ Build for Android (Pixel 4a)
4. ✅ No "Duplicate mapping key" error

---

## 🎯 Quick Checklist

- [ ] Opened pubspec.yaml in Android Studio
- [ ] Found the duplicate `network_info_plus`
- [ ] Deleted one of them (kept only one)
- [ ] Saved the file (Ctrl+S)
- [ ] Ran Pub Get (right-click → Flutter → Pub Get)
- [ ] Saw "Got dependencies!" message
- [ ] Tried building for Android again

**If all checked → Error should be fixed!** ✅

---

## 🚀 Next Step

After fixing:

1. **Connect Pixel 4a** via USB
2. **Click green play button** ▶️
3. **Select your device**
4. **Build should work now!**

The Windows build works because it doesn't read the same manifest. Android requires a valid pubspec.yaml.

**Fix your local file and try building for Android again!** 🎉