# AndroidManifest.xml Fix Guide

## Problem
Your AndroidManifest.xml has several errors:
1. Empty application name placeholder: `android:name="${}"`
2. Unresolved class references for MainActivity, BootReceiver, UsbReceiver, and ViamBackgroundService

## Solution

### Step 1: Fix the AndroidManifest.xml

Replace your current `android/app/src/main/AndroidManifest.xml` with this corrected version:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.viam_pixel4a_sensors">

    <!-- Internet and Network -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    
    <!-- Camera -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.front" android:required="false" />
    
    <!-- Audio -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    
    <!-- USB -->
    <uses-permission android:name="android.permission.USB_PERMISSION" />
    <uses-feature android:name="android.hardware.usb.host" />
    
    <!-- Sensors -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.VIBRATE" />
    
    <!-- Storage -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- Boot and Background Service -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_CAMERA" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
    
    <!-- Location (for foreground service) -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <application
        android:label="Viam Pixel 4a Sensors"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Boot receiver for auto-start -->
        <receiver android:name=".BootReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter android:priority="1000">
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>

        <!-- USB device attachment receiver -->
        <receiver android:name=".UsbReceiver"
            android:enabled="true"
            android:exported="true">
            <intent-filter android:priority="1000">
                <action android:name="android.hardware.usb.action.USB_DEVICE_ATTACHED" />
                <action android:name="android.hardware.usb.action.USB_DEVICE_DETACHED" />
            </intent-filter>
        </receiver>

        <!-- Background service -->
        <service
            android:name=".ViamBackgroundService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="location|camera|microphone" />

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### Step 2: Verify Kotlin File Locations

Make sure your Kotlin files are in the correct location:

```
android/app/src/main/kotlin/com/example/viam_pixel4a_sensors/
├── MainActivity.kt
├── BootReceiver.kt
├── UsbReceiver.kt
└── ViamBackgroundService.kt
```

### Step 3: Check Package Declaration

Each Kotlin file should start with:
```kotlin
package com.example.viam_pixel4a_sensors
```

### Step 4: Sync and Rebuild

After making these changes:
1. In Android Studio: File → Sync Project with Gradle Files
2. Build → Clean Project
3. Build → Rebuild Project

## Key Changes Made

1. **Removed empty placeholder**: Deleted `android:name="${}"` from application tag
2. **Added missing permissions**: Added foreground service type permissions
3. **Fixed receiver priorities**: Adjusted intent filter priorities
4. **Changed service export**: Set ViamBackgroundService to `android:exported="false"` for security
5. **Removed problematic action**: Removed `PACKAGE_REPLACED` with data scheme from BootReceiver

## If Errors Persist

If you still see "Unresolved class" errors:

1. **Check build.gradle**: Ensure Kotlin is properly configured
2. **Invalidate Caches**: File → Invalidate Caches / Restart
3. **Check file names**: Ensure Kotlin files match the class names exactly
4. **Verify package**: Ensure all files have the correct package declaration

## Testing

After fixing, test that:
- App builds without errors
- App installs on device
- Boot receiver works (restart phone)
- USB receiver detects connections
- Background service starts properly