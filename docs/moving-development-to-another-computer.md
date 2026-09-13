# Moving Veilmi Development to Another Computer

This document is a practical reminder for continuing Veilmi development on
another computer.

For example, if Veilmi 1.0.0 has already been released and I want to develop
Veilmi 1.0.1 on a new computer, I can follow these steps.

---

## 1. Clone Veilmi

After installing Git, Flutter, and the Android development tools, clone the
project:

```bash
git clone https://github.com/noa-jou/Veilmi.git
cd Veilmi
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

## 2. Restore Flutter Packages

Run:

```bash
flutter pub get
```

Flutter reads `pubspec.yaml` and `pubspec.lock` and restores the packages needed
by Veilmi.

It also recreates local Flutter files such as:

```text
.dart_tool/
```

I do not need to copy `.dart_tool/` from the old computer.

---

## 3. Open the Project

Open the Veilmi folder in Android Studio, IntelliJ IDEA, VS Code, or another
Flutter-compatible editor.

Android Studio or IntelliJ may recreate local files such as:

```text
.idea/
veilmi.iml
android/veilmi_android.iml
```

These are local IDE files.

They do not need to be copied from the old computer or stored in GitHub.

---

## 4. Check Veilmi

Run:

```bash
flutter analyze
flutter test
```

If both commands complete successfully, the project is ready for development.

---

## 5. Continue Development in Debug Mode

Connect an Android test device and check that Flutter can see it:

```bash
flutter devices
```

Then run:

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

During the original release preparation, the old debug signing configuration
was replaced with a proper release signing configuration.

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

Therefore, when moving Veilmi to another computer, I should keep the
`android/app/build.gradle.kts` file exactly as it is stored in Git.

---

## 6. Start Developing the Next Version

At this point I can continue normal development.

For example:

```text
Veilmi 1.0.0 already released
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

The Android upload keystore is not required just to run and develop Veilmi in
Debug mode.

---

# When I Am Ready to Release a New Version

The following steps are only needed when I am ready to create another signed
Android App Bundle for Google Play.

---

## 7. Restore the Android Upload Keystore

The Veilmi Android upload keystore is private and is not stored in GitHub.

I keep it outside the project directory at:

```text
$HOME/veilmi-upload-keystore.jks
```

On the new computer, restore the keystore from my secure private backup and
place it in the home directory.

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

## 8. Restore `android/key.properties`

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

## 9. Update the Version

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

The build number must be higher than the one used by the previous Google Play
upload.

---

## 10. Build the New Release

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

## Quick Checklist

### To continue development on another computer

```bash
git clone https://github.com/noa-jou/Veilmi.git
cd Veilmi

flutter doctor
flutter pub get
flutter analyze
flutter test

flutter devices
flutter run
```

At this point I can continue developing Veilmi in Debug mode.

### When the new version is ready for Google Play

1. Restore `veilmi-upload-keystore.jks`.
2. Restore or recreate `android/key.properties`.
3. Update the version in `pubspec.yaml`.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Run:

```bash
flutter build appbundle --release
```

The easiest way to remember the process is:

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

GitHub restores the project source.

`flutter pub get` restores Flutter packages.

The IDE can recreate its own local files.

Flutter can recreate the `build/` directory.

The Android upload keystore is the important private file that I must keep in a
separate secure backup.