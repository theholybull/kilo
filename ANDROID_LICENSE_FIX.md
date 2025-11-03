# Fix: Android License Status Unknown

## The Issue
Flutter Doctor shows:
```
X Android license status unknown.
  Run `flutter doctor --android-licenses` to accept the SDK licenses.
```

## Why This Matters
Without accepting the Android SDK licenses, you cannot build Android apps. This is a one-time setup step.

## The Fix (5 minutes)

### Method 1: Using Android Studio (GUI - EASIEST)
1. Open **Android Studio**
2. Go to **File** → **Settings** (or **Android Studio** → **Preferences** on Mac)
3. Navigate to **Appearance & Behavior** → **System Settings** → **Android SDK**
4. Click on the **SDK Tools** tab
5. Check the box for **Android SDK Command-line Tools (latest)**
6. Click **Apply** and **OK**
7. Wait for installation to complete
8. Close and reopen Android Studio

### Method 2: Using Command Line (FASTEST)
1. Open **Command Prompt** or **PowerShell**
2. Run this command:
   ```bash
   flutter doctor --android-licenses
   ```
3. You'll see several license agreements
4. For each one, type `y` and press Enter
5. Continue until all licenses are accepted

**Example of what you'll see:**
```
Review licenses that have not been accepted (y/N)? y
1/7: License android-sdk-license:
---------------------------------------
[License text here]
---------------------------------------
Accept? (y/N): y

2/7: License android-sdk-preview-license:
...
```

Just keep typing `y` and pressing Enter for each license.

### Method 3: If Command Line Doesn't Work
If you get an error like "cmdline-tools not found":

1. Open **Android Studio**
2. Go to **Tools** → **SDK Manager**
3. Click **SDK Tools** tab
4. Check these items:
   - ✓ Android SDK Command-line Tools (latest)
   - ✓ Android SDK Build-Tools
   - ✓ Android SDK Platform-Tools
5. Click **Apply** and wait for installation
6. Try Method 2 again

## Verification
After accepting licenses, run:
```bash
flutter doctor
```

You should see:
```
[√] Android toolchain - develop for Android devices (Android SDK version 36.1.0)
```

**No more X mark!**

## Common Issues

### Issue: "cmdline-tools component is missing"
**Solution:** Install Android SDK Command-line Tools using Method 1 or Method 3 above.

### Issue: "java.lang.NoClassDefFoundError"
**Solution:** Your Java installation is fine (you have JDK 21). Just install the command-line tools.

### Issue: Command hangs or freezes
**Solution:** 
1. Press `Ctrl+C` to cancel
2. Close Android Studio completely
3. Reopen and try again

## What These Licenses Are
The Android SDK licenses are legal agreements from Google that you must accept to:
- Use the Android SDK
- Build Android apps
- Distribute apps on Google Play
- Use Android emulators

This is a standard requirement for all Android developers.

## Next Steps
After accepting licenses:
1. ✓ Android licenses accepted
2. → Fix pubspec.yaml (viam_sdk issue)
3. → Run flutter pub get
4. → Build your app
5. → Install on Pixel 4a 5G

## Time Required
- Method 1 (GUI): ~5 minutes
- Method 2 (Command): ~2 minutes
- Method 3 (If issues): ~10 minutes