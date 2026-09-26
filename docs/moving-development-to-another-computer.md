# Moving Veilmi Development to Another Computer

This document is a practical reminder for continuing Veilmi development on another computer.

For example, if Veilmi 1.0.0 has already been released and I want to develop Veilmi 1.0.1 on a new computer, I can follow these steps.

The most important thing to remember is:

> **GitHub stores the Veilmi project, but not the whole development environment.**

Cloning the repository gives me the source code. A new computer still needs the software required to run, test, and build a Flutter Android project.

---

## 1. What a New Computer Needs

For normal Veilmi Android development, I need:

```text
Operating system
        ↓
Git
        ↓
Flutter SDK
        ↓
Dart
(included with Flutter)
        ↓
Android development tools
(Android Studio / Android SDK / ADB)
        ↓
Code editor
        ↓
Veilmi source code
        ↓
Flutter packages
```

The main tools are:

| Tool | Why I need it |
|---|---|
| Git | Clone Veilmi and manage source-code changes |
| Flutter SDK | Run, analyze, test, and build Veilmi |
| Dart | The language used by Flutter; included with Flutter |
| Android SDK | Build the Android version |
| ADB / Platform Tools | Connect Android test devices |
| Android Studio | Convenient way to install/manage the Android SDK and Android tooling |
| Code editor | Edit the project; VS Code is convenient, but not required |

### Different operating systems

The Veilmi project itself is the same, but the development environment is installed differently depending on the computer.

#### Windows

For Android development, install:

```text
Git
Flutter SDK
Android Studio + Android SDK
VS Code or another editor
```

#### macOS

For Android development, install:

```text
Git
Flutter SDK
Android Studio + Android SDK
VS Code or another editor
```

If I later want to build Veilmi for iOS, the Mac also needs Xcode and the iOS development tools.

#### Linux

For Android development, install:

```text
Git and basic Linux tools
Flutter SDK
Android Studio + Android SDK
VS Code or another editor
```

The Debian example below shows this setup.

#### Chromebook

A Chromebook can use the Linux development environment.

After Linux is enabled, the setup is essentially a Linux setup, so the Debian example below is also useful.

### What matters in `flutter doctor`

Veilmi currently focuses on Android development.

I do not need every platform that Flutter supports.

For example:

```text
Android toolchain       → important

Chrome / web            → not required for Android development

Linux desktop toolchain → not required for Android development

Windows desktop tools   → not required for Android development

Xcode / iOS tools       → only needed when working on the iOS version
```

For normal Android work, the important results are:

```text
Flutter
        ✓

Android toolchain
        ✓

Android device or emulator
        ✓
```

---

# Example: Setting Up Veilmi on a New Debian Computer

The following example assumes I have a new Debian-based development environment with no Flutter installation yet.

If some tools are already installed, I can simply skip those steps.

---

## 2. Install the Basic Linux Tools

Update the package list:

```bash
sudo apt update
```

Install the basic tools needed for Flutter development:

```bash
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa
```

Check Git:

```bash
git --version
```

On a normal Debian installation, this may not work:

```bash
sudo apt install flutter
```

If APT reports:

```text
Unable to locate package flutter
```

that does not mean anything is wrong with Veilmi.

Flutter needs to be installed separately.

---

## 3. Install the Flutter SDK

Create a place for development tools:

```bash
mkdir -p ~/develop
```

Install the stable Flutter SDK:

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/develop/flutter
```

Add Flutter to the shell PATH:

```bash
echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> ~/.bashrc
```

Reload the shell:

```bash
source ~/.bashrc
```

Check that Flutter is available:

```bash
flutter --version
```

Dart should also be available because it is included with Flutter:

```bash
dart --version
```

For reference, Veilmi has been developed with Flutter and Dart from the stable Flutter channel.

If I use a newer Flutter version on a new computer, I should run the full Veilmi analysis and test suite before assuming that everything still behaves the same.

---

## 4. Install the Android Development Tools

To build and run the Android version of Veilmi, install Android Studio and the Android SDK.

Android Studio can provide or manage:

```text
Android SDK
Android Platform Tools
ADB
Android emulator
Java runtime used by Android tooling
```

After the Android tools are available, run:

```bash
flutter doctor -v
```

If Flutter asks me to accept Android licences:

```bash
flutter doctor --android-licenses
```

Then run:

```bash
flutter doctor -v
```

again.

For Veilmi Android development, the important result is:

```text
[✓] Android toolchain
```

Warnings about Chrome or Linux desktop development can be ignored if I am only working on the Android version.

---

## 5. Clone Veilmi

After Git, Flutter, and the Android development tools are ready, clone the project:

```bash
git clone https://github.com/noa-jou/Veilmi.git
cd Veilmi
```

If I already cloned Veilmi before installing Flutter, I do **not** need to clone it again.

I can simply return to the existing project:

```bash
cd ~/Veilmi
```

Then check the Flutter environment:

```bash
flutter doctor
```

The Git repository restores the important project files, including:

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

Some local files will be missing after cloning. This is normal.

---

## 6. Restore Flutter Packages

Run:

```bash
flutter pub get
```

Flutter reads `pubspec.yaml` and `pubspec.lock` and restores the packages needed by Veilmi.

It also recreates local Flutter files such as:

```text
.dart_tool/
```

I do not need to copy `.dart_tool/` from the old computer.

---

## 7. Open the Project

Open the Veilmi folder in Android Studio, IntelliJ IDEA, VS Code, or another Flutter-compatible editor.

Android Studio or IntelliJ may recreate local files such as:

```text
.idea/
veilmi.iml
android/veilmi_android.iml
```

These are local IDE files.

They do not need to be copied from the old computer or stored in GitHub.

---

## 8. Check Veilmi

Before changing anything, run:

```bash
flutter analyze
flutter test
```

If both commands complete successfully, the source code and Flutter packages are working correctly on the new computer.

---

## 9. Connect an Android Test Device

Enable Developer Options and USB debugging on the Android test phone.

Connect the phone to the computer.

Check whether ADB can see it:

```bash
adb devices
```

Then check whether Flutter can see it:

```bash
flutter devices
```

If the device appears, Veilmi is ready to run on the phone.

---

## 10. Continue Development in Debug Mode

Run:

```bash
flutter run
```

`flutter run` uses Debug mode by default.

I can also write:

```bash
flutter run --debug
```

There is no need to convert Veilmi from Release mode back into Debug mode.

Running:

```bash
flutter build appbundle --release
```

only creates a Release build.

It does not permanently change the Flutter project into Release mode.

### Important: Do Not Change the Release Signing Configuration Back to Debug

Veilmi's Android release signing configuration is stored in:

```text
android/app/build.gradle.kts
```

During the original release preparation, the old debug signing configuration was replaced with a proper release signing configuration.

I should **not** change this file back to:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

just because I am developing Veilmi in Debug mode.

The project can still run normally in Debug mode with:

```bash
flutter run
```

The two situations are separate:

```text
flutter run
    ↓
Debug development


flutter build appbundle --release
    ↓
Release build using Veilmi's release signing configuration
```

Therefore, when moving Veilmi to another computer, I should keep the `android/app/build.gradle.kts` file exactly as it is stored in Git.

---

## 11. Start Developing the Next Version

At this point I can continue normal development.

For example:

```text
Veilmi 1.0.0 already released
        ↓
Set up Flutter and Android tools
        ↓
Clone project
        ↓
flutter pub get
        ↓
flutter analyze
flutter test
        ↓
flutter run
        ↓
Develop Veilmi 1.0.1
```

The Android upload keystore is not required just to run and develop Veilmi in Debug mode.

---

# When I Am Ready to Release a New Version

The following steps are only needed when I am ready to create another signed Android App Bundle for Google Play.

---

## 12. Restore the Android Upload Keystore

The Veilmi Android upload keystore is private and is not stored in GitHub.

I keep it outside the project directory at:

```text
$HOME/veilmi-upload-keystore.jks
```

On the new computer, restore the keystore from my secure private backup and place it in the home directory.

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

I can check the home directory with:

```bash
echo "$HOME"
```

The keystore must never be committed to the public Git repository.

---

## 13. Restore `android/key.properties`

The file:

```text
android/key.properties
```

is also private and is not stored in GitHub.

Before creating a Release build, I need to recreate or restore it.

Its structure is similar to:

```properties
storePassword=PRIVATE_PASSWORD
keyPassword=PRIVATE_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/veilmi-upload-keystore.jks
```

The real passwords must remain private.

The `storeFile` value must point to the upload keystore on the new computer.

---

## 14. Update the Version

Before releasing a new version, update the version in:

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

is the application version, while:

```text
2
```

is the build number.

The build number must be higher than the one used by the previous Google Play upload.

---

## 15. Build the New Release

Before creating the release:

```bash
flutter analyze
flutter test
```

Then build the signed Android App Bundle:

```bash
flutter build appbundle --release
```

The new AAB should normally appear at:

```text
build/app/outputs/bundle/release/app-release.aab
```

---

# Quick Checklists

## A. Completely New Computer

```text
Install Git
        ↓
Install Flutter
        ↓
Install Android development tools
        ↓
Run flutter doctor
        ↓
Clone Veilmi
        ↓
flutter pub get
        ↓
flutter analyze
        ↓
flutter test
        ↓
Connect Android device
        ↓
flutter run
```

## B. Veilmi Is Already Cloned

If I cloned Veilmi before installing Flutter:

```text
Keep the existing Veilmi folder
        ↓
Install Flutter
        ↓
Install Android development tools
        ↓
cd ~/Veilmi
        ↓
flutter pub get
        ↓
flutter analyze
flutter test
        ↓
flutter run
```

There is no need to clone the repository again.

## C. When the New Version Is Ready for Google Play

1. Restore `veilmi-upload-keystore.jks`.
2. Restore or recreate `android/key.properties`.
3. Update the version in `pubspec.yaml`.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Run:

```bash
flutter build appbundle --release
```

The easiest way to remember the difference is:

```text
Continue development
        ↓
flutter run
        ↓
Debug mode


Ready to publish
        ↓
Restore signing files
        ↓
Update version
        ↓
flutter build appbundle --release
        ↓
Release AAB
```

---

# What GitHub Restores and What It Does Not

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
→ Flutter/Dart package dependencies
→ local generated package metadata such as .dart_tool/
```

```text
IDE
→ local IDE files such as .idea/ and .iml files
```

```text
Not stored publicly
→ Android upload keystore
→ signing passwords
→ android/key.properties
```

The Android upload keystore is the important private file that I must keep in a separate secure backup.
