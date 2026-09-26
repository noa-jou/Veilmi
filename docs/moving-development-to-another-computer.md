# Moving Veilmi Development to Another Computer

This document is a practical reminder for continuing Veilmi development on another computer.

For example, if Veilmi 1.0.0 has already been released and I want to develop Veilmi 1.0.1 on a new computer, I can follow these steps.

The most important thing to remember is:

> **GitHub stores the Veilmi project, but not the whole development environment.**

Cloning the repository gives me the source code. A new computer still needs the software required to edit, run, test, and build a Flutter Android project.

Veilmi currently focuses on **Android development**. I do **not** need to set up Flutter Linux desktop development just because the development computer runs Linux.

---

# 1. What a New Computer Needs

For normal Veilmi Android development, I need:

```text
Operating system
        ↓
Git
        ↓
VS Code
        ↓
Flutter SDK
        ↓
Dart
(included with Flutter)
        ↓
Android Studio
        ↓
Android SDK + Platform Tools + ADB
        ↓
Veilmi source code
        ↓
Flutter packages
```

The main tools are:

| Tool | Why I need it |
|---|---|
| Git | Clone Veilmi and manage source-code changes |
| VS Code | My main editor for Veilmi |
| Flutter SDK | Run, analyze, test, and build Veilmi |
| Dart | The language used by Flutter; included with Flutter |
| Android Studio | Install and manage the Android SDK and Android tools |
| Android SDK | Build the Android version of Veilmi |
| Platform Tools / ADB | Connect physical Android test devices |

Android Studio and VS Code have different jobs in my setup:

```text
VS Code
→ write and edit Veilmi

Android Studio
→ provide/manage Android SDK, SDK Manager, emulator tools, and Android tooling
```

I do not need to use Android Studio as my main code editor.

---

# 2. Different Operating Systems

The Veilmi source code is the same, but the development tools are installed differently depending on the computer.

## Windows

For Android development, install:

```text
Git
VS Code
Flutter SDK
Android Studio + Android SDK
```

Windows may also require the Android phone manufacturer's USB driver before ADB can see a physical device.

## macOS

For Android development, install:

```text
Git
VS Code
Flutter SDK
Android Studio + Android SDK
```

If I later want to build Veilmi for iOS, the Mac also needs Xcode and the iOS development tools.

## Linux

For Android development, install:

```text
Git and Flutter prerequisites
VS Code
Flutter SDK
Android Studio + Android SDK
```

The Debian example below shows this setup.

## Chromebook

Enable the ChromeOS Linux development environment first.

After that, most Flutter work happens inside the Linux environment.

ChromeOS has some Android Studio-specific installation and USB-device behaviour, so I may need the separate Chromebook environment notes if I am using a Chromebook.

---

# 3. What I Do NOT Need

Veilmi currently targets Android.

I do **not** need to install the Linux desktop Flutter toolchain just because I am developing from Debian.

For example, I do not need these packages merely to develop Veilmi for Android:

```text
clang
cmake
ninja-build
pkg-config
libgtk-3-dev
```

Those belong to Flutter **Linux desktop** development.

`flutter doctor` may therefore show something such as:

```text
[✗] Linux toolchain - develop for Linux desktop
```

That is not a problem for Veilmi Android development.

Likewise:

```text
Chrome / web           → not required
Linux desktop          → not required
Windows desktop        → not required
macOS desktop          → not required
iOS / Xcode            → only required when I work on the iOS release
```

For the current Veilmi Android workflow, the important parts are:

```text
Flutter               ✓
Android toolchain     ✓
Android device        ✓
```

> Note: Android Studio's **Android SDK Manager** may offer Android-specific tools such as CMake or NDK. Those are different from setting up Flutter Linux desktop development.

---

# Example: Setting Up Veilmi on a New Debian Computer

The following example assumes I have a new Debian-based computer with no Veilmi development environment yet.

If something is already installed, I can skip that step.

---

## 4. Install Basic Linux Tools

Update the package list:

```bash
sudo apt update
```

Install Flutter's basic Linux prerequisites:

```bash
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa
```

Check Git:

```bash
git --version
```

Do not assume Flutter can be installed with:

```bash
sudo apt install flutter
```

On a normal Debian installation, this may return:

```text
Unable to locate package flutter
```

That does not mean Veilmi is broken.

Flutter is installed separately.

---

## 5. Install VS Code

VS Code is my main editor for Veilmi.

### Debian method

Go to the official VS Code download page and download the Debian/Ubuntu `.deb` package.

After the file has downloaded, open a terminal in the folder containing it.

For example:

```bash
cd ~/Downloads
```

Install the package:

```bash
sudo apt install ./code_*.deb
```

After installation, check:

```bash
code --version
```

Start VS Code with:

```bash
code
```

Later, from the Veilmi project folder, I can open the project directly with:

```bash
code .
```

The official VS Code `.deb` package can also configure Microsoft's package repository so VS Code can receive future updates through the package manager.

---

## 6. Install the Flutter SDK

I keep the Flutter SDK inside:

```text
~/develop/flutter
```

Create the development folder:

```bash
mkdir -p ~/develop
```

Install the stable Flutter SDK:

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/develop/flutter
```

Add Flutter to the Bash PATH:

```bash
echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> ~/.bashrc
```

Reload the shell:

```bash
source ~/.bashrc
```

Check Flutter:

```bash
flutter --version
```

Check Dart:

```bash
dart --version
```

Dart comes with Flutter, so I do not need a separate Dart installation.

If `flutter` still says:

```text
command not found
```

close and reopen the terminal, then check again:

```bash
flutter --version
```

---

## 7. Install the Flutter Extension in VS Code

Open VS Code.

Go to:

```text
Extensions
→ search for "Flutter"
→ install Flutter
```

Installing the Flutter extension also installs the Dart extension.

After that, restart VS Code.

I can check the Flutter environment from VS Code with:

```text
View
→ Command Palette
→ Flutter: Run Flutter Doctor
```

or simply use the terminal:

```bash
flutter doctor -v
```

---

## 8. Install Android Studio

Flutter alone is not enough to build Veilmi for Android.

I also need the Android SDK and Android Platform Tools.

Android Studio is the easiest place to install and manage them.

### On Debian / normal Linux

Go to the official Android Studio download page and download the current stable Linux `.tar.gz` package.

The filename changes with each Android Studio release, so I should use the current file from the official site rather than copying an old version number from this guide.

After downloading it:

```bash
cd ~/Downloads
```

Extract the archive.

For example:

```bash
tar -xzf android-studio-*-linux.tar.gz
```

Move Android Studio to `/opt`:

```bash
sudo mv android-studio /opt/
```

Launch it:

```bash
/opt/android-studio/bin/studio
```

The first time Android Studio starts:

```text
Start Android Studio
        ↓
Choose whether to import old settings
        ↓
Run the Setup Wizard
        ↓
Allow it to install Android SDK components
```

Android Studio includes its own Java runtime, so I should not install a random separate JDK just because Veilmi uses Android.

After setup, `flutter doctor -v` will tell me which Java runtime Flutter is actually using and whether there is a real Java problem.

### Optional launcher

Inside Android Studio I can use:

```text
Tools
→ Create Desktop Entry
```

to add Android Studio to the Linux applications menu.

---

## 9. Install the Android SDK and Tools

Installing Android Studio itself is not enough.

I must also check the Android SDK.

Open Android Studio.

From the welcome screen:

```text
More Actions
→ SDK Manager
```

If a project is already open:

```text
Tools
→ SDK Manager
```

### SDK Platforms

Open:

```text
SDK Platforms
```

Install the Android SDK platform required by the project.

Veilmi currently targets Android API 36, so API 36 should be available.

### SDK Tools

Open:

```text
SDK Tools
```

Check that the Android development tools are installed.

The important ones include:

```text
Android SDK Build-Tools
Android SDK Command-line Tools
Android SDK Platform-Tools
Android Emulator
```

Current Flutter Android setup documentation may also recommend Android SDK components such as:

```text
CMake
NDK (Side by side)
```

These are Android SDK components. They are not the same thing as installing the Linux desktop Flutter toolchain.

Click:

```text
Apply
→ OK
```

and let Android Studio install the selected components.

---

## 10. Accept Android SDK Licences

After the Android SDK is installed, return to the terminal and run:

```bash
flutter doctor --android-licenses
```

Read and accept the required Android licences.

Then run:

```bash
flutter doctor -v
```

The important result is:

```text
[✓] Android toolchain
```

If `flutter doctor` still reports an Android problem, fix the item listed under **Android toolchain** before continuing.

I do not need to fix unrelated Linux desktop or Chrome/web warnings.

---

## 11. Check the Android SDK and ADB

On a normal Linux installation, Android Studio commonly places the SDK under:

```text
$HOME/Android/Sdk
```

Check what Flutter detected:

```bash
flutter doctor -v
```

The output should show the Android SDK path.

Platform Tools contain `adb`.

If this works:

```bash
adb version
```

then ADB is already on the PATH.

If `adb` is not found, I can still check it directly with:

```bash
$HOME/Android/Sdk/platform-tools/adb version
```

and later decide whether I want to add Platform Tools to the PATH.

---

# Restore the Veilmi Project

## 12. Clone Veilmi

After Git, VS Code, Flutter, and the Android development tools are ready:

```bash
cd ~
git clone https://github.com/noa-jou/Veilmi.git
cd Veilmi
```

If I already cloned Veilmi **before** installing Flutter, I do not need to clone it again.

I can simply return to:

```bash
cd ~/Veilmi
```

The Git repository restores important project files such as:

```text
lib/
test/
android/
ios/
assets/
docs/
pubspec.yaml
pubspec.lock
```

Some machine-specific files will be missing. That is normal.

---

## 13. Restore Flutter Packages

From the Veilmi project root:

```bash
flutter pub get
```

Flutter reads:

```text
pubspec.yaml
pubspec.lock
```

and restores the packages needed by Veilmi.

It also recreates local Flutter files such as:

```text
.dart_tool/
```

I do not need to copy `.dart_tool/` from the old computer.

---

## 14. Open Veilmi in VS Code

From:

```bash
cd ~/Veilmi
```

run:

```bash
code .
```

VS Code should open the project root.

The project root is the folder containing:

```text
pubspec.yaml
```

This matters because the Flutter extension recognizes the project from that file.

---

## 15. Local IDE Files May Be Recreated

Some IDE files are local machine metadata, for example:

```text
.idea/
veilmi.iml
android/veilmi_android.iml
```

Android Studio or IntelliJ may recreate them.

They do not need to be copied manually from the old computer.

---

## 16. Check Veilmi Before Editing Anything

Run:

```bash
flutter analyze
```

Then:

```bash
flutter test
```

If both succeed, the cloned project and its dependencies are working.

---

# Run Veilmi on a Real Android Phone

## 17. Enable Android Developer Options

On the Android test phone:

```text
Settings
→ About phone
→ tap Build number / OS version repeatedly
→ Developer options enabled
```

The exact wording depends on the phone manufacturer.

Then enable:

```text
USB debugging
```

---

## 18. Connect the Phone

Connect the phone with a USB cable that supports data.

When the phone asks whether to allow USB debugging from this computer, allow it.

Check ADB:

```bash
adb devices
```

If `adb` is not on the PATH:

```bash
$HOME/Android/Sdk/platform-tools/adb devices
```

A working connection should show a device rather than an empty list.

Then check Flutter:

```bash
flutter devices
```

The Android phone should appear.

---

## 19. If ADB Cannot See the Phone

Restart ADB:

```bash
$HOME/Android/Sdk/platform-tools/adb kill-server
$HOME/Android/Sdk/platform-tools/adb start-server
$HOME/Android/Sdk/platform-tools/adb devices
```

Also check:

```text
USB debugging is enabled
the phone is unlocked
the USB cable supports data
the phone accepted the computer's debugging key
the USB connection is not charge-only
```

On Linux, `lsusb` can also help confirm whether the computer can see the USB device at all:

```bash
lsusb
```

---

## 20. Continue Development in Debug Mode

Run:

```bash
flutter run
```

`flutter run` uses Debug mode by default.

I can also use:

```bash
flutter run --debug
```

There is no need to convert Veilmi from Release mode back into Debug mode.

Running:

```bash
flutter build appbundle --release
```

only creates a Release build.

It does not permanently change the project into Release mode.

---

## 21. Important: Do Not Change Release Signing Back to Debug

Veilmi's Android release signing configuration is stored in:

```text
android/app/build.gradle.kts
```

During the original release preparation, the release build was changed from debug signing to a real release signing configuration.

I should **not** change it back to:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

just because I am developing in Debug mode.

These are separate:

```text
flutter run
        ↓
Debug development
```

and:

```text
flutter build appbundle --release
        ↓
Release build using Veilmi's release signing configuration
```

When moving Veilmi to another computer, keep `android/app/build.gradle.kts` as stored in Git.

---

# When I Am Ready to Release a New Version

The next sections are only needed when I want to create another signed Android App Bundle for Google Play.

Normal Debug development does not require the upload keystore.

---

## 22. Restore the Android Upload Keystore

The Veilmi Android upload keystore is private and is not stored in GitHub.

I keep it outside the project directory at:

```text
$HOME/veilmi-upload-keystore.jks
```

On the new computer, restore it from my secure private backup.

The layout should look like:

```text
Home directory
├── veilmi-upload-keystore.jks
│
└── Veilmi/
    ├── android/
    ├── lib/
    ├── test/
    └── ...
```

Check the home directory with:

```bash
echo "$HOME"
```

The keystore must never be committed to the public Git repository.

---

## 23. Restore `android/key.properties`

This file is private and is not stored in GitHub:

```text
android/key.properties
```

Before creating a Release build, recreate or restore it.

Its structure is similar to:

```properties
storePassword=PRIVATE_PASSWORD
keyPassword=PRIVATE_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/veilmi-upload-keystore.jks
```

The real passwords must remain private.

`storeFile` must point to the upload keystore on the new computer.

---

## 24. Update the Version

Before releasing a new version, update:

```text
pubspec.yaml
```

For example:

```yaml
version: 1.0.1+2
```

Here:

```text
1.0.1
```

is the application version.

```text
2
```

is the build number.

The build number must be higher than the one used by the previous Google Play upload.

---

## 25. Build the New Release

Before building:

```bash
flutter analyze
flutter test
```

Then:

```bash
flutter build appbundle --release
```

The AAB should normally appear at:

```text
build/app/outputs/bundle/release/app-release.aab
```

---

# Quick Checklist

## Completely New Debian Computer

```text
1. Install basic packages
2. Install VS Code
3. Install Flutter
4. Add Flutter to PATH
5. Install VS Code Flutter extension
6. Install Android Studio
7. Install Android SDK + Platform Tools
8. Accept Android licences
9. Run flutter doctor -v
10. Clone Veilmi
11. flutter pub get
12. flutter analyze
13. flutter test
14. Connect Android phone
15. flutter devices
16. flutter run
```

## Veilmi Was Already Cloned Too Early

If I did this first:

```bash
git clone https://github.com/noa-jou/Veilmi.git
```

and later discovered:

```text
flutter: command not found
```

I do not need to clone Veilmi again.

I only need to install the missing development environment, then return to:

```bash
cd ~/Veilmi
flutter pub get
flutter analyze
flutter test
flutter run
```

## Ready for a New Google Play Release

```text
Restore upload keystore
        ↓
Restore android/key.properties
        ↓
Update pubspec.yaml version
        ↓
flutter analyze
        ↓
flutter test
        ↓
flutter build appbundle --release
        ↓
New signed AAB
```

---

# What Is Restored From Where?

```text
GitHub
→ Veilmi source code
→ project configuration
→ pubspec.yaml
→ pubspec.lock
→ Android/iOS project files
→ documentation
```

```text
flutter pub get
→ Flutter/Dart packages
→ local package metadata such as .dart_tool/
```

```text
VS Code / Android Studio
→ local editor and IDE metadata
```

```text
Private backup
→ veilmi-upload-keystore.jks
→ signing passwords
→ android/key.properties
```

The Android upload keystore is the most important private release file that I must keep in a separate secure backup.

---

# Official Setup References

Because Flutter, Android Studio, and VS Code change over time, use the official installation pages when an old screenshot or menu name no longer matches:

- Flutter installation: https://docs.flutter.dev/install
- Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
- Flutter in VS Code: https://docs.flutter.dev/tools/vs-code
- VS Code on Linux: https://code.visualstudio.com/docs/setup/linux
- Android Studio installation: https://developer.android.com/studio/install
