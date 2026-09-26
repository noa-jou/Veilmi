# Moving Veilmi Development to Another Computer

This document is a practical recovery guide for continuing Veilmi development on another computer.

It is written for my future self as an engineer. The Debian setup is intentionally command-line first, avoids unnecessary GUI dependencies, and avoids hard-coding tool versions whenever possible.

The most important thing to remember is:

> **GitHub stores the Veilmi project, not the whole development environment.**

A fresh computer still needs Git, VS Code, Java, Flutter, the Android command-line tools, and the Android SDK.

Veilmi currently focuses on Android development. I do **not** need the Flutter Linux desktop toolchain just because the development computer runs Linux.

---

## 1. Before You Start

### You need to know: Build, Run, and Test Are Different

These commands have different requirements:

```text
flutter analyze
flutter test
→ no Android runtime target required

flutter build apk --debug
flutter build appbundle --release
→ no Android runtime target required

flutter run
→ requires a runtime target
→ physical Android device OR Android emulator
```

---

### What a New Computer Needs

For normal Veilmi Android development:

```text
Operating system
        ↓
Git
        ↓
VS Code
        ↓
Debian default JDK
        ↓
Flutter SDK
        ↓
Dart
(included with Flutter)
        ↓
Google Android CLI
        ↓
Android SDK + Platform Tools + ADB
        ↓
Veilmi source code
        ↓
Flutter packages
```

For the tested Debian workflow:

```text
VS Code
→ main editor

Flutter
→ Dart + Flutter tooling

Google Android CLI
→ Android SDK management

ADB
→ Android device communication
```

Android Studio is **not required** for this command-line setup.

---

### Other Operating Systems

The Veilmi source code is the same on every computer, but the installation commands differ.

#### Windows

Install the same categories of tools:

```text
Git
VS Code
Java
Flutter
Android development tools / Android SDK
```

Windows may also require a phone manufacturer's USB driver when using a physical Android device.

#### macOS

Install:

```text
Git
VS Code
Java
Flutter
Android development tools / Android SDK
```

If I later build Veilmi for iOS, the Mac also needs Xcode and the iOS development tools.

#### Linux / Chromebook Linux

The Debian x86_64 workflow below is the tested path.

On a Chromebook, enable the Linux development environment first. Then run the Debian commands inside Linux.

ChromeOS may display Crostini notices about containerless environments or virtualization. Those notices are not, by themselves, Veilmi build failures.

---

## 2. (This is for my own example) Prepare the Debian x86_64 Environment

### Check the Machine Architecture

The following workflow was rebuilt and tested from a fresh Debian environment.

Check the architecture:

```bash
uname -m
```

These commands assume:

```text
x86_64
```

If the result is different, do not reuse the x64-specific download URLs blindly.

---

### Reserve Enough Disk Space Before Starting

The Veilmi Git repository itself is small. The tested clone was only around 10 MB.

The development environment is much larger.

During one tested rebuild, the environment already contained approximately:

```text
Flutter SDK        ~2.3 GB
Gradle cache       ~1.6 GB
Android SDK        ~1.4 GB
Pub cache          ~0.6 GB
VS Code + JDK      additional space
NDK                additional multi-GB space during installation/extraction
```

A first Android build may download more Gradle artifacts, SDK components, and an NDK.

Practical recommendation:

```text
Allocate at least about 20 GB to the Linux environment.
Try to keep around 10–12 GB free before the first Android build.
```

This is a practical Veilmi setup recommendation, not an official Flutter storage requirement.

Check the current space:

```bash
df -h "$HOME"
```

---

### Install the Basic Debian Packages

Update the package index:

```bash
sudo apt-get update
```

Install the basic tools:

```bash
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  python3 \
  default-jdk
```

Check them:

```bash
git --version
curl --version
python3 --version
java -version
javac -version
```

---

### Install the Latest Stable VS Code

Download the latest stable x64 Debian package directly to the home directory:

```bash
curl -fL \
  "https://update.code.visualstudio.com/latest/linux-deb-x64/stable" \
  -o "$HOME/vscode.deb"
```

Install it:

```bash
sudo apt-get install -y "$HOME/vscode.deb"
```

Remove the installer:

```bash
rm -f "$HOME/vscode.deb"
```

Check VS Code:

```bash
code --version
```

Install the Flutter extension:

```bash
code --install-extension Dart-Code.flutter
```

The Flutter extension also installs the Dart extension.

---

### Download the Latest Stable Flutter SDK

Do not hard-code a Flutter version.

Read the current stable Linux archive from Flutter's release metadata:

```bash
FLUTTER_URL="$(
  curl -fsSL \
    "https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json" |
  python3 -c '
import json
import sys

data = json.load(sys.stdin)
stable_hash = data["current_release"]["stable"]

release = next(
    item
    for item in data["releases"]
    if item["hash"] == stable_hash
)

print(data["base_url"] + "/" + release["archive"])
'
)"
```

Check the URL:

```bash
echo "$FLUTTER_URL"
```

Download it:

```bash
curl -fL "$FLUTTER_URL" -o "$HOME/flutter.tar.xz"
```

Create the development-tools directory:

```bash
mkdir -p "$HOME/develop"
```

Extract Flutter:

```bash
tar -xf "$HOME/flutter.tar.xz" -C "$HOME/develop"
```

Remove the archive:

```bash
rm -f "$HOME/flutter.tar.xz"
```

Flutter should now exist at:

```text
$HOME/develop/flutter
```

---

### Add Flutter to PATH

Add Flutter permanently to Bash without duplicating the line:

```bash
grep -qxF \
  'export PATH="$HOME/develop/flutter/bin:$PATH"' \
  "$HOME/.bashrc" ||
echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> "$HOME/.bashrc"
```

Reload the Bash configuration:

```bash
source "$HOME/.bashrc"
```

Check Flutter and Dart:

```bash
flutter --version
dart --version
```

Dart comes with Flutter and does not need a separate installation.

---

### Disable Unused Flutter Targets

This Debian environment is intended for **Veilmi Android development**.

Flutter supports several target platforms. Because this computer runs Linux,
Flutter may also try to treat Linux desktop as a runnable target. That can be
confusing when Veilmi is only being developed for Android.

Disable Linux desktop:

```bash
flutter config --no-enable-linux-desktop
```

Disable Flutter Web:

```bash
flutter config --no-enable-web
```

Reloading VS Code after changing Flutter configuration is a good idea if it is
already open.

These commands do **not** delete the `linux/` or `web/` folders from the
repository. They only stop this Flutter installation from treating those
platforms as normal runtime targets.

#### Why I Do Not Install the Linux Desktop Toolchain

If Flutter tries to build Veilmi as a Linux desktop application, it may ask for
tools such as:

```text
clang
cmake
ninja-build
pkg-config
libgtk-3-dev
```

These tools are for building a native **Linux desktop** Flutter application:

```text
clang
→ C / C++ compiler used by native Linux builds

cmake
→ generates the native build configuration

ninja-build
→ executes the generated native build steps

pkg-config
→ helps the build system locate installed native libraries

libgtk-3-dev
→ development files for the GTK Linux desktop interface
```

They are not required merely because the development computer itself runs
Debian.

Veilmi's Android build uses the Android / Gradle toolchain instead.

This distinction matters because, when no Android runtime target was connected,
an earlier:

```bash
flutter run
```

attempted to launch the Linux desktop version and started asking for CMake and
other Linux desktop dependencies.

That did **not** mean Veilmi's Android environment was missing those tools.

Disabling the unused targets makes the intention clearer:

```text
This Debian machine
        ↓
develops Veilmi
        ↓
for Android
```

If I intentionally decide to support Veilmi as a Linux desktop or web
application in the future, I can enable those targets again and install their
separate development requirements at that time.

---

### Install Google's Android CLI

Create the APT keyring directory:

```bash
sudo mkdir -p /etc/apt/keyrings
```

Add Google's signing key:

```bash
curl -fsSL \
  "https://dl.google.com/linux/linux_signing_key.pub" |
sudo tee /etc/apt/keyrings/google.asc >/dev/null
```

Add the Android CLI repository:

```bash
echo \
  "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.asc] http://dl.google.com/android/cli/latest/debian/ stable main" |
sudo tee /etc/apt/sources.list.d/android-cli.list >/dev/null
```

Update APT:

```bash
sudo apt-get update
```

Install Android CLI:

```bash
sudo apt-get install -y android-cli
```

Check it:

```bash
android -V
```

On first use, Android CLI may download and unpack its embedded installation and display its Terms of Service.

---

### Create the Android SDK Directory

Create:

```bash
mkdir -p "$HOME/Android/Sdk"
```

Tell Android CLI to use it:

```bash
printf '%s\n' \
  "--sdk=$HOME/Android/Sdk" \
  > "$HOME/.androidrc"
```

Check the result:

```bash
android info sdk
```

It should point to:

```text
$HOME/Android/Sdk
```

---

### Install the Version-Free Android Base Tools

Install the Android components whose package names are intentionally stable:

```bash
android sdk install \
  cmdline-tools/latest \
  platform-tools
```

Do **not** copy an old Android platform, Build Tools, or NDK version number from another machine.

The current Flutter / Gradle build can request the versions it actually needs.

---

### Add Android Tools to PATH

Add the SDK location:

```bash
grep -qxF \
  'export ANDROID_HOME="$HOME/Android/Sdk"' \
  "$HOME/.bashrc" ||
echo 'export ANDROID_HOME="$HOME/Android/Sdk"' >> "$HOME/.bashrc"
```

Add Platform Tools:

```bash
grep -qxF \
  'export PATH="$ANDROID_HOME/platform-tools:$PATH"' \
  "$HOME/.bashrc" ||
echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> "$HOME/.bashrc"
```

Reload the Bash configuration:

```bash
source "$HOME/.bashrc"
```

Check ADB:

```bash
adb version
```

---

### Quick Environment Check

Run this before restoring and building Veilmi:

```bash
git --version
code --version
java -version
javac -version
flutter --version
dart --version
android -V
adb version
flutter doctor -v
```

At this stage, `flutter doctor -v` is a diagnostic check.

The Android toolchain might not yet be completely green if a project-specific Android platform, Build Tools package, or NDK has not been installed. The first Veilmi Android build can request those components.

A physical Android device is not required here.

#### Android Licences

With newer Android CLI versions:

```bash
flutter doctor --android-licenses
```

may report:

```text
The --licenses option is no longer needed.
```

If `flutter doctor -v` already reports that the Android licences are accepted, do nothing.

Only use the licence command when the installed tooling says licence acceptance is still required.

---

## Restore the Veilmi Project

### Clone Veilmi

If Veilmi has not already been cloned:

```bash
cd "$HOME"
git clone https://github.com/noa-jou/Veilmi.git
cd "$HOME/Veilmi"
```

If the repository was cloned earlier, do not clone it again:

```bash
cd "$HOME/Veilmi"
```

A fresh clone restores files such as:

```text
lib/
test/
android/
ios/
assets/
docs/
pubspec.yaml
analysis_options.yaml
```

#### `pubspec.lock`

In the current Veilmi repository, `pubspec.lock` is not restored from GitHub.

It is created locally when dependencies are resolved.

---

### Restore Flutter Packages

From the project root:

```bash
cd "$HOME/Veilmi"
flutter pub get
```

This creates / restores local dependency metadata such as:

```text
.dart_tool/
.flutter-plugins-dependencies
pubspec.lock
```

There is no need to copy `.dart_tool/` from the old computer.

If Flutter reports that newer package versions exist but are incompatible with the current dependency constraints, that does not mean `flutter pub get` failed.

Do not automatically perform a major dependency upgrade merely because newer versions exist.

---

### Open Veilmi in VS Code

```bash
cd "$HOME/Veilmi"
code .
```

VS Code should recognize the project because the project root contains:

```text
pubspec.yaml
```

Some local IDE metadata may be recreated on the new computer:

```text
.idea/
*.iml
```

These do not need to be copied manually from the old computer.

---

### Verify Veilmi Before Any Android Build

Run:

```bash
flutter analyze
```

Then:

```bash
flutter test
```

Both should succeed before I begin relying on Android build results.

If I later change source code before a Release build, repeat these checks.

---

## Build Veilmi for Android

### First Debug APK Build — Let Gradle Request the Required Android Components

Run:

```bash
cd "$HOME/Veilmi"
flutter build apk --debug
```

Modern Android Gradle tooling can automatically download missing SDK components required by the project when the relevant licences are already accepted.

The important rule is:

> **Automatic installation means the version required by the current project / Flutter / Android Gradle Plugin — not simply the newest package in the Android repository.**

For Veilmi, the Android Gradle configuration uses Flutter-provided values such as the current Flutter compile SDK / NDK requirements, so a first build may download exactly the component version requested by that toolchain.

If the build succeeds, no manual package installation is needed.

A successful Debug APK normally appears at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

---

### If Automatic Android Component Installation Fails

Only use this section when the Debug build reports that a required Android component could not be installed or could not be found.

First inspect the packages that the current repository actually exposes.

Android platforms:

```bash
android sdk list --all "platforms*"
```

Build Tools:

```bash
android sdk list --all "build-tools*"
```

NDK:

```bash
android sdk list --all "ndk*"
```

Package names can include patch suffixes.

Do not assume that an API family has one unsuffixed package name.

#### Install the Exact Platform / Build Tools Package

Copy the exact package path shown by the build error or current Android package list:

```bash
REQUIRED_PLATFORM='<copy-exact-platform-package-path>'
REQUIRED_BUILD_TOOLS='<copy-exact-build-tools-package-path>'
```

Install them:

```bash
android sdk install \
  "$REQUIRED_PLATFORM" \
  "$REQUIRED_BUILD_TOOLS"
```

#### Install the Exact NDK Required by the Build

If the build reports an exact NDK version:

```bash
REQUIRED_NDK='<copy-exact-ndk-version-reported-by-the-build>'
```

Confirm that it exists:

```bash
android sdk list --all "ndk*" | grep "$REQUIRED_NDK"
```

Install it:

```bash
android sdk install "ndk/$REQUIRED_NDK"
```

Retry the build:

```bash
cd "$HOME/Veilmi"
flutter build apk --debug
```

Do not automatically install the numerically newest Android platform or NDK merely because it exists.

---

### Warnings Seen During a Successful Debug Build

Read this section immediately after the first Debug APK build.

A build can succeed even when Flutter / Gradle prints warnings.

Do not automatically change the Veilmi project merely because a warning appears.

#### `sdkmanager` Deprecation Warning

Flutter may explain that the old SDK Manager CLI is deprecated and the newer Android CLI will be used instead.

This is not a build failure.

#### `cryptography_flutter` Kotlin Gradle Plugin Warning

A tested Debug APK build printed a future compatibility warning for:

```text
cryptography_flutter
```

The APK still built successfully.

Treat this as an upstream dependency warning to review when updating Flutter or the plugin.

Do not rewrite the Gradle project solely because the current build prints this warning.

#### SDK XML Version Warning

A tested build also printed an SDK XML compatibility warning.

The APK still built successfully.

If the build ends with:

```text
✓ Built ...
```

the build itself succeeded. Investigate the warning separately.

---

## Run Veilmi on an Android Device

### Detect the Device

Running is separate from building.

Enable USB debugging on the Android phone and connect it.

Check ADB:

```bash
adb devices
```

Then let Flutter list its runtime targets:

```bash
flutter devices
```

Flutter prints a device ID for every detected target.

Example shape:

```text
Android Phone • DEVICE_ID • android-arm64 • Android ...
```

### Run on That Exact Device

Use the ID shown by `flutter devices`:

```bash
flutter run -d DEVICE_ID
```

For example:

```text
My Android Phone • ABC123XYZ • android-arm64 • Android ...
```

means:

```bash
flutter run -d ABC123XYZ
```

This avoids accidentally selecting the wrong target.

### If the Device Is Unauthorized

Restart ADB:

```bash
adb kill-server
adb start-server
adb devices
```

Unlock the phone and accept the USB debugging authorization prompt.

Then check again:

```bash
flutter devices
```

On ChromeOS, the USB device may also need to be shared with the Linux environment.

### If no Android target is connected, a Debug APK can still be built with:

```bash
flutter build apk --debug
```

---

## Restore Release Signing and Build a Google Play AAB

This section is for creating a signed Google Play Release build on the new computer.

Normal Debug development should work without:

```text
$HOME/veilmi-upload-keystore.jks
android/key.properties
```

### Keep Veilmi's Release Signing Configuration

The Android Release signing configuration is stored in:

```text
android/app/build.gradle.kts
```

Do **not** change Release signing back to:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

Debug and Release builds are separate:

```text
flutter build apk --debug
→ Debug signing / development

flutter build appbundle --release
→ Veilmi Release signing
```

The current project configuration should allow Debug builds without the private signing files and use the private signing configuration only for Release builds.

### Restore the Upload Keystore

The Veilmi upload keystore is private and is not stored in GitHub.

Restore it from the secure private backup:

```bash
cp \
  "/path/to/private-backup/veilmi-upload-keystore.jks" \
  "$HOME/veilmi-upload-keystore.jks"
```

Restrict permissions:

```bash
chmod 600 "$HOME/veilmi-upload-keystore.jks"
```

Check the file:

```bash
ls -l "$HOME/veilmi-upload-keystore.jks"
```

Optionally verify the expected alias:

```bash
keytool -list \
  -keystore "$HOME/veilmi-upload-keystore.jks" \
  -alias upload
```

`keytool` will ask for the keystore password.

### Restore `android/key.properties`

Move to Veilmi:

```bash
cd "$HOME/Veilmi"
```

Create or restore:

```text
android/key.properties
```

Its structure is:

```properties
storePassword=PRIVATE_PASSWORD
keyPassword=PRIVATE_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/veilmi-upload-keystore.jks
```

Open it in VS Code:

```bash
code android/key.properties
```

Use the real private passwords.

For `storeFile`, use the real absolute path on the new computer.

Check it with:

```bash
echo "$HOME/veilmi-upload-keystore.jks"
```

The value in `storeFile` should point to that file.

This is how the repository's Gradle configuration finds the restored upload keystore:

```text
android/app/build.gradle.kts
        ↓
reads android/key.properties
        ↓
key.properties contains storeFile
        ↓
storeFile points to veilmi-upload-keystore.jks
```

Restrict permissions:

```bash
chmod 600 android/key.properties
```

Confirm that Git ignores it:

```bash
git check-ignore -v android/key.properties
```

Also check:

```bash
git status --short
```

The private signing file must never be committed.

### Check the App Version

Show the current version:

```bash
grep '^version:' pubspec.yaml
```

Edit if necessary:

```bash
code pubspec.yaml
```

The format is:

```yaml
version: <version-name>+<build-number>
```

For a new Google Play upload, the build number must be higher than the previous uploaded build number.

### Re-run Verification If Anything Changed

If source code or release configuration changed after the earlier verification step:

```bash
flutter analyze
flutter test
```

### Build the Signed AAB

```bash
flutter build appbundle --release
```

A successful AAB should normally appear at:

```text
build/app/outputs/bundle/release/app-release.aab
```

Check it:

```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

## What Is Restored From Where?

```text
GitHub
→ Veilmi source code
→ project configuration
→ Android/iOS project files
→ assets
→ documentation
→ pubspec.yaml
```

```text
flutter pub get
→ Flutter/Dart packages
→ .dart_tool/
→ .flutter-plugins-dependencies
→ local pubspec.lock for the current Veilmi repository
```

```text
VS Code
→ editor environment
→ Flutter extension
→ Dart extension
```

```text
Android CLI
→ Android SDK components
→ Platform Tools / ADB
→ project-required platform / Build Tools / NDK packages
```

```text
Private backup
→ veilmi-upload-keystore.jks
→ android/key.properties
→ signing passwords
```

The upload keystore and signing information must remain outside the public repository.

---

## Official References

Because Flutter, Android tooling, and VS Code evolve, use current official documentation when command behaviour changes:

- Flutter installation: https://docs.flutter.dev/install
- Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
- Flutter in VS Code: https://docs.flutter.dev/tools/vs-code
- VS Code on Linux: https://code.visualstudio.com/docs/setup/linux
- Android command-line tools: https://developer.android.com/tools
- Android SDK packages: https://developer.android.com/tools
