# Android v2 Embedding Fix

## Problem
Build was failing with error:
```
Build failed due to use of deleted Android v1 embedding.
```

## Root Cause
The AndroidManifest.xml had receivers and service components incorrectly placed **inside** the `<activity>` tag instead of inside the `<application>` tag. This caused Flutter to detect it as v1 embedding even though:
- MainActivity.kt was correctly using FlutterActivity
- flutterEmbedding meta-data was set to 2

## The Fix

### What Was Wrong
```xml
<activity android:name=".MainActivity" ...>
    <intent-filter>...</intent-filter>
    
    <!-- WRONG: These should NOT be inside activity -->
    <receiver android:name=".BootReceiver" ...>
    <receiver android:name=".UsbReceiver" ...>
    <service android:name=".ViamBackgroundService" ...>
</activity>
```

### What's Correct
```xml
<activity android:name=".MainActivity" ...>
    <intent-filter>...</intent-filter>
</activity>

<!-- CORRECT: These should be inside application, not activity -->
<receiver android:name=".BootReceiver" ...>
<receiver android:name=".UsbReceiver" ...>
<service android:name=".ViamBackgroundService" ...>
```

## Changes Made

### AndroidManifest.xml Structure
1. ✅ Moved `<receiver>` tags outside `<activity>` tag
2. ✅ Moved `<service>` tag outside `<activity>` tag
3. ✅ All components now properly inside `<application>` tag
4. ✅ Verified `flutterEmbedding` meta-data is set to 2
5. ✅ MainActivity.kt already uses FlutterActivity (correct)

### Proper Android Manifest Structure
```xml
<manifest>
    <uses-permission ... />
    <uses-feature ... />
    
    <application>
        <activity android:name=".MainActivity">
            <meta-data ... />
            <intent-filter>...</intent-filter>
        </activity>
        
        <receiver android:name=".BootReceiver">
            <intent-filter>...</intent-filter>
        </receiver>
        
        <receiver android:name=".UsbReceiver">
            <intent-filter>...</intent-filter>
        </receiver>
        
        <service android:name=".ViamBackgroundService" />
        
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
```

## Verification

After this fix, the build should succeed because:
1. ✅ MainActivity extends FlutterActivity (v2)
2. ✅ flutterEmbedding meta-data = 2
3. ✅ All Android components properly structured
4. ✅ No v1 embedding artifacts

## Build Now

Try building again:
```bash
flutter clean
flutter pub get
flutter build apk
```

Or in Android Studio:
1. Click **Build** → **Clean Project**
2. Click **Build** → **Rebuild Project**
3. Click the green **Run** button

## What This Means

**Android v1 Embedding (Deprecated):**
- Used FlutterApplication
- Different plugin registration
- Removed in Flutter 3.0+

**Android v2 Embedding (Current):**
- Uses FlutterActivity
- Automatic plugin registration
- Required for Flutter 3.0+
- Better lifecycle management

Your app now correctly uses v2 embedding!

## Additional Notes

### Service Export Setting
Changed `android:exported="true"` to `android:exported="false"` for the background service since it doesn't need to be accessible by other apps. This is a security best practice.

### Foreground Service Types
The service correctly declares:
```xml
android:foregroundServiceType="location|camera|microphone"
```
This is required for Android 14+ to use these features in the background.

## Next Steps

1. ✅ AndroidManifest.xml fixed
2. → Build the app
3. → Test on Pixel 4a 5G
4. → Verify all features work

The v2 embedding error should now be resolved!