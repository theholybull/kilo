# Package Namespace Fix Guide

## Problem
You're getting this error:
```
Incorrect package="com.example.viam_pixel4a_sensors" found in source AndroidManifest.xml
Setting the namespace via the package attribute in the source AndroidManifest.xml is no longer supported.
```

## Solution

### Step 1: Remove package from AndroidManifest.xml

The AndroidManifest.xml should NOT have the `package` attribute. It should start like this:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
```

NOT like this:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.viam_pixel4a_sensors">
```

### Step 2: Set namespace in build.gradle

The namespace should be defined in `android/app/build.gradle`:

```gradle
android {
    namespace "com.example.viam_pixel4a_sensors"
    compileSdkVersion 33
    
    // ... rest of configuration
}
```

### Step 3: Complete build.gradle Configuration

Your `android/app/build.gradle` should look like this:

```gradle
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.example.viam_pixel4a_sensors"
    compileSdkVersion 33
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.viam_pixel4a_sensors"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

## Quick Fix Steps

1. **Open AndroidManifest.xml** at `android/app/src/main/AndroidManifest.xml`
2. **Remove the package attribute** from the `<manifest>` tag
3. **Open build.gradle** at `android/app/build.gradle`
4. **Add namespace** inside the `android {}` block at the top
5. **Sync Project**: File → Sync Project with Gradle Files
6. **Clean and Rebuild**: Build → Clean Project, then Build → Rebuild Project

## Files to Update

### File 1: android/app/src/main/AndroidManifest.xml
Remove `package="com.example.viam_pixel4a_sensors"` from the first line.

### File 2: android/app/build.gradle
Add `namespace "com.example.viam_pixel4a_sensors"` as the first line inside `android {}` block.

## After Making Changes

1. Sync Project with Gradle Files
2. Clean Project
3. Rebuild Project
4. Run the app

The error should be resolved!