# 🎯 Complete Beginner's Guide to Building the Viam Pixel 4a App

## 📖 What This Guide Does

This guide will help you build the Viam Pixel 4a integration app **from your GitHub repository** with **zero assumptions** about your knowledge. Every step is explained in detail.

---

## 🎬 Before You Start

### What You'll Need:
- ✅ A Windows PC (Windows 10 or 11)
- ✅ Your Google Pixel 4a phone
- ✅ A USB cable to connect phone to PC
- ✅ About 2-3 hours of time
- ✅ 10GB of free disk space
- ✅ Internet connection

### What You'll Get:
- ✅ A working Android app on your Pixel 4a
- ✅ The app will connect to your Raspberry Pi via USB
- ✅ Full Viam integration with sensors, camera, and audio

---

## 📚 Part 1: Install Required Software

### Step 1.1: Install Android Studio

**What is Android Studio?**  
It's the official tool from Google for building Android apps. Think of it like Microsoft Word, but for making apps.

**How to Install:**

1. **Open your web browser** (Chrome, Edge, Firefox, etc.)

2. **Go to**: https://developer.android.com/studio

3. **Click the big green button** that says "Download Android Studio"

4. **Wait for download** (it's about 1GB, so it might take a few minutes)

5. **Find the downloaded file**:
   - Usually in your `Downloads` folder
   - File name: `android-studio-2023.x.x.x-windows.exe` (or similar)

6. **Double-click the file** to start installation

7. **Follow the installer**:
   - Click "Next" on the welcome screen
   - Choose "Standard" installation type
   - Click "Next" through all screens
   - Click "Finish" when done

8. **First Launch**:
   - Android Studio will open automatically
   - It will say "Downloading Components" - **let it finish** (10-15 minutes)
   - When you see "Welcome to Android Studio" screen, you're done!

**✅ Checkpoint**: You should see the Android Studio welcome screen with options like "New Project", "Open", etc.

---

### Step 1.2: Install Flutter

**What is Flutter?**  
Flutter is the framework we use to build the app. It lets us write code once and run it on Android.

**How to Install:**

1. **Go to**: https://docs.flutter.dev/get-started/install/windows

2. **Click "Download Flutter SDK"** (blue button)

3. **Wait for download** (about 500MB)

4. **Extract the ZIP file**:
   - Right-click the downloaded file
   - Choose "Extract All..."
   - Extract to `C:\` (so you'll have `C:\flutter`)
   - **Important**: Don't put it in `Program Files` or anywhere with spaces in the name

5. **Add Flutter to PATH** (so your computer knows where to find it):
   
   **Method A - Easy Way (Windows 11/10):**
   - Press `Windows key` on keyboard
   - Type "environment variables"
   - Click "Edit the system environment variables"
   - Click "Environment Variables" button at bottom
   - In "User variables" section, find "Path" and click "Edit"
   - Click "New"
   - Type: `C:\flutter\bin`
   - Click "OK" on all windows

   **Method B - If Method A doesn't work:**
   - Open File Explorer
   - Right-click "This PC" → Properties
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Follow steps above from "In User variables..."

6. **Verify Installation**:
   - Press `Windows key`
   - Type "cmd" and press Enter (opens Command Prompt)
   - Type: `flutter --version`
   - Press Enter
   - You should see Flutter version information

**✅ Checkpoint**: Command Prompt shows Flutter version (like "Flutter 3.x.x")

---

### Step 1.3: Install Git

**What is Git?**  
Git helps you download code from GitHub (where your project is stored).

**How to Install:**

1. **Go to**: https://git-scm.com/download/win

2. **Download will start automatically**

3. **Run the installer**:
   - Click "Next" on all screens
   - Use all default options
   - Click "Install"
   - Click "Finish"

4. **Verify Installation**:
   - Open Command Prompt (Windows key → type "cmd" → Enter)
   - Type: `git --version`
   - Press Enter
   - You should see Git version information

**✅ Checkpoint**: Command Prompt shows Git version (like "git version 2.x.x")

---

## 📱 Part 2: Setup Your Pixel 4a Phone

### Step 2.1: Enable Developer Options

**What are Developer Options?**  
Hidden settings on your phone that let you connect it to your computer for app development.

**How to Enable:**

1. **Open Settings** on your Pixel 4a

2. **Scroll down** and tap "About phone"

3. **Find "Build number"** (usually near the bottom)

4. **Tap "Build number" 7 times quickly**
   - You'll see a message: "You are now a developer!"
   - If it asks for your PIN/password, enter it

5. **Go back** to main Settings

6. **Tap "System"**

7. **Tap "Developer options"** (it's now visible!)

**✅ Checkpoint**: You can see "Developer options" in System settings

---

### Step 2.2: Enable USB Debugging

**What is USB Debugging?**  
This lets your computer talk to your phone and install apps on it.

**How to Enable:**

1. **In Developer options** (from previous step)

2. **Scroll down** to find "USB debugging"

3. **Toggle it ON** (switch turns blue)

4. **Tap "OK"** on the warning popup

**✅ Checkpoint**: USB debugging switch is ON (blue)

---

### Step 2.3: Connect Phone to Computer

**How to Connect:**

1. **Get your USB cable** (the one that came with your phone)

2. **Plug USB-C end into phone**

3. **Plug USB-A end into computer**

4. **On your phone**, you'll see a popup:
   - "Allow USB debugging?"
   - **Check the box** "Always allow from this computer"
   - **Tap "OK"**

5. **Verify Connection**:
   - Open Command Prompt on PC
   - Type: `adb devices`
   - Press Enter
   - You should see your phone listed (a long number/code)

**Troubleshooting if phone doesn't show up:**
- Try a different USB cable
- Try a different USB port on your computer
- On phone: Swipe down from top → Tap USB notification → Choose "File Transfer"
- Restart both phone and computer

**✅ Checkpoint**: `adb devices` shows your phone's serial number

---

## 💻 Part 3: Download Your Project from GitHub

### Step 3.1: Create a Workspace Folder

**Why?**  
We need a place to put your project files.

**How to Create:**

1. **Open File Explorer** (Windows key + E)

2. **Go to your Documents folder**

3. **Right-click** in empty space

4. **Choose "New" → "Folder"**

5. **Name it**: `AndroidProjects`

6. **Press Enter**

**✅ Checkpoint**: You have a folder at `C:\Users\YourName\Documents\AndroidProjects`

---

### Step 3.2: Download Project from GitHub

**How to Download:**

1. **Open Command Prompt**:
   - Press Windows key
   - Type "cmd"
   - Press Enter

2. **Navigate to your workspace**:
   - Type: `cd Documents\AndroidProjects`
   - Press Enter

3. **Download the project**:
   - Type: `git clone https://github.com/theholybull/kilo.git`
   - Press Enter
   - Wait for download (might take 1-2 minutes)

4. **Switch to the correct branch**:
   - Type: `cd kilo`
   - Press Enter
   - Type: `git checkout viam-pixel-integration`
   - Press Enter

5. **Go to the project folder**:
   - Type: `cd viam_pixel_integration`
   - Press Enter

**✅ Checkpoint**: You're now in the project folder. Type `dir` and press Enter - you should see folders like "android", "lib", etc.

---

## 🔧 Part 4: Setup the Project in Android Studio

### Step 4.1: Open Project in Android Studio

**How to Open:**

1. **Launch Android Studio**
   - Double-click Android Studio icon on desktop
   - OR: Windows key → type "Android Studio" → Enter

2. **On the welcome screen**:
   - Click "Open"
   - **Navigate to**: `Documents\AndroidProjects\kilo\viam_pixel_integration`
   - Click "OK"

3. **Wait for project to load** (2-5 minutes)
   - You'll see "Indexing..." at the bottom
   - You'll see "Gradle sync" running
   - **Let it finish completely**

4. **If you see any popups**:
   - "Trust and Open Project?" → Click "Trust Project"
   - "Gradle Sync" → Click "OK"
   - "Install missing components" → Click "Install"

**✅ Checkpoint**: Project is open, no error popups, bottom bar shows "Indexing complete"

---

### Step 4.2: Install Flutter Dependencies

**What are dependencies?**  
These are extra pieces of code your app needs to work (like camera support, sensors, etc.)

**How to Install:**

1. **In Android Studio**, look at the bottom of the window

2. **Click "Terminal"** tab (it opens a command line inside Android Studio)

3. **Type**: `flutter pub get`

4. **Press Enter**

5. **Wait** (1-2 minutes) - you'll see it downloading packages

6. **Success message**: "Got dependencies!"

**If you see errors:**
- Make sure you're in the right folder (should show `viam_pixel_integration` in the path)
- Try closing and reopening Android Studio
- Try: `flutter clean` then `flutter pub get` again

**✅ Checkpoint**: Terminal shows "Got dependencies!" with no errors

---

### Step 4.3: Fix the AndroidManifest.xml File

**Why fix it?**  
The file from GitHub might have the wrong format for your version of Android Studio.

**How to Fix:**

1. **In Android Studio**, look at the left side panel (Project view)

2. **Navigate to**:
   - Click the ▶ arrow next to "android"
   - Click ▶ next to "app"
   - Click ▶ next to "src"
   - Click ▶ next to "main"
   - **Click on "AndroidManifest.xml"**

3. **The file opens in the editor**

4. **Look at the very first line** - it should look like:
   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android">
   ```

5. **If it has `package="something"` in it**, you need to remove that part:
   - **Find this line** (usually line 1 or 2):
     ```xml
     <manifest xmlns:android="http://schemas.android.com/apk/res/android"
         package="com.example.viam_pixel4a_sensors">
     ```
   - **Change it to**:
     ```xml
     <manifest xmlns:android="http://schemas.android.com/apk/res/android">
     ```
   - **Save the file**: Ctrl+S

6. **Sync the project**:
   - Click "File" menu → "Sync Project with Gradle Files"
   - Wait for sync to complete

**✅ Checkpoint**: AndroidManifest.xml first line has NO `package=` attribute

---

### Step 4.4: Fix the build.gradle File

**Why fix it?**  
We need to tell Android Studio where to find the package name.

**How to Fix:**

1. **In Android Studio**, left side panel

2. **Navigate to**:
   - Click ▶ next to "android"
   - Click ▶ next to "app"
   - **Click on "build.gradle"** (the one under "app", not the other one!)

3. **The file opens in the editor**

4. **Find the line** that says `android {` (usually around line 25)

5. **Right after that line**, add this line:
   ```gradle
   namespace "com.example.viam_pixel4a_sensors"
   ```

6. **It should look like this**:
   ```gradle
   android {
       namespace "com.example.viam_pixel4a_sensors"
       compileSdkVersion 33
       // ... rest of the file
   ```

7. **Save the file**: Ctrl+S

8. **Sync the project**:
   - Click "File" → "Sync Project with Gradle Files"
   - Wait for sync (1-2 minutes)

**✅ Checkpoint**: Gradle sync completes with "BUILD SUCCESSFUL"

---

## 🏗️ Part 5: Build the App

### Step 5.1: Clean the Project

**Why clean?**  
This removes old build files and starts fresh.

**How to Clean:**

1. **In Android Studio**, click "Build" menu at top

2. **Click "Clean Project"**

3. **Wait** (30 seconds to 1 minute)

4. **You'll see**: "BUILD SUCCESSFUL" at the bottom

**✅ Checkpoint**: Bottom panel shows "BUILD SUCCESSFUL"

---

### Step 5.2: Build the APK

**What is an APK?**  
It's the installable file for Android apps (like .exe for Windows).

**How to Build:**

1. **Make sure your phone is connected**:
   - Phone plugged into computer via USB
   - USB debugging enabled
   - In Command Prompt: `adb devices` shows your phone

2. **In Android Studio Terminal** (bottom of window):
   - Type: `flutter build apk --release`
   - Press Enter

3. **Wait for build** (5-10 minutes first time)
   - You'll see lots of text scrolling
   - Don't close anything!
   - It's downloading and compiling

4. **Success message**:
   - "Built build\app\outputs\flutter-apk\app-release.apk"

**If you see errors:**
- "Flutter SDK not found" → Make sure Flutter is in PATH (see Step 1.2)
- "Android SDK not found" → Restart Android Studio
- "Gradle build failed" → Try `flutter clean` then build again

**✅ Checkpoint**: You see "Built build\app\outputs\flutter-apk\app-release.apk"

---

## 📲 Part 6: Install App on Your Phone

### Step 6.1: Install via Flutter

**Easiest Method:**

1. **Make sure phone is connected** (USB cable, USB debugging on)

2. **In Android Studio Terminal**:
   - Type: `flutter install`
   - Press Enter

3. **Watch your phone**:
   - App will install automatically
   - You'll see "Viam Pixel 4a Sensors" icon appear

4. **Tap the icon** to open the app!

**✅ Checkpoint**: App opens on your phone

---

### Step 6.2: Alternative - Manual Install

**If flutter install doesn't work:**

1. **Find the APK file**:
   - Open File Explorer
   - Go to: `Documents\AndroidProjects\kilo\viam_pixel_integration\build\app\outputs\flutter-apk\`
   - You'll see: `app-release.apk`

2. **Copy to phone**:
   - Right-click `app-release.apk`
   - Choose "Copy"
   - In File Explorer, click on your phone name (left sidebar)
   - Open "Downloads" folder
   - Right-click → "Paste"

3. **Install on phone**:
   - On your phone, open "Files" app
   - Go to "Downloads"
   - Tap `app-release.apk`
   - Tap "Install"
   - Tap "Open"

**✅ Checkpoint**: App is installed and opens on your phone

---

## 🎉 Part 7: First Run and Testing

### Step 7.1: Grant Permissions

**When you first open the app**, it will ask for permissions:

1. **Camera** → Tap "Allow"
2. **Microphone** → Tap "Allow"
3. **Location** → Tap "Allow" (needed for USB connection)
4. **Files** → Tap "Allow"

**Why these permissions?**
- Camera: For face recognition
- Microphone: For voice communication
- Location: Required for foreground service
- Files: For saving data

---

### Step 7.2: Test Basic Features

**What to test:**

1. **App Opens**: ✅ App launches without crashing

2. **Sensors Work**:
   - Tilt your phone
   - You should see sensor values changing on screen

3. **Camera Preview**:
   - You should see camera feed
   - Try covering camera - preview should go dark

4. **Connection Status**:
   - Look for "Connection Status" on screen
   - It might say "Not Connected" (that's OK for now)

**✅ Checkpoint**: App runs, sensors show data, camera works

---

## 🔌 Part 8: Connect to Raspberry Pi (Optional)

### Step 8.1: Setup USB Connection

**If you want to connect to your Raspberry Pi:**

1. **On Pixel 4a**:
   - Go to Settings → Network & Internet
   - Tap "Hotspot & tethering"
   - Enable "USB tethering"

2. **Connect phone to Pi**:
   - Plug USB cable from phone to Raspberry Pi
   - Wait 10 seconds

3. **On Pi**, check connection:
   - Open terminal
   - Type: `ifconfig usb0`
   - Should show IP: 10.10.10.67

4. **In the app**:
   - Connection status should change to "Connected"

**✅ Checkpoint**: App shows "Connected to Pi"

---

## 🐛 Troubleshooting Common Issues

### Issue 1: "Flutter SDK not found"

**Solution:**
1. Open Command Prompt
2. Type: `flutter doctor`
3. Follow any instructions it gives
4. Restart Android Studio

---

### Issue 2: "Gradle sync failed"

**Solution:**
1. In Android Studio: File → Invalidate Caches / Restart
2. Choose "Invalidate and Restart"
3. Wait for restart
4. Try building again

---

### Issue 3: "Phone not detected"

**Solution:**
1. Unplug and replug USB cable
2. On phone: Swipe down → Tap USB notification → Choose "File Transfer"
3. Try different USB cable
4. Try different USB port on computer
5. Restart both phone and computer

---

### Issue 4: "App crashes on startup"

**Solution:**
1. Uninstall app from phone
2. In Android Studio: Build → Clean Project
3. Build and install again
4. Make sure all permissions are granted

---

### Issue 5: "Build takes forever"

**Solution:**
1. First build always takes 10-15 minutes (normal!)
2. Make sure you have good internet (downloading packages)
3. Close other programs to free up RAM
4. Be patient - subsequent builds will be faster

---

## 📝 Quick Reference Commands

**Open Command Prompt:**
- Windows key → type "cmd" → Enter

**Navigate to project:**
```cmd
cd Documents\AndroidProjects\kilo\viam_pixel_integration
```

**Check phone connection:**
```cmd
adb devices
```

**Install dependencies:**
```cmd
flutter pub get
```

**Clean project:**
```cmd
flutter clean
```

**Build APK:**
```cmd
flutter build apk --release
```

**Install on phone:**
```cmd
flutter install
```

**Check Flutter installation:**
```cmd
flutter doctor
```

---

## 🎯 Success Checklist

Use this to verify everything is working:

- [ ] Android Studio installed and opens
- [ ] Flutter installed (`flutter --version` works)
- [ ] Git installed (`git --version` works)
- [ ] Phone shows in `adb devices`
- [ ] Project downloaded from GitHub
- [ ] Project opens in Android Studio
- [ ] `flutter pub get` completes successfully
- [ ] AndroidManifest.xml has no `package=` attribute
- [ ] build.gradle has `namespace` line
- [ ] Gradle sync completes successfully
- [ ] `flutter build apk` completes successfully
- [ ] APK file exists in build folder
- [ ] App installs on phone
- [ ] App opens without crashing
- [ ] Permissions granted
- [ ] Sensors show data
- [ ] Camera preview works

---

## 🆘 Still Stuck?

If you're still having issues:

1. **Take a screenshot** of the error message
2. **Note which step** you're stuck on
3. **Try the troubleshooting section** for that specific issue
4. **Check the error message carefully** - it often tells you what's wrong

**Common things to try:**
- Restart Android Studio
- Restart your computer
- Restart your phone
- Try a different USB cable
- Make sure you have good internet connection
- Make sure you have enough disk space (10GB free)

---

## 🎊 Congratulations!

If you made it through all the steps, you now have:
- ✅ A working development environment
- ✅ The Viam Pixel 4a app installed on your phone
- ✅ All the tools to modify and rebuild the app
- ✅ Knowledge of the basic Android development workflow

**Next steps:**
- Test the app with your Raspberry Pi
- Explore the code in Android Studio
- Make modifications if needed
- Build and test again

**You did it!** 🎉🚀📱