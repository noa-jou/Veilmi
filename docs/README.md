# Veilmi Documentation

This folder contains the main developer notes, technical documentation, setup
guides, and public project information for Veilmi.


## 1. Development Environment

This section focuses on the development machine itself rather than on Veilmi's
application logic.

### [chromebook-flutter-environment.md](chromebook-flutter-environment.md)

A beginner-friendly record of the development environment currently used for
Veilmi.

It explains how to configure a Chromebook Linux environment so Flutter, Dart,
Java, the Android SDK, and ADB can be used from the terminal.

### [github-publication-and-pages.md](github-publication-and-pages.md)

A beginner-friendly guide to preparing Veilmi for public development on GitHub
and publishing its documentation with GitHub Pages.

It records how to check a repository for secrets and personal information
before making it public, change the repository visibility, publish the `docs/`
folder with GitHub Pages, create clean documentation URLs with Jekyll front
matter and permalinks, and manage Pages deployment notifications.

---

## 2. Veilmi Design and Application

### [crypto-notes.md](crypto-notes.md)

A beginner-friendly explanation of how Veilmi currently encrypts and decrypts
messages.

It covers concepts such as:

- shared passphrases;
- PBKDF2;
- salt;
- nonce;
- AES-256-GCM;
- authentication tags;
- the Veilmi message envelope.

### [crypto-design-and-future.md](crypto-design-and-future.md)

A higher-level explanation of Veilmi's cryptographic design choices.

It records the reasoning behind the current protection levels, important
security trade-offs, and possible future directions such as Argon2id.

### [localization.md](localization.md)

An explanation of Veilmi's current localization system.

It describes:

- English and Traditional Chinese support;
- how the selected language is stored;
- how language switching works at runtime;
- how Veilmi-specific strings are loaded;
- how Flutter framework text uses the same locale;
- how new translations can be added.

---

## 3. Android Development and Release

### [android-device-testing.md](android-device-testing.md)

A practical guide to testing Veilmi on a real Android phone.

It explains how to:

- enable Developer options;
- enable USB debugging;
- connect an Android phone to Flutter;
- use ADB (Android Debug Bridge);
- run Veilmi on a physical device;
- troubleshoot device detection problems.

### [android-release-signing.md](android-release-signing.md)

A beginner-friendly explanation of preparing Veilmi for an Android release.

It covers the complete release path, including:

- debug builds and release builds;
- Android application signing;
- upload keys;
- Java keystores (`.jks`);
- `key.properties`;
- Gradle;
- `build.gradle.kts`;
- Android App Bundles (`.aab`);
- Google Play App Signing;
- version numbers;
- private release files and backups.

It also records the commands and configuration used to create Veilmi's signed
Android App Bundle for Google Play.

---

## Privacy

### [privacy-policy.md](privacy-policy.md)

The public Privacy Policy for Veilmi.

It explains how Veilmi handles:

- messages and shared passphrases;
- application preferences;
- clipboard data;
- network use;
- external links;
- data retention and deletion.

Veilmi performs its encryption and decryption locally and does not require a
Veilmi account or developer-operated messaging server.

---

For a general introduction, source code, and project overview, visit the
[Veilmi GitHub repository](https://github.com/noa-jou/Veilmi).