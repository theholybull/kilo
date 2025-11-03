# 🔧 Fixed pubspec.yaml - Remove Duplicate Keys

## 🎯 The Error

```
Error on line 55, column 3: Duplicate mapping key.
network_info_plus: ^4.0.2
```

**Problem:** The same package is listed twice in your `pubspec.yaml` file.

---

## ✅ Fixed pubspec.yaml

**Location:** `pubspec.yaml` (root of project)

**Replace entire content with:**

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

---

## 🎯 How to Fix

### Step 1: Open pubspec.yaml

1. In Android Studio, find `pubspec.yaml` in the left panel
2. Double-click to open it

### Step 2: Replace Content

1. Select all (Ctrl+A)
2. Delete
3. Copy the fixed content above
4. Paste
5. Save (Ctrl+S)

### Step 3: Get Dependencies

1. Right-click on `pubspec.yaml`
2. Choose "Flutter" → "Pub Get"
3. Wait for "Got dependencies!"

**✅ Done! Error should be fixed.**

---

## 🔍 What Was Wrong

Your `pubspec.yaml` had `network_info_plus` listed twice:

```yaml
dependencies:
  network_info_plus: ^4.0.2  # First time
  # ... other packages ...
  network_info_plus: ^4.0.2  # Second time (DUPLICATE!)
```

YAML doesn't allow duplicate keys. Each package can only be listed once.

---

## 📋 Common pubspec.yaml Mistakes

### Mistake 1: Duplicate Keys
```yaml
# ❌ Wrong
dependencies:
  http: ^1.1.0
  http: ^1.1.0  # Duplicate!

# ✅ Correct
dependencies:
  http: ^1.1.0
```

### Mistake 2: Wrong Indentation
```yaml
# ❌ Wrong
dependencies:
http: ^1.1.0  # Not indented!

# ✅ Correct
dependencies:
  http: ^1.1.0  # Properly indented with 2 spaces
```

### Mistake 3: Missing Colon
```yaml
# ❌ Wrong
dependencies
  http: ^1.1.0

# ✅ Correct
dependencies:
  http: ^1.1.0
```

---

## ✅ Verification

After fixing, you should be able to:

1. ✅ Open the project in Android Studio without errors
2. ✅ Run "Pub Get" successfully
3. ✅ See "Got dependencies!" message
4. ✅ Build the app

---

## 🚨 If You Still Get Errors

### Error: "Version conflict"

**Solution:**
```bash
flutter pub cache repair
flutter pub get
```

### Error: "Package not found"

**Solution:**
Check internet connection and try again.

### Error: "SDK version mismatch"

**Solution:**
Update the SDK constraint:
```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
```

---

## 💡 Pro Tips

### Tip 1: Check for Duplicates
Before saving, search for each package name to make sure it only appears once.

### Tip 2: Use Proper Indentation
Always use 2 spaces for indentation in YAML files, never tabs.

### Tip 3: Validate YAML
You can use online YAML validators to check for syntax errors.

### Tip 4: Keep It Organized
Group related packages together with comments:
```yaml
dependencies:
  # UI
  cupertino_icons: ^1.0.2
  
  # Network
  http: ^1.1.0
  
  # Sensors
  sensors_plus: ^4.0.2
```

---

## 🎊 Success!

Once you fix the duplicate key:
- ✅ pubspec.yaml will be valid
- ✅ Flutter can read the file
- ✅ Dependencies will install
- ✅ Project will open correctly

**Copy the fixed pubspec.yaml above and you're good to go!** 🚀