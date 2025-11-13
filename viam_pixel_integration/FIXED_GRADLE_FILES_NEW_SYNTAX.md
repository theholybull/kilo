# 🔧 Fixed Gradle Files - New Plugin Syntax

## 🎯 The Problem

Modern Gradle requires using the `plugins {}` block instead of `buildscript {}` and `classpath`. The old syntax no longer works.

---

## ✅ Corrected Files - Copy These Exactly

### File 1: android/build.gradle (Root)

**Location:** `android/build.gradle`

**Replace entire content with:**

```gradle
plugins {
    id "com.android.application" version "7.3.0" apply false
    id "com.android.library" version "7.3.0" apply false
    id "org.jetbrains.kotlin.android" version "1.7.10" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

---

### File 2: android/settings.gradle

**Location:** `android/settings.gradle`

**Replace entire content with:**

```gradle
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "7.3.0" apply false
    id "org.jetbrains.kotlin.android" version "1.7.10" apply false
}

include ":app"
```

---

### File 3: android/app/build.gradle

**Location:** `android/app/build.gradle`

**Replace entire content with:**

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "com.example.viam_pixel4a_sensors"
    compileSdk 33
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
        minSdk 21
        targetSdk 33
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
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10"
}
```

---

## 🎯 Key Changes Made

### Old Syntax (Doesn't Work):
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
    }
}
```

### New Syntax (Works):
```gradle
plugins {
    id "com.android.application" version "7.3.0" apply false
}
```

---

## 📋 Step-by-Step Fix

1. **Open android/build.gradle**
   - Select all (Ctrl+A)
   - Delete
   - Paste File 1 content above
   - Save (Ctrl+S)

2. **Open android/settings.gradle**
   - Select all (Ctrl+A)
   - Delete
   - Paste File 2 content above
   - Save (Ctrl+S)

3. **Open android/app/build.gradle**
   - Select all (Ctrl+A)
   - Delete
   - Paste File 3 content above
   - Save (Ctrl+S)

4. **Sync Gradle**
   - Click elephant icon 🐘
   - Wait for sync
   - Should see "BUILD SUCCESSFUL"

---

## ✅ Verification

After making these changes:

1. ✅ No more "classpath" errors
2. ✅ Plugins load correctly
3. ✅ Gradle sync completes
4. ✅ "BUILD SUCCESSFUL" appears

---

## 🚨 If You Still Get Errors

### Error: "flutter.sdk not set"

**Solution:**
Make sure `android/local.properties` exists with:
```properties
flutter.sdk=C:\\flutter
```
(Use your actual Flutter SDK path)

### Error: "Plugin not found"

**Solution:**
1. Update Gradle wrapper to 7.5+
2. File → Invalidate Caches / Restart
3. Try sync again

### Error: "Version conflict"

**Solution:**
Make sure all three files use the same versions:
- Android plugin: 7.3.0
- Kotlin: 1.7.10
- Gradle: 7.5

---

## 💡 Why This Works

**The Problem:** Gradle 7.0+ deprecated the old `buildscript` syntax and requires the new `plugins {}` block.

**The Solution:** These files use the modern plugin syntax that Gradle expects.

**The Result:** Gradle can find and load all plugins correctly.

---

## 🎊 Success!

Once you apply these changes:
- ✅ All plugin errors fixed
- ✅ Gradle sync works
- ✅ Ready to build APK

Copy the three files above and you should be good to go! 🚀