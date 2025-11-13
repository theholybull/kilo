# 🔧 Fix: Android Plugin Not Found Error

## 🎯 The Error

```
Plugin with id 'com.android.application' not found.
```

This means the Android Gradle plugin is not configured correctly in your project.

---

## ✅ Solution 1: Fix Root build.gradle (MOST COMMON!)

The root `build.gradle` file is missing the Android plugin dependency.

### Step 1: Open the ROOT build.gradle

**In Android Studio:**
1. Look at the **left panel** (Project view)
2. Find the **root** `build.gradle` file (at the very top level)
3. **NOT** the one inside `android/app/`
4. Click on it to open

**File location:**
```
viam_pixel_integration/
├── android/
│   └── app/
│       └── build.gradle  ❌ NOT this one
├── build.gradle          ✅ THIS ONE!
└── pubspec.yaml
```

### Step 2: Check the Content

The file should look like this:

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

### Step 3: If File is Missing or Wrong

**Create/Replace the file with this content:**

1. Right-click on the project root in left panel
2. New → File
3. Name it: `build.gradle`
4. Paste this content:

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

5. Save the file (Ctrl+S)

### Step 4: Sync Gradle

1. Click the elephant icon 🐘 in the toolbar
2. OR: File → Sync Project with Gradle Files
3. Wait for sync to complete

**✅ Success:** Sync completes without errors

---

## ✅ Solution 2: Fix android/build.gradle

Sometimes the issue is in the `android/build.gradle` file.

### Step 1: Open android/build.gradle

**In Android Studio:**
1. Left panel → android folder
2. Click on `build.gradle` inside android folder
3. Open it

**File location:**
```
viam_pixel_integration/
├── android/
│   └── build.gradle  ✅ THIS ONE!
└── build.gradle
```

### Step 2: Check the Content

The file should look like this:

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

### Step 3: If Wrong, Replace It

Replace the entire content with the code above, then:
1. Save (Ctrl+S)
2. Sync Gradle (elephant icon 🐘)

**✅ Success:** Sync completes without errors

---

## ✅ Solution 3: Check settings.gradle

The `settings.gradle` file might be missing plugin management.

### Step 1: Open settings.gradle

**File location:**
```
viam_pixel_integration/
├── android/
│   └── settings.gradle  ✅ THIS ONE!
└── settings.gradle
```

### Step 2: Check Content

It should include:

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

### Step 3: If Missing pluginManagement

Add this at the very top:

```gradle
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
```

Then:
1. Save (Ctrl+S)
2. Sync Gradle

**✅ Success:** Sync completes without errors

---

## ✅ Solution 4: Update Gradle Version

If the plugin version is too old or incompatible:

### Step 1: Open gradle-wrapper.properties

**File location:**
```
viam_pixel_integration/
└── android/
    └── gradle/
        └── wrapper/
            └── gradle-wrapper.properties  ✅ THIS ONE!
```

### Step 2: Check Gradle Version

Look for this line:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

### Step 3: Update if Needed

Change the version to 7.5 or higher:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
```

Then:
1. Save (Ctrl+S)
2. Sync Gradle
3. Wait for Gradle to download (might take a few minutes)

**✅ Success:** New Gradle version downloads and sync completes

---

## 🔍 Quick Diagnosis

**Check which file is the problem:**

1. **If error says "root project 'app'"** → Fix `android/build.gradle`
2. **If error says "root project 'viam_pixel_integration'"** → Fix root `build.gradle`
3. **If error mentions "plugin management"** → Fix `settings.gradle`

---

## 📋 Complete File Checklist

Make sure these files exist and have correct content:

### File 1: Root build.gradle
**Location:** `viam_pixel_integration/build.gradle`
**Must have:** `classpath 'com.android.tools.build:gradle:7.3.0'`

### File 2: android/build.gradle
**Location:** `viam_pixel_integration/android/build.gradle`
**Must have:** `classpath 'com.android.tools.build:gradle:7.3.0'`

### File 3: android/app/build.gradle
**Location:** `viam_pixel_integration/android/app/build.gradle`
**Must have:** 
- `apply plugin: 'com.android.application'`
- `namespace "com.example.viam_pixel4a_sensors"`

### File 4: settings.gradle
**Location:** `viam_pixel_integration/android/settings.gradle`
**Must have:** `pluginManagement { ... }` block

### File 5: gradle-wrapper.properties
**Location:** `viam_pixel_integration/android/gradle/wrapper/gradle-wrapper.properties`
**Must have:** `gradle-7.5-all.zip` or higher

---

## 🚨 Common Mistakes

### Mistake 1: Editing Wrong build.gradle
There are THREE build.gradle files:
- Root `build.gradle` ✅ Edit this
- `android/build.gradle` ✅ Edit this
- `android/app/build.gradle` ⚠️ Usually don't need to edit

### Mistake 2: Wrong Plugin Version
Make sure versions match:
- Gradle version: 7.5
- Android plugin: 7.3.0
- Kotlin: 1.7.10

### Mistake 3: Forgetting to Sync
After ANY change to .gradle files:
1. Save the file
2. Sync Gradle (elephant icon)
3. Wait for completion

---

## ✅ Verification Steps

After making changes:

1. **Save all files** (Ctrl+S)
2. **Sync Gradle** (elephant icon 🐘)
3. **Check Build panel** at bottom
4. **Look for:** "BUILD SUCCESSFUL"
5. **No errors** in red text

**If all pass → Problem fixed!** ✅

---

## 🎯 Step-by-Step Fix (Recommended)

**Follow these steps in order:**

1. ✅ Open root `build.gradle`
2. ✅ Verify it has the Android plugin classpath
3. ✅ If missing, add it
4. ✅ Save file
5. ✅ Open `android/build.gradle`
6. ✅ Verify it has the same content
7. ✅ If missing, add it
8. ✅ Save file
9. ✅ Open `android/settings.gradle`
10. ✅ Verify it has pluginManagement block
11. ✅ If missing, add it
12. ✅ Save file
13. ✅ Sync Gradle
14. ✅ Wait for "BUILD SUCCESSFUL"

---

## 💡 Pro Tips

### Tip 1: Copy from Working Project
If you have another Flutter project that works, copy these files from it:
- Root build.gradle
- android/build.gradle
- android/settings.gradle

### Tip 2: Use Flutter Create
If files are completely broken:
```
flutter create --org com.example .
```
This regenerates the Android files.

### Tip 3: Check Flutter Version
Make sure Flutter is up to date:
```
flutter upgrade
```

---

## 🆘 Still Getting the Error?

If none of the solutions work:

### Nuclear Option:
1. Close Android Studio
2. Delete `android` folder completely
3. Open Terminal
4. Run: `flutter create --org com.example .`
5. This recreates the entire Android project
6. Reopen in Android Studio
7. Apply your previous fixes (namespace, etc.)

---

## 📞 Need More Help?

Provide this information:
1. Which solution you tried
2. Content of your root build.gradle file
3. Content of your android/build.gradle file
4. Full error message from Build panel
5. Gradle version (from gradle-wrapper.properties)

---

## ✅ Success Indicators

You know it's fixed when:

1. ✅ Gradle sync completes without errors
2. ✅ "BUILD SUCCESSFUL" appears in Build panel
3. ✅ No red error text
4. ✅ Project structure shows properly in left panel
5. ✅ Can proceed to next step (building the app)

**Once you see "BUILD SUCCESSFUL" → Continue with the main guide!** 🎉