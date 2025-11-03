# 📄 Fixed build.gradle Files - Copy & Paste Ready

## 🎯 Use These Files to Fix Your Error

Copy and paste these exact files to fix the "Plugin with id 'com.android.application' not found" error.

---

## 📁 File 1: Root build.gradle

**Location:** `viam_pixel_integration/build.gradle`

**Copy this entire content:**

```gradle
buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
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

**How to use:**
1. Open `build.gradle` at the root of your project
2. Select ALL content (Ctrl+A)
3. Delete it
4. Paste the content above
5. Save (Ctrl+S)

---

## 📁 File 2: android/build.gradle

**Location:** `viam_pixel_integration/android/build.gradle`

**Copy this entire content:**

```gradle
buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
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

**How to use:**
1. Open `android/build.gradle`
2. Select ALL content (Ctrl+A)
3. Delete it
4. Paste the content above
5. Save (Ctrl+S)

---

## 📁 File 3: android/settings.gradle

**Location:** `viam_pixel_integration/android/settings.gradle`

**Copy this entire content:**

```gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

include ':app'

def localPropertiesFile = new File(rootProject.projectDir, "local.properties")
def properties = new Properties()

assert localPropertiesFile.exists()
localPropertiesFile.withReader("UTF-8") { reader -> properties.load(reader) }

def flutterSdkPath = properties.getProperty("flutter.sdk")
assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
apply from: "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle"
```

**How to use:**
1. Open `android/settings.gradle`
2. Select ALL content (Ctrl+A)
3. Delete it
4. Paste the content above
5. Save (Ctrl+S)

---

## 📁 File 4: android/app/build.gradle (Already Fixed)

**Location:** `viam_pixel_integration/android/app/build.gradle`

**This should already be correct from earlier, but verify it has:**

```gradle
android {
    namespace "com.example.viam_pixel4a_sensors"
    compileSdkVersion 33
    // ... rest of file
}
```

**Key points:**
- First line inside `android {` should be `namespace "com.example.viam_pixel4a_sensors"`
- NO `package=` attribute anywhere

---

## 📁 File 5: gradle-wrapper.properties

**Location:** `viam_pixel_integration/android/gradle/wrapper/gradle-wrapper.properties`

**Copy this entire content:**

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

**How to use:**
1. Open `android/gradle/wrapper/gradle-wrapper.properties`
2. Select ALL content (Ctrl+A)
3. Delete it
4. Paste the content above
5. Save (Ctrl+S)

---

## ✅ After Copying All Files

### Step 1: Save Everything
- Make sure all files are saved (Ctrl+S)

### Step 2: Sync Gradle
1. Click the elephant icon 🐘 in the toolbar
2. OR: File → Sync Project with Gradle Files
3. Wait for sync (might take 2-3 minutes first time)

### Step 3: Check for Success
- Look at the bottom of Android Studio
- Should see: "BUILD SUCCESSFUL" in green
- No red error messages

**✅ If you see "BUILD SUCCESSFUL" → Problem fixed!**

---

## 🎯 Quick Copy-Paste Workflow

**Follow this exact order:**

1. ✅ Copy File 1 → Paste into root `build.gradle` → Save
2. ✅ Copy File 2 → Paste into `android/build.gradle` → Save
3. ✅ Copy File 3 → Paste into `android/settings.gradle` → Save
4. ✅ Check File 4 → Verify `namespace` line exists
5. ✅ Copy File 5 → Paste into `gradle-wrapper.properties` → Save
6. ✅ Click elephant icon 🐘 to sync
7. ✅ Wait for "BUILD SUCCESSFUL"

**Total time: 5 minutes**

---

## 🔍 File Locations Visual Guide

```
viam_pixel_integration/
├── build.gradle                          ← FILE 1
├── android/
│   ├── build.gradle                      ← FILE 2
│   ├── settings.gradle                   ← FILE 3
│   ├── app/
│   │   └── build.gradle                  ← FILE 4 (verify only)
│   └── gradle/
│       └── wrapper/
│           └── gradle-wrapper.properties ← FILE 5
└── pubspec.yaml
```

---

## 🚨 Common Issues

### Issue: "Can't find the file"

**Solution:**
- Make sure you're looking in the right folder
- Use the Project view in the left panel
- Expand folders by clicking the arrows

### Issue: "File is read-only"

**Solution:**
- Right-click the file
- Properties → Uncheck "Read-only"
- Try again

### Issue: "Sync still fails after copying"

**Solution:**
1. Close Android Studio
2. Delete these folders:
   - `android/.gradle`
   - `android/build`
   - `.gradle` (in project root)
3. Reopen Android Studio
4. Sync again

---

## 💡 Pro Tips

### Tip 1: Use Find & Replace
If you need to change package name:
- Press Ctrl+Shift+R
- Find: `com.example.viam_pixel4a_sensors`
- Replace with: your package name
- Click "Replace All"

### Tip 2: Keep Backups
Before replacing files:
- Right-click file → Copy
- Paste somewhere safe
- If something breaks, you can restore

### Tip 3: Check Line Endings
If you get weird errors:
- File → File Properties
- Line Separators → Unix (LF)
- Save

---

## ✅ Verification Checklist

After copying all files, verify:

- [ ] Root build.gradle has `classpath 'com.android.tools.build:gradle:7.3.0'`
- [ ] android/build.gradle has same classpath
- [ ] android/settings.gradle has `pluginManagement` block
- [ ] android/app/build.gradle has `namespace` line
- [ ] gradle-wrapper.properties has `gradle-7.5-all.zip`
- [ ] All files saved (no asterisk * in tab names)
- [ ] Gradle synced (clicked elephant icon)
- [ ] "BUILD SUCCESSFUL" appears at bottom

**If all checked → You're ready to build!** ✅

---

## 🎊 Success!

Once you see "BUILD SUCCESSFUL":

1. ✅ The Android plugin error is fixed
2. ✅ Gradle is properly configured
3. ✅ You can continue with the main guide
4. ✅ Next step: Build the APK!

**You're almost there!** 🚀