# Fix: "could not find package viam" Error

## The Problem
You're getting this error:
```
Because viam_pixel_integration depends on viam any which doesn't exist 
(could not find package viam at https://pub.dev), version solving failed.
```

## Root Cause
The error says "package viam" but the correct package name is "viam_sdk". This means:
1. Your local `pubspec.yaml` might have an old reference to `viam` instead of `viam_sdk`
2. OR there's a cached/old version of the file

## The Solution

### Step 1: Verify Your pubspec.yaml
Open your `pubspec.yaml` file and look for the dependencies section. It should say:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Viam SDK for robot communication
  viam_sdk: ^0.11.0    # ← Should be viam_SDK not just viam
```

**If you see `viam: any` or just `viam:` anywhere, change it to `viam_sdk: ^0.11.0`**

### Step 2: Clean Flutter Cache
Sometimes Flutter caches old dependency information. Clean it:

**Option A: Using Android Studio (GUI)**
1. In Android Studio, go to: **File → Invalidate Caches**
2. Check "Clear file system cache and Local History"
3. Click "Invalidate and Restart"

**Option B: Using Terminal (if you can)**
```bash
cd C:\Users\jbates\develop\viam_pixel_integration
flutter clean
flutter pub cache repair
flutter pub get
```

**Option C: Manual Cache Clear**
1. Close Android Studio completely
2. Navigate to: `C:\Users\jbates\AppData\Local\Pub\Cache`
3. Delete the entire `Cache` folder
4. Reopen Android Studio
5. Right-click `pubspec.yaml` → Flutter → Pub Get

### Step 3: Verify the Fix
After cleaning, run Flutter Pub Get again. You should see:
```
Resolving dependencies...
+ viam_sdk 0.11.0
...
Changed X dependencies!
```

## If It Still Fails

### Check for Multiple pubspec.yaml Files
Make sure you're editing the RIGHT pubspec.yaml:
- **Correct location**: `C:\Users\jbates\develop\viam_pixel_integration\pubspec.yaml`
- **Wrong location**: `C:\Users\jbates\develop\viam_pixel_integration\android\pubspec.yaml` (doesn't exist)

### Verify Package Exists
The `viam_sdk` package DOES exist on pub.dev:
- **Package URL**: https://pub.dev/packages/viam_sdk
- **Latest Version**: 0.11.0 (published 6 days ago)
- **Publisher**: viam.com (verified)

## What the GitHub Version Has
The version in the GitHub repository (`theholybull/kilo` branch `viam-pixel-integration`) has the CORRECT dependency:
```yaml
viam_sdk: ^0.11.0
```

So if your local file is different, you need to update it to match the GitHub version.

## Quick Fix: Replace Your Local File
If nothing else works, you can replace your local pubspec.yaml with the correct version from GitHub:

1. Go to: https://github.com/theholybull/kilo/blob/viam-pixel-integration/pubspec.yaml
2. Click "Raw" button
3. Copy all the content
4. Open your local `pubspec.yaml` in Android Studio
5. Select All (Ctrl+A) and Delete
6. Paste the GitHub content
7. Save (Ctrl+S)
8. Right-click → Flutter → Pub Get

## Expected Result
After the fix, `flutter pub get` should successfully download:
- viam_sdk 0.11.0
- All its dependencies (grpc, protobuf, flutter_webrtc, etc.)
- All other packages in your pubspec.yaml

## Need More Help?
If you're still getting the error after trying all these steps, please:
1. Take a screenshot of your pubspec.yaml file (the dependencies section)
2. Take a screenshot of the full error message
3. Share both so I can see exactly what's happening