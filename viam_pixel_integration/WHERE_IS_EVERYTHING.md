# 🔍 Where Is Everything? - Visual Location Guide

## 🎯 Can't Find Something? Look Here!

This guide shows you EXACTLY where to find everything in Android Studio.

---

## 📍 Main Android Studio Window Layout

```
┌────────────────────────────────────────────────────────────────┐
│ File  Edit  View  Navigate  Code  Analyze  Refactor  Build    │ ← MENU BAR
│ Tools  VCS  Window  Help                                       │
├────────────────────────────────────────────────────────────────┤
│ 🔨 Build  ▶ Run  🐘 Sync  📱 Device  ⚙️ Settings  🔍 Search   │ ← TOOLBAR
├────────────────────────────────────────────────────────────────┤
│ ⚠️ Gradle files have changed [Sync Now] [Dismiss]             │ ← NOTIFICATION
├──────────────┬─────────────────────────────────────────────────┤
│ PROJECT      │ CODE EDITOR                                     │
│              │                                                 │
│ ▼ android    │ Your code appears here when you                │
│   ▼ app      │ click on a file in the Project panel           │
│     ▼ src    │                                                 │
│       ▼ main │                                                 │
│         Android│                                               │
│         Manifest│                                              │
│         .xml  │                                                │
│              │                                                 │
│ LEFT PANEL   │ CENTER PANEL                                    │
├──────────────┴─────────────────────────────────────────────────┤
│ Terminal  |  Build  |  Problems  |  Event Log  |  TODO        │ ← BOTTOM TABS
│                                                                 │
│ > flutter pub get                                              │ ← TERMINAL
│ Got dependencies!                                              │
│                                                                 │
│ BOTTOM PANEL                                                    │
└────────────────────────────────────────────────────────────────┘
```

---

## 🐘 Finding the Gradle Sync Button

### Location 1: Top Toolbar (EASIEST!)

```
Look at the TOP RIGHT area:

[File] [Edit] [View] ... [Help]    🔨  ▶  🐘  📱  ⚙️
                                         ↑
                                    THIS ONE!
                                  (Elephant icon)
```

**What it looks like:**
- Small elephant icon 🐘
- Gray/blue color
- In the toolbar with other icons
- Usually between the "Run" button (▶) and device selector (📱)

**How to use:**
1. Move mouse to top right area
2. Look for elephant icon
3. Hover over it (tooltip says "Sync Project with Gradle Files")
4. Click it once
5. Wait for sync

---

### Location 2: File Menu

```
Click here:
┌─────────────────────┐
│ File                │
│ ├─ New              │
│ ├─ Open             │
│ ├─ Close Project    │
│ ├─ Settings         │
│ ├─ Project Structure│
│ ├─ Sync Project with│ ← THIS ONE!
│ │  Gradle Files     │
│ └─ ...              │
└─────────────────────┘
```

**How to use:**
1. Click "File" at top left
2. Scroll down the menu
3. Find "Sync Project with Gradle Files"
4. Click it
5. Wait for sync

---

### Location 3: Build Menu

```
Click here:
┌─────────────────────┐
│ Build               │
│ ├─ Make Project     │
│ ├─ Rebuild Project  │
│ ├─ Clean Project    │
│ ├─ Sync Project with│ ← THIS ONE!
│ │  Gradle Files     │
│ └─ ...              │
└─────────────────────┘
```

**How to use:**
1. Click "Build" in menu bar
2. Find "Sync Project with Gradle Files"
3. Click it
4. Wait for sync

---

### Location 4: Notification Bar

```
After saving a file, look at the TOP:

┌────────────────────────────────────────────────────┐
│ ⚠️ Gradle files have changed since last project   │
│    sync. A project sync may be necessary for the   │
│    IDE to work properly.                           │
│                                    [Sync Now]      │ ← CLICK THIS!
└────────────────────────────────────────────────────┘
```

**What it looks like:**
- Yellow or blue bar at the top
- Warning icon (⚠️) on the left
- "Sync Now" link on the right
- Appears after you save AndroidManifest.xml or build.gradle

**How to use:**
1. Save your file (Ctrl+S)
2. Look at the very top of the window
3. Find the colored notification bar
4. Click "Sync Now" on the right
5. Wait for sync

---

## 📁 Finding Files to Edit

### Finding AndroidManifest.xml

```
LEFT PANEL (Project view):

▼ viam_pixel_integration
  ▼ android                    ← Click the arrow to expand
    ▼ app                      ← Click the arrow to expand
      ▼ src                    ← Click the arrow to expand
        ▼ main                 ← Click the arrow to expand
          AndroidManifest.xml  ← CLICK THIS FILE!
```

**Step by step:**
1. Look at the LEFT panel
2. Find "android" folder
3. Click the ▶ arrow next to it (becomes ▼)
4. Find "app" folder inside
5. Click the ▶ arrow next to it
6. Find "src" folder inside
7. Click the ▶ arrow next to it
8. Find "main" folder inside
9. Click the ▶ arrow next to it
10. Click on "AndroidManifest.xml"
11. File opens in the center panel

---

### Finding build.gradle

```
LEFT PANEL (Project view):

▼ viam_pixel_integration
  ▼ android                    ← Click the arrow to expand
    ▼ app                      ← Click the arrow to expand
      build.gradle             ← CLICK THIS FILE!
      (NOT the other build.gradle at the top level!)
```

**Step by step:**
1. Look at the LEFT panel
2. Find "android" folder
3. Click the ▶ arrow next to it
4. Find "app" folder inside
5. Click the ▶ arrow next to it
6. Click on "build.gradle" (the one under "app")
7. File opens in the center panel

**⚠️ IMPORTANT:** There are TWO build.gradle files!
- ✅ Use the one under: android → app → build.gradle
- ❌ NOT the one at the top level

---

## 🖥️ Opening the Terminal

### Where is the Terminal?

```
Look at the BOTTOM of the window:

┌────────────────────────────────────────────┐
│ [Terminal] [Build] [Problems] [Event Log]  │ ← THESE TABS
├────────────────────────────────────────────┤
│                                             │
│ Terminal content appears here              │
│                                             │
└────────────────────────────────────────────┘
```

**How to open:**
1. Look at the very bottom of Android Studio
2. Find the tabs: "Terminal", "Build", "Problems", etc.
3. Click on "Terminal" tab
4. Terminal panel opens
5. You can type commands here

**If you don't see the tabs:**
- Look for a thin bar at the bottom
- Click on it to expand
- OR: Click "View" menu → "Tool Windows" → "Terminal"

---

## 💾 Saving Files

### How to Save

**Method 1: Keyboard**
- Press `Ctrl + S` (hold Ctrl, press S)

**Method 2: Menu**
- Click "File" → "Save All"

**Method 3: Auto-save**
- Android Studio auto-saves after a few seconds
- Look for the asterisk (*) next to filename
- When asterisk disappears, file is saved

**Visual indicator:**
```
File is NOT saved:  AndroidManifest.xml *  ← See the asterisk?
File IS saved:      AndroidManifest.xml    ← No asterisk!
```

---

## 🔍 Checking Sync Status

### Where to Look

**Location 1: Bottom Right Corner**
```
Look here:
                                    ┌──────────────┐
                                    │ Gradle sync  │
                                    │ in progress..│
                                    └──────────────┘
                                           ↑
                                    BOTTOM RIGHT
```

**Location 2: Bottom Panel (Build tab)**
```
Click "Build" tab at bottom:

┌────────────────────────────────────────────┐
│ [Terminal] [Build] [Problems] [Event Log]  │
├────────────────────────────────────────────┤
│ > Task :app:processDebugResources          │
│ > Task :app:compileDebugKotlin             │
│ BUILD SUCCESSFUL in 2s                     │ ← LOOK FOR THIS!
└────────────────────────────────────────────┘
```

**What to look for:**
- ✅ "BUILD SUCCESSFUL" in green
- ✅ "Gradle sync finished"
- ❌ "BUILD FAILED" in red (means error)
- ⏳ "Gradle sync in progress..." (wait)

---

## 🎨 Changing View Mode

### If Left Panel is Empty or Wrong

**Switch to Project view:**

```
Look at the TOP of the left panel:

┌─────────────────────┐
│ [Project ▼]         │ ← Click this dropdown
├─────────────────────┤
│ ▼ viam_pixel_...    │
│   ▼ android         │
│   ▼ lib             │
└─────────────────────┘
```

**How to change:**
1. Find the dropdown at top of left panel
2. It might say "Android", "Project", "Packages", etc.
3. Click on it
4. Select "Project" from the dropdown
5. Now you'll see the full project structure

---

## 🔧 Opening Settings

### Where is Settings?

**Method 1: Menu**
```
File → Settings (on Windows/Linux)
File → Preferences (on Mac)
```

**Method 2: Toolbar**
```
Look for ⚙️ icon in top right toolbar
Click it
```

**Method 3: Keyboard**
```
Press: Ctrl + Alt + S (Windows/Linux)
Press: Cmd + , (Mac)
```

---

## 📱 Selecting Your Phone

### Where is Device Selector?

```
Look at the TOP toolbar:

🔨  ▶  🐘  [Pixel 4a] ▼  ⚙️
              ↑
         CLICK HERE
```

**What it shows:**
- Your phone name (e.g., "Pixel 4a")
- OR "No devices" if phone not connected
- OR "Loading..." if detecting

**How to use:**
1. Make sure phone is connected via USB
2. Look at the device selector (between Run button and Settings)
3. Click the dropdown arrow
4. Select your phone from the list
5. If phone not listed, check USB connection

---

## 🏗️ Building the App

### Where is Build Button?

**Method 1: Toolbar**
```
Look at the TOP toolbar:

🔨  ▶  🐘  📱  ⚙️
 ↑
THIS ONE (Hammer icon)
```

**Method 2: Menu**
```
Build → Make Project
Build → Rebuild Project
Build → Clean Project
```

**Method 3: Terminal**
```
Click Terminal tab at bottom
Type: flutter build apk --release
Press Enter
```

---

## ✅ Quick Reference Checklist

**Before you start, make sure you can find:**

- [ ] Menu bar (File, Edit, View, etc.) - at the very top
- [ ] Toolbar with icons (🔨 ▶ 🐘 📱 ⚙️) - below menu bar
- [ ] Left panel (Project view) - shows folders and files
- [ ] Center panel (Code editor) - where you edit files
- [ ] Bottom panel (Terminal, Build, etc.) - at the bottom
- [ ] Notification bar - appears at top when needed
- [ ] Status bar - bottom right corner shows progress

**If you can see all these, you're ready to continue!** ✅

---

## 🆘 Still Can't Find Something?

### Take a Screenshot:
1. Press `Windows key + Shift + S`
2. Select the entire Android Studio window
3. Save it
4. This helps identify what you're seeing

### Common Issues:

**Issue: "I don't see the toolbar with icons"**
- Solution: View → Toolbar (check it's enabled)

**Issue: "I don't see the left panel"**
- Solution: View → Tool Windows → Project

**Issue: "I don't see the bottom panel"**
- Solution: View → Tool Windows → Terminal (or Build)

**Issue: "Everything looks different"**
- Solution: You might be in a different view mode
- Try: View → Appearance → Toolbar (enable)
- Try: View → Tool Windows → Project

---

## 💡 Pro Tips

### Tip 1: Maximize Space
- Double-click on a tab to maximize that panel
- Double-click again to restore

### Tip 2: Reset Layout
- Window → Restore Default Layout
- This resets everything to default positions

### Tip 3: Search Everywhere
- Press `Shift` twice quickly
- Type what you're looking for
- Android Studio will find it for you!

---

## 🎯 You Got This!

Remember:
- ✅ Everything is either in the menu bar or toolbar
- ✅ Files are in the left panel
- ✅ Code editor is in the center
- ✅ Terminal and build output are at the bottom
- ✅ Status and progress are in the bottom right

**Once you know where everything is, the rest is easy!** 🚀