# 🔧 Fix: Flutter Pub Get Error

## 🎯 The Error

```
Error running 'flutter pub get'
Cannot run program "flutter" in directory "C:\Users\jbates\Desktop\viam_pixel_integration\android\app"
CreateProcess error=2, The system cannot find the file specified
```

## 🔍 What This Means

You're trying to run `flutter pub get` from the **wrong directory**. Flutter commands must be run from the **root project directory**, not from inside the `android/app` folder.

---

## ✅ Solution: Navigate to Correct Directory

### In Android Studio Terminal:

**Step 1: Check Current Directory**
Look at your terminal prompt. It probably shows:
```
PS C:\Users\jbates\Desktop\viam_pixel_integration\android\app>
```

**Step 2: Go Back to Root Directory**
Type this command:
```bash
cd ../..
```
Press Enter.

**Step 3: Verify You're in the Right Place**
Your prompt should now show:
```
PS C:\Users\jbates\Desktop\viam_pixel_integration>
```

**Step 4: Run Flutter Pub Get**
Now type:
```bash
flutter pub get
```
Press Enter.

**✅ Success:** You should see "Got dependencies!"

---

## 🎯 Quick Fix (Copy-Paste)

**Just copy and paste these two commands:**

```bash
cd ../..
flutter pub get
```

---

## 📍 Understanding the Directory Structure

```
viam_pixel_integration/          ← YOU NEED TO BE HERE!
├── android/
│   └── app/                     ← YOU ARE HERE (WRONG!)
├── lib/
├── pubspec.yaml                 ← Flutter looks for this file
└── build.gradle
```

**Flutter commands only work from the root directory where `pubspec.yaml` is located.**

---

## 🔍 How to Check You're in the Right Place

**Method 1: Look at the Terminal Prompt**
- ✅ Correct: `C:\Users\jbates\Desktop\viam_pixel_integration>`
- ❌ Wrong: `C:\Users\jbates\Desktop\viam_pixel_integration\android\app>`

**Method 2: List Files**
Type: `dir` (Windows) or `ls` (Mac/Linux)

You should see:
- ✅ `pubspec.yaml`
- ✅ `android` folder
- ✅ `lib` folder
- ✅ `build.gradle`

If you don't see these, you're in the wrong directory!

---

## 🚨 Common Mistakes

### Mistake 1: Opening Terminal in Wrong Folder
**Problem:** Terminal opens in `android/app` by default

**Solution:**
```bash
cd ../..
```

### Mistake 2: Using Wrong Command Prompt
**Problem:** Using Windows Command Prompt instead of Android Studio Terminal

**Solution:** Use the Terminal tab at the bottom of Android Studio

### Mistake 3: Flutter Not in PATH
**Problem:** `flutter` command not recognized

**Solution:**
1. Close Android Studio
2. Open new Command Prompt
3. Type: `flutter --version`
4. If it works, reopen Android Studio
5. If not, Flutter is not installed or not in PATH

---

## 📋 Step-by-Step Fix

**Follow these exact steps:**

1. ✅ Look at the bottom of Android Studio
2. ✅ Click "Terminal" tab
3. ✅ Look at the prompt - where are you?
4. ✅ If you see `android\app` in the path, type: `cd ../..`
5. ✅ Press Enter
6. ✅ Verify you're in the root (type `dir` to check)
7. ✅ Type: `flutter pub get`
8. ✅ Press Enter
9. ✅ Wait for "Got dependencies!"

---

## 💡 Pro Tips

### Tip 1: Always Start from Root
When opening Terminal in Android Studio, it should open in the project root. If it doesn't:
```bash
cd C:\Users\jbates\Desktop\viam_pixel_integration
```

### Tip 2: Use Tab Completion
Type `cd ..` and press Tab - it will auto-complete the path.

### Tip 3: Create Shortcut
In Terminal, type:
```bash
cd ~
```
This takes you to your home directory. Then navigate to your project.

---

## 🎯 Alternative: Use Android Studio GUI

**If Terminal is confusing, use the GUI:**

1. **Right-click on `pubspec.yaml`** in the left panel
2. **Select "Flutter" → "Pub Get"**
3. Wait for completion
4. Check bottom panel for "Got dependencies!"

**This does the same thing without using Terminal!**

---

## ✅ Verification

After running `flutter pub get`, you should see:

```
Running "flutter pub get" in viam_pixel_integration...
Resolving dependencies...
Got dependencies!
```

**If you see this → Success!** ✅

---

## 🆘 Still Getting Errors?

### Error: "flutter: command not found"

**Solution:**
1. Flutter is not installed or not in PATH
2. Close Android Studio
3. Open new Command Prompt
4. Type: `flutter doctor`
5. If it doesn't work, reinstall Flutter
6. Make sure to add Flutter to PATH

### Error: "pubspec.yaml not found"

**Solution:**
1. You're still in the wrong directory
2. Type: `cd C:\Users\jbates\Desktop\viam_pixel_integration`
3. Try again

### Error: "pub get failed"

**Solution:**
1. Check internet connection
2. Try: `flutter pub cache repair`
3. Then: `flutter pub get`

---

## 📝 Quick Reference

**Navigate to root:**
```bash
cd ../..
```

**Check where you are:**
```bash
pwd    # Mac/Linux
cd     # Windows (shows current directory)
```

**List files:**
```bash
dir    # Windows
ls     # Mac/Linux
```

**Run pub get:**
```bash
flutter pub get
```

---

## 🎊 Success!

Once you see "Got dependencies!":

1. ✅ Dependencies are installed
2. ✅ You can continue with the build
3. ✅ Next step: Sync Gradle
4. ✅ Then: Build the APK!

**You're making progress!** 🚀