# Chromebook Flutter Development Environment

This guide explains how to configure a Chromebook Linux terminal for Flutter
and Android development.

It is written for beginners who may not have configured a development
environment before.

---

## 1. What This Setup Does

Flutter development uses several command-line tools:

```text
Flutter
Dart
Java
Android SDK
ADB
```

The terminal needs to know where these tools are installed.

This is controlled mainly through environment variables such as:

```text
PATH
JAVA_HOME
ANDROID_HOME
```

If these variables are not loaded correctly, commands such as:

```bash
flutter
dart
java
adb
```

may return:

```text
command not found
```

even when the software is already installed.

---

## 2. Bash Configuration Files

On Linux, shell settings are commonly stored in:

```text
~/.bashrc
```

However, some terminal sessions may start as login shells and read:

```text
~/.profile
```

instead.

A reliable setup is:

```text
Terminal starts
      ↓
~/.profile
      ↓
~/.bashrc
      ↓
Development environment is loaded
```

---

## 3. Make `.profile` Load `.bashrc`

Open:

```bash
code ~/.profile
```

Make sure the following block exists:

```bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
```

This tells Bash to load `.bashrc` when `.profile` is used.

Save the file.

---

## 4. Configure the Development Environment

Open:

```bash
code ~/.bashrc
```

Add a development environment block near the end of the file.

Example:

```bash
# Flutter SDK
export FLUTTER_HOME="$HOME/develop/flutter"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# Java
export JAVA_HOME="/path/to/java"

# Development tools
export PATH="$FLUTTER_HOME/bin:$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
```

The paths above are examples.

Replace them with the actual installation locations on the development
computer.

For example, if Flutter is installed somewhere else, change:

```bash
export FLUTTER_HOME="$HOME/develop/flutter"
```

to the correct location.

---

## 5. Avoid Duplicate or Placeholder Entries

Do not repeatedly add the same directory to `PATH`.

For example, this is unnecessary:

```bash
export PATH="$HOME/develop/flutter/bin:$PATH"
export PATH="$HOME/develop/flutter/bin:$PATH"
export PATH="$HOME/develop/flutter/bin:$PATH"
```

One entry is enough.

Also remove unfinished placeholders such as:

```bash
export PATH="<path-to-sdk>/bin:$PATH"
```

A placeholder is documentation, not a real filesystem path.

---

## 6. Reload the Shell Configuration

After editing `.profile` or `.bashrc`, apply the changes with:

```bash
source ~/.profile
```

This should load `.bashrc` as well.

There is no need to restart the Chromebook just to apply these changes.

---

## 7. Verify the Environment

Run:

```bash
which flutter
which dart
which java
which adb
```

Each command should return a real executable path.

Then check the installed tools:

```bash
flutter --version
dart --version
java -version
adb version
```

Finally, run:

```bash
flutter doctor -v
```

`flutter doctor` checks several Flutter development targets, not only Android.

A completely clean result is helpful, but **not every warning or error means
that Android development is broken**.

For example, an Android-focused project may show output similar to:

```text
[✓] Flutter
[!] Android toolchain
[✗] Chrome
[✗] Linux toolchain
[☠] Connected device
[!] Network resources
```

This can still be usable for Android development.

### What matters for Android development

#### Flutter

```text
[✓] Flutter
```

This confirms that Flutter and Dart are available.

#### Android toolchain

```text
[!] Android toolchain
```

Read the details below the warning.

For example, Flutter may report:

```text
Android license status unknown.
```

This does not necessarily mean that the SDK itself is missing.

The licenses can normally be checked with:

```bash
flutter doctor --android-licenses
```

More importantly, confirm that Flutter can find:

```text
Android SDK
Java
Android build tools
```

#### Chrome

```text
[✗] Chrome
```

This matters when developing a Flutter web application.

It can be ignored when the project is currently being tested only on Android.

#### Linux toolchain

Flutter may report missing tools such as:

```text
clang++
CMake
ninja
pkg-config
```

These are required for building a Linux desktop application.

They are not required simply to build and test an Android application.

Therefore, an Android-only project does not need to install these packages just
to make `flutter doctor` completely green.

#### Connected device

A connected-device check can occasionally time out or fail:

```text
[☠] Connected device
```

Check the device directly instead:

```bash
adb devices
flutter devices
```

If the Android phone appears correctly there, continue with physical-device
testing.

See:

```text
docs/android-device-testing.md
```

for the full setup and troubleshooting process.

#### Network resources

Flutter may occasionally report:

```text
[!] Network resources
```

because a Google or Flutter server could not be reached.

A temporary network or DNS problem does not mean that Flutter itself is
incorrectly installed.

If packages or Android build dependencies need to be downloaded, however, the
network connection must be working before the build can complete.

---

### A practical check

For an Android project, a more useful final test is:

```bash
flutter analyze
flutter test
adb devices
flutter devices
```

and then:

```bash
flutter run -d DEVICE_ID
```

If the project passes analysis and tests, Flutter detects the Android phone, and
the application successfully builds and runs on that phone, the Android
development environment is working even if `flutter doctor` still reports
issues for unused platforms.

Do not install unrelated web or Linux desktop dependencies only to make every
`flutter doctor` line display `[✓]`.

## 8. Test a New Terminal Session

Running:

```bash
source ~/.profile
```

only proves that the configuration works when loaded manually.

The more important test is whether it loads automatically.

Close the terminal completely and open a new Linux terminal.

Without running any `source` command, try:

```bash
flutter --version
```

If Flutter works immediately, the shell startup configuration is working.

---

## 9. If Flutter Is Still Not Found

First check whether Flutter is actually installed:

```bash
ls "$HOME/develop/flutter/bin/flutter"
```

If the file exists but this fails:

```bash
flutter --version
```

the problem is probably the shell configuration or `PATH`.

Check whether `.profile` loads `.bashrc`:

```bash
grep -n "bashrc" ~/.profile
```

Then inspect the relevant environment settings:

```bash
grep -nE 'FLUTTER_HOME|ANDROID_HOME|JAVA_HOME|PATH' ~/.bashrc
```

This helps distinguish between:

```text
Software exists
but command is unavailable
        ↓
Shell / PATH problem
```

and:

```text
Software does not exist
        ↓
Installation problem
```

Do not reinstall Flutter simply because the terminal cannot find the command.

---

## 10. Normal Flutter Development Check

Once the environment is working, a basic project check is:

```bash
flutter analyze
flutter test
```

For Android physical-device testing:

```bash
adb devices
flutter devices
flutter run -d DEVICE_ID
```

A normal development workflow is therefore:

```text
Open terminal
     ↓
Environment loads automatically
     ↓
flutter analyze
     ↓
flutter test
     ↓
Connect Android device
     ↓
flutter run
```

For detailed Android phone setup and USB debugging instructions, see:

```text
docs/android-device-testing.md
```