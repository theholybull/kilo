# 🔧 Enable Gradle for Your Project

## 🎯 Problem: Gradle Not Enabled

If Android Studio doesn't recognize your project as a Gradle project, you need to enable it manually.

---

## 🚨 Signs Gradle is Not Enabled

You might see:
- ❌ No elephant icon (🐘) in the toolbar
- ❌ No "Sync Project with Gradle Files" in File menu
- ❌ Left panel shows files but no proper Android structure
- ❌ Bottom panel doesn't show "Gradle" tab
- ❌ Project doesn't build

---

## ✅ Solution 1: Import as Gradle Project (EASIEST!)

### Step 1: Close the Current Project
1. Click **"File"** menu at top
2. Click **"Close Project"**
3. You'll see the Android Studio welcome screen

### Step 2: Import the Project Properly
1. On the welcome screen, click **"Open"** (NOT "New Project")
2. Navigate to: `Documents\AndroidProjects\kilo\viam_pixel_integration`
3. **IMPORTANT:** Look for a file called **"build.gradle"** in this folder
4. **Click on the "build.gradle" file** (not the folder!)
5. Click **"OK"**
6. A popup appears: **"Open as Project or File?"**
7. Choose **"Open as Project"**
8. Wait for Android Studio to import (2-5 minutes)
9. Gradle should now be enabled!

**✅ Success:** You'll see the elephant icon appear in the toolbar

---

## ✅ Solution 2: Link Gradle Manually

If Solution 1 doesn't work, try this:

### Step 1: Check for Gradle Files
1. In the left panel, look for these files:
   - `build.gradle` (at the root)
   - `settings.gradle`
   - `gradle.properties`
   - `android/build.gradle`
   - `android/app/build.gradle`

2. **If you DON'T see these files:**
   - The project might not have been downloaded correctly
   - Go to Solution 3 below

3. **If you DO see these files:**
   - Continue to Step 2

### Step 2: Enable Gradle Support
1. Click **"File"** menu
2. Click **"Project Structure"** (or press Ctrl+Alt+Shift+S)
3. In the left panel, click **"Project"**
4. Look for **"Project SDK"**
5. If it says "No SDK", click the dropdown and select an Android SDK
6. Click **"OK"**
7. Close and reopen the project

**✅ Success:** Gradle should now be recognized

---

## ✅ Solution 3: Re-download Project Correctly

If the project files are missing or corrupted:

### Step 1: Delete the Old Project
1. Close Android Studio
2. Open File Explorer
3. Go to: `Documents\AndroidProjects\kilo`
4. **Delete the entire "kilo" folder**

### Step 2: Download Fresh from GitHub

**Option A: Using GitHub Desktop (Easiest!)**
1. Download GitHub Desktop: https://desktop.github.com/
2. Install it
3. Open GitHub Desktop
4. Click "File" → "Clone Repository"
5. Click "URL" tab
6. Enter: `https://github.com/theholybull/kilo.git`
7. Choose location: `Documents\AndroidProjects`
8. Click "Clone"
9. Wait for download
10. In GitHub Desktop, click "Current Branch" dropdown
11. Select "viam-pixel-integration"
12. Wait for branch to switch

**Option B: Using Git Command (If you have Git installed)**
1. Open Command Prompt
2. Type: `cd Documents\AndroidProjects`
3. Press Enter
4. Type: `git clone https://github.com/theholybull/kilo.git`
5. Press Enter
6. Wait for download
7. Type: `cd kilo`
8. Press Enter
9. Type: `git checkout viam-pixel-integration`
10. Press Enter

**Option C: Download ZIP from GitHub**
1. Go to: https://github.com/theholybull/kilo
2. Click the green "Code" button
3. Click "Download ZIP"
4. Extract ZIP to: `Documents\AndroidProjects\kilo`
5. **Important:** Make sure you're on the "viam-pixel-integration" branch before downloading

### Step 3: Open in Android Studio
1. Open Android Studio
2. Click "Open"
3. Navigate to: `Documents\AndroidProjects\kilo\viam_pixel_integration`
4. **Click on "build.gradle" file** (not the folder!)
5. Click "OK"
6. Choose "Open as Project"
7. Wait for import

**✅ Success:** Project opens with Gradle enabled

---

## ✅ Solution 4: Create Gradle Wrapper

If Gradle files exist but aren't recognized:

### Step 1: Check for Gradle Wrapper
1. In the left panel, look for a folder called **"gradle"**
2. Inside it, look for **"wrapper"** folder
3. Inside wrapper, look for **"gradle-wrapper.properties"**

### Step 2: If Wrapper is Missing
1. Close Android Studio
2. Open Command Prompt
3. Navigate to project: `cd Documents\AndroidProjects\kilo\viam_pixel_integration`
4. Type: `flutter create --org com.example .`
5. Press Enter
6. This recreates the Gradle wrapper
7. Reopen in Android Studio

**✅ Success:** Gradle wrapper is created

---

## ✅ Solution 5: Install Gradle Plugin

If Android Studio is missing the Gradle plugin:

### Step 1: Check Plugins
1. Click **"File"** → **"Settings"** (or Ctrl+Alt+S)
2. In the left panel, click **"Plugins"**
3. Click **"Installed"** tab
4. Look for **"Gradle"** in the list

### Step 2: If Gradle Plugin is Missing
1. Click **"Marketplace"** tab
2. Search for **"Gradle"**
3. Find **"Gradle"** plugin (by JetBrains)
4. Click **"Install"**
5. Click **"Restart IDE"**
6. Wait for restart
7. Reopen your project

**✅ Success:** Gradle plugin is installed

---

## 🔍 Verify Gradle is Working

After trying any solution, check these:

### Check 1: Elephant Icon
- Look at the top toolbar
- You should see the elephant icon 🐘
- If you see it → Gradle is enabled! ✅

### Check 2: File Menu
- Click "File" menu
- Look for "Sync Project with Gradle Files"
- If you see it → Gradle is enabled! ✅

### Check 3: Gradle Tab
- Look at the right edge of Android Studio
- You should see a vertical "Gradle" tab
- Click it to open Gradle panel
- If you see it → Gradle is enabled! ✅

### Check 4: Project Structure
- Left panel should show:
  - android folder with proper structure
  - build.gradle files
  - Proper Android project hierarchy
- If you see this → Gradle is working! ✅

---

## 🚨 Common Issues and Fixes

### Issue: "Could not find build.gradle"

**Solution:**
- You might be opening the wrong folder
- Make sure you open: `viam_pixel_integration` folder
- NOT the `kilo` folder
- The correct folder has `pubspec.yaml` and `android` folder

---

### Issue: "Gradle version not supported"

**Solution:**
1. Click "File" → "Project Structure"
2. Click "Project" in left panel
3. Find "Gradle Version"
4. Click "Use default gradle wrapper"
5. Click "OK"
6. Let Android Studio download the correct version

---

### Issue: "SDK not found"

**Solution:**
1. Click "File" → "Settings"
2. Expand "Appearance & Behavior"
3. Expand "System Settings"
4. Click "Android SDK"
5. Check if SDK location is set
6. If empty, click "Edit" and let Android Studio download SDK
7. Click "OK"

---

### Issue: "Gradle sync keeps failing"

**Solution:**
1. Click "File" → "Invalidate Caches / Restart"
2. Choose "Invalidate and Restart"
3. Wait for restart
4. Try opening project again

---

## 📋 Step-by-Step Checklist

Use this to verify everything:

- [ ] Project downloaded from GitHub
- [ ] Opened the correct folder (viam_pixel_integration)
- [ ] build.gradle file exists in the project
- [ ] Opened project by clicking on build.gradle file
- [ ] Chose "Open as Project" when prompted
- [ ] Waited for initial import to complete
- [ ] Can see elephant icon in toolbar
- [ ] Can see "Sync Project with Gradle Files" in File menu
- [ ] Can see Gradle tab on the right side
- [ ] Project structure shows android folder properly

**If all checked → Gradle is enabled and working!** ✅

---

## 🎯 Recommended Approach

**Try solutions in this order:**

1. **First:** Solution 1 (Import as Gradle Project)
   - Fastest and easiest
   - Works 90% of the time

2. **If that fails:** Solution 3 (Re-download Project)
   - Ensures you have all files
   - Fresh start

3. **If that fails:** Solution 2 (Link Gradle Manually)
   - For when files are there but not recognized

4. **If that fails:** Solution 5 (Install Gradle Plugin)
   - For when Android Studio is missing components

5. **Last resort:** Solution 4 (Create Gradle Wrapper)
   - For advanced issues

---

## 💡 Pro Tips

### Tip 1: Always Open build.gradle
When opening a Flutter/Android project, always click on the `build.gradle` file, not the folder. This tells Android Studio it's a Gradle project.

### Tip 2: Wait for Initial Import
The first time you open a project, Android Studio needs to:
- Download Gradle wrapper
- Download dependencies
- Index files
- Configure project

This takes 5-10 minutes. Be patient!

### Tip 3: Check Internet Connection
Gradle needs internet to download dependencies. Make sure you're online.

### Tip 4: Use Latest Android Studio
Old versions might have Gradle issues. Update to the latest version:
- Help → Check for Updates

---

## 🆘 Still Not Working?

If Gradle still won't enable:

### Collect This Information:
1. Android Studio version (Help → About)
2. Do you see build.gradle files in the project?
3. What happens when you click File → Open?
4. Any error messages?
5. Screenshot of the Android Studio window

### Try This:
1. Completely uninstall Android Studio
2. Delete `C:\Users\YourName\.android` folder
3. Delete `C:\Users\YourName\.gradle` folder
4. Reinstall Android Studio
5. Start fresh with Solution 1

---

## ✅ Success Indicators

You know Gradle is working when:

1. ✅ Elephant icon visible in toolbar
2. ✅ "Sync Project with Gradle Files" in File menu
3. ✅ Gradle tab on right side of window
4. ✅ Project structure shows proper Android hierarchy
5. ✅ Can click "Build" → "Make Project" without errors
6. ✅ Bottom panel shows "Gradle" tab
7. ✅ No "Gradle not configured" errors

**If you have all 7 → You're ready to continue!** 🎉

---

## 🎊 Next Steps

Once Gradle is enabled:

1. Go back to the main guide
2. Continue from Step 4 (Install Dependencies)
3. Run: `flutter pub get`
4. Fix AndroidManifest.xml
5. Fix build.gradle
6. Sync with Gradle
7. Build the app!

**You're almost there!** 🚀