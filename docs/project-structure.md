
# Veilmi Project Structure

This document provides an overview of the Veilmi repository and explains
the purpose of its main directories and files.

The goal is to make the project easier to understand without requiring a
reader to explore every directory individually.

---

## 1. Repository Overview

At a high level, the Veilmi repository is organized like this:

```text
Veilmi/
├── android/
├── assets/
│   └── icon/
├── docs/
├── ios/
├── lib/
│   ├── crypto/
│   ├── device_check/
│   ├── l10n/
│   ├── screens/
│   └── settings/
├── linux/
├── macos/
├── test/
│   └── crypto/
├── tool/
├── web/
├── windows/
│
├── analysis_options.yaml
├── flutter_launcher_icons.yaml
├── LICENSE
├── pubspec.lock
├── pubspec.yaml
├── README.md
└── README.zh.md
````

The most important directories for understanding Veilmi itself are:

```text
lib/      application source code
test/     automated tests
assets/   icons
docs/     project documentation
```

The platform directories such as `android/`and `ios/` contain platform-specific Flutter project files.

---

## 2. `lib/` — Main Application Code

The `lib/` directory contains Veilmi's main Dart source code.

```text
lib/
├── main.dart
│
├── crypto/
│   ├── crypto_constants.dart
│   ├── crypto_service.dart
│   ├── message_envelope.dart
│   └── protection_level.dart
│
├── device_check/
│   └── device_check_service.dart
│
├── l10n/
│   ├── app_en.arb
│   ├── app_localizations.dart
│   └── app_zh_Hant.arb
│
├── screens/
│   ├── about_screen.dart
│   ├── device_check_screen.dart
│   ├── home_screen.dart
│   └── settings_screen.dart
│
└── settings/
    └── settings_service.dart
```

### `main.dart`

```text
lib/main.dart
```

This is the main entry point of the Flutter application.

It starts Veilmi and connects the main application configuration with the
user interface, localization, and application settings.

---

## 3. `lib/crypto/` — Cryptographic Logic

```text
lib/crypto/
├── crypto_constants.dart
├── crypto_service.dart
├── message_envelope.dart
└── protection_level.dart
```

This directory contains the code related to Veilmi's encryption and
decryption system.

### `crypto_service.dart`

Contains the main cryptographic operations used by Veilmi.

Conceptually, this is where the application performs operations such as:

```text
plaintext
    ↓
shared passphrase
    ↓
key derivation
    ↓
encryption
    ↓
protected message
```

and the reverse process during decryption.

For a detailed explanation of the cryptographic design, see:

* [Cryptography Notes](crypto-notes.md)
* [Cryptographic Design and Future Direction](crypto-design-and-future.md)

### `message_envelope.dart`

Handles the structure of Veilmi protected messages.

Veilmi does not output only raw ciphertext. The encrypted data and the
information required to interpret it are stored inside a versioned message
format.

A protected message begins with:

```text
VEILMI1:
```

This allows Veilmi to recognize the current message protocol.

### `crypto_constants.dart`

Stores constants used by the cryptographic implementation.

Keeping cryptographic parameters in a dedicated file makes them easier to
review and avoids unnecessarily repeating important values throughout the
application.

### `protection_level.dart`

Defines Veilmi's selectable protection levels.

The current interface provides different PBKDF2 work factors so that users
can choose an appropriate balance between protection and device performance.

---

## 4. `lib/device_check/` — Device Performance Check

```text
lib/device_check/
└── device_check_service.dart
```

The Device Check system measures how long Veilmi's protection levels take
on the current device.

Different phones can have very different performance characteristics.

The benchmark therefore helps Veilmi estimate which protection level is
practical on the device being used.

The benchmark runs locally.

---

## 5. `lib/l10n/` — Localization

```text
lib/l10n/
├── app_en.arb
├── app_localizations.dart
└── app_zh_Hant.arb
```

Veilmi currently supports:

```text
English
Traditional Chinese
```

### ARB files

```text
app_en.arb
app_zh_Hant.arb
```

These files contain Veilmi's translated application strings.

### `app_localizations.dart`

This is Veilmi's localization implementation.

It loads the appropriate application strings and makes them available to
the user interface.

For a more detailed explanation, see:

[Localization](localization.md)

---

## 6. `lib/screens/` — User Interface Screens

```text
lib/screens/
├── about_screen.dart
├── device_check_screen.dart
├── home_screen.dart
└── settings_screen.dart
```

These files define the main screens that users interact with.

### `home_screen.dart`

The main Veilmi interface.

This is where users can:

* enter text;
* enter a shared passphrase;
* encrypt a message;
* decrypt a protected message;
* switch between Encrypt and Decrypt modes;
* copy results;
* change the interface language.

### `settings_screen.dart`

Displays application settings, including the selectable protection level.

### `device_check_screen.dart`

Displays the Protection & Device Check interface and benchmark results.

### `about_screen.dart`

Provides project information and links to resources such as:

* the GitHub repository;
* Veilmi documentation;
* the Privacy Policy;
* project support information.

For screenshots and a visual walkthrough of these screens, see:

* [Veilmi Usage Guide](usage-guide.md)
* [Veilmi 使用指南](usage-guide.zh.md)

---

## 7. `lib/settings/` — Application Settings

```text
lib/settings/
└── settings_service.dart
```

This service manages Veilmi application preferences.

Examples include settings that need to remain available while the user
navigates through the application or after the application is restarted.

---


## 8. `test/` — Automated Tests

Veilmi's automated tests are stored under:

```text
test/
├── crypto/
│   ├── crypto_service_test.dart
│   └── message_envelope_test.dart
│
└── widget_test.dart
````

The full test suite can be run with:

```bash
flutter test
```

The current suite contains 22 test cases covering cryptographic behavior,
message-envelope validation, tamper detection, and a basic Flutter UI smoke
test.

### `crypto_service_test.dart`

This file tests the main cryptographic service in:

```text
lib/crypto/crypto_service.dart
```

It checks that Veilmi:

* generates random bytes of the requested length;
* produces different random values across calls;
* can encrypt and decrypt text with AES-GCM;
* derives the same key from the same passphrase and salt;
* can complete an encrypt/decrypt flow using a shared passphrase;
* applies the selected protection level to the PBKDF2 iteration count.

These tests cover both lower-level cryptographic operations and the
passphrase-based workflow used by Veilmi.

### `message_envelope_test.dart`

This file tests the `VEILMI1:` protected-message format and its validation
behavior.

It checks that Veilmi:

* can encode and decode a message envelope without losing its data;
* rejects messages without the `VEILMI1:` prefix;
* can encrypt and decrypt a complete Veilmi protected message;
* rejects an incorrect passphrase;
* detects modified ciphertext;
* detects a modified nonce;
* detects a modified authentication tag;
* produces different encrypted output when the same plaintext is encrypted
  more than once;
* rejects empty or malformed envelope payloads;
* rejects unsupported message versions;
* rejects invalid nonce and authentication-tag lengths;
* rejects unsupported PBKDF2 iteration counts;
* accepts all PBKDF2 iteration counts supported by the current protocol.

These tests are especially important because successful decryption is only
one part of authenticated encryption. Veilmi should also reject protected
messages that have been altered or that do not follow the expected protocol
format.

### `widget_test.dart`

This file contains a basic Flutter widget smoke test.

It starts Veilmi in a Flutter test environment using English as the initial
language and checks that the main interface contains:

```text
Veilmi
Encrypt
Decrypt
```

This provides a simple check that the application can build its main screen
without crashing and that several important interface elements are present.

### What the Test Suite Does Not Mean

Passing the automated test suite does not mean that Veilmi has been
professionally security-audited.

The tests are development checks designed to catch expected failures,
regressions, malformed data, and implementation mistakes.

They complement, rather than replace:

```text
automated tests
        +
physical-device testing
        +
code review
        +
cryptographic review
        ↓
greater confidence in the implementation
```

---

## 9. `assets/` — Application Assets

```text
assets/
└── icon/
```

### Application icons

```text
assets/icon/
├── veilmi_icon.png
└── veilmi_icon_small.png
```

These files contain Veilmi icon assets used by the application and related
project material.

### Application screenshots

```text
docs/assets/app_screenshots/
```

This directory contains English and Traditional Chinese screenshots of the
Veilmi interface.

The screenshots are used for:

* the Veilmi Usage Guide;
* project documentation;
* Google Play Store preparation.

The current screenshot collection contains seven English screenshots and
seven Traditional Chinese screenshots.

---

## 10. `docs/` — Documentation

Veilmi keeps its longer documentation separate from the main README.

```text
docs/
├──assets/
|   └── app_screenshots/
├── README.md
├── usage-guide.md
├── usage-guide.zh.md
├── ....

```

The documentation covers several different parts of the project:

```text
Using Veilmi
    ↓
Usage Guide

Understanding Veilmi
    ↓
Cryptography
Localization
Project structure

Development
    ↓
Flutter environment
GitHub publication
Android device testing

Release
    ↓
Android signing
App Bundle
Privacy Policy
```

The documentation index is available at:

[Veilmi Documentation](README.md)

---

## 11. Platform Directories

Veilmi is currently intended for two mobile platforms:

```text
Android
iOS
````

The corresponding Flutter platform directories are:

```text
android/
ios/
```

### `android/`

Contains Android-specific project files and build configuration.

This includes configuration used for areas such as:

* the Android application ID;
* Android SDK versions;
* Gradle;
* release signing;
* Android App Bundle generation;
* Android platform integration.

Veilmi's Android version is currently the main platform being developed,
tested, and prepared for release.

For more information, see:

* [Android Device Testing](android-device-testing.md)
* [Android Release Signing and App Bundle](android-release-signing.md)

### `ios/`

Contains the iOS-specific Flutter project files and platform integration
required for building Veilmi for Apple devices.

Veilmi is intended to support iOS in addition to Android, but the iOS
release process has not yet been completed.

Future iOS-specific development and release documentation can be added as
that work progresses.

### Other Flutter Platform Directories

The repository also currently contains:

```text
linux/
macos/
web/
windows/
```

These directories were generated as part of the Flutter project structure.

They do **not** currently represent planned Veilmi release platforms.

Veilmi's current platform direction is:

```text
Veilmi
   │
   ├── Android
   │     └── current development and release target
   │
   └── iOS
         └── planned mobile platform
```

The main shared Veilmi application code remains in:

```text
lib/
```

Flutter allows much of this Dart code to be shared between the Android and
iOS versions while keeping platform-specific configuration inside the
corresponding platform directories.


---

## 12. Important Root Files

### `pubspec.yaml`

The main Flutter project configuration file.

It defines information such as:

* application version;
* Dart and Flutter dependencies;
* asset declarations;
* Flutter configuration.

### `pubspec.lock`

Records the exact package versions resolved for the project.

### `analysis_options.yaml`

Controls Dart static-analysis and linting behavior.

Static analysis can be run with:

```bash
flutter analyze
```

### `flutter_launcher_icons.yaml`

Contains configuration used to generate Veilmi launcher icons.

### `LICENSE`

Contains the software license for Veilmi.

### `README.md`

The main English introduction to the Veilmi project.

### `README.zh.md`

The Traditional Chinese version of the main project README.

---

## 13. Development Checks

Three useful commands cover different parts of the development process:

```bash
dart format .
flutter analyze
flutter test
```

Conceptually:

```text
dart format .
     ↓
checks source formatting

flutter analyze
     ↓
checks Dart / Flutter code statically

flutter test
     ↓
runs automated tests
```

They serve different purposes and are commonly run together before committing
important changes.

---

## 14. Simple Mental Model

The repository can be understood like this:

```text
Veilmi
│
├── lib/
│     └── What the application does
│
├── test/
│     └── Checks that important behavior still works
│
├── assets/
│     └── Icons
│
├── docs/
│     └── Explains how Veilmi works and how it was developed
│
├── android/ ios/ ...
│     └── Platform-specific integration
│
└── pubspec.yaml
      └── Flutter project configuration
```

For a general introduction to Veilmi, see the
[main project README](https://github.com/noa-jou/Veilmi).

