# ⚡ Quick Fix: Enable Gradle (1 Minute!)

## 🎯 The Problem
Gradle is not enabled for your project. No elephant icon, no sync option.

## ✅ The Solution (Try This First!)

### Close and Reopen Correctly

**Step 1: Close Project**
```
File → Close Project
```

**Step 2: Open Correctly**
1. Click **"Open"** on welcome screen
2. Navigate to: `Documents\AndroidProjects\kilo\viam_pixel_integration`
3. **IMPORTANT:** Click on the **"build.gradle"** file (NOT the folder!)
4. Click **"OK"**
5. When asked "Open as Project or File?" → Choose **"Open as Project"**
6. Wait 2-5 minutes for import

**✅ Done!** Elephant icon should appear in toolbar.

---

## 🔍 Where is build.gradle?

```
Documents\AndroidProjects\kilo\viam_pixel_integration\
├── android/
├── lib/
├── test/
├── pubspec.yaml
└── build.gradle  ← CLICK THIS FILE!
```

**Visual:**
```
File Explorer:
Documents → AndroidProjects → kilo → viam_pixel_integration

You should see these files:
📁 android
📁 lib  
📁 test
📄 build.gradle     ← CLICK THIS!
📄 pubspec.yaml
📄 README.md
```

---

## 🚨 If That Doesn't Work

### Option A: Re-download Project

1. **Delete old project:**
   - Close Android Studio
   - Delete: `Documents\AndroidProjects\kilo`

2. **Download fresh:**
   - Go to: https://github.com/theholybull/kilo
   - Click green "Code" button
   - Click "Download ZIP"
   - Extract to: `Documents\AndroidProjects\`
   - Rename folder to "kilo" if needed

3. **Open correctly:**
   - Open Android Studio
   - Click "Open"
   - Click on `build.gradle` file
   - Choose "Open as Project"

---

### Option B: Install Gradle Plugin

1. **Open Settings:**
   ```
   File → Settings (or Ctrl+Alt+S)
   ```

2. **Go to Plugins:**
   ```
   Plugins → Installed tab
   ```

3. **Check for Gradle:**
   - Look for "Gradle" in the list
   - If missing, go to "Marketplace" tab
   - Search "Gradle"
   - Install it
   - Restart Android Studio

---

## ✅ How to Know It Worked

After reopening, you should see:

1. **Elephant icon** 🐘 in top toolbar
2. **"Sync Project with Gradle Files"** in File menu
3. **"Gradle"** tab on right side of window
4. **Proper Android structure** in left panel

**If you see all 4 → Success!** ✅

---

## 🎯 What to Do Next

Once Gradle is enabled:

1. ✅ Continue with the main guide
2. ✅ Run `flutter pub get` in Terminal
3. ✅ Fix AndroidManifest.xml
4. ✅ Fix build.gradle  
5. ✅ Sync with Gradle
6. ✅ Build the app!

---

## 💡 Pro Tip

**Always open Flutter projects by clicking on build.gradle file, not the folder!**

This tells Android Studio: "Hey, this is a Gradle project!"

---

## 🆘 Still Stuck?

See the full **ENABLE_GRADLE_GUIDE.md** for:
- 5 different solutions
- Detailed troubleshooting
- Common error fixes
- Step-by-step with screenshots

**You got this!** 🚀