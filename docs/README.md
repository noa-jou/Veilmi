<p align="center">
  <img src="assets/icon/veilmi_icon_small.png"
       width="100"
       height="100"
       alt="Veilmi icon">
</p>

# Veilmi Documentation

Welcome to the Veilmi documentation.

This documentation explains how to use Veilmi, how its cryptographic
design works, and how the application is developed, tested, and prepared
for release.

---

## 1. Using Veilmi

### [Veilmi Usage Guide](usage-guide.md)

A visual walkthrough of Veilmi's main screens and basic workflow,
including encryption, decryption, protection levels, and Device Check.

Traditional Chinese version:

[Veilmi 使用指南](usage-guide.zh.md)

---

## 2. Project Structure and Development Environment

This section explains how the Veilmi repository is organized and records
the tools and environment used to build and maintain the project.

### [Project Structure](project-structure.md)

An overview of the Veilmi repository, including:

- the main Dart source code under `lib/`;
- cryptographic and application services;
- UI screens;
- localization files;
- automated tests;
- assets and screenshots;
- documentation;
- Android and iOS platform directories;
- important Flutter project files.

### [Chromebook Flutter Environment](chromebook-flutter-environment.md)

A beginner-friendly record of the development environment used for
Veilmi.

It explains how to configure a Chromebook Linux environment so Flutter,
Dart, Java, the Android SDK, and ADB can be used from the terminal.

### [GitHub Publication and GitHub Pages](github-publication-and-pages.md)

A beginner-friendly guide to preparing Veilmi for public development on
GitHub and publishing its documentation with GitHub Pages.

It covers:

- checking a repository for secrets and personal information;
- changing repository visibility;
- publishing the `docs/` directory with GitHub Pages;
- using Jekyll front matter and permalinks;
- creating clean documentation URLs;
- managing GitHub Pages deployment notifications.

---

## 3. Veilmi Design and Application

This section explains how Veilmi works internally and records important
design decisions.

### [Cryptography Notes](crypto-notes.md)

A beginner-friendly explanation of how Veilmi currently encrypts and
decrypts messages.

It covers concepts such as:

- shared passphrases;
- PBKDF2;
- salt;
- nonce;
- AES-256-GCM;
- authentication tags;
- the Veilmi message envelope.

### [Cryptographic Design and Future Direction](crypto-design-and-future.md)

A higher-level explanation of Veilmi's cryptographic design choices.

It records the reasoning behind the current protection levels, important
security trade-offs, and possible future directions such as Argon2id.

### [Localization](localization.md)

An explanation of Veilmi's current localization system.

It describes:

- English and Traditional Chinese support;
- how the selected language is stored;
- how language switching works at runtime;
- how Veilmi-specific strings are loaded;
- how Flutter framework text uses the same locale;
- how new translations can be added.

---

## 4. Android Development and Release

This section documents how Veilmi is tested, prepared, and gradually
published on Android.

### [Android Device Testing](android-device-testing.md)

A practical guide to testing Veilmi on a real Android phone.

It explains how to:

- enable Developer options;
- enable USB debugging;
- connect an Android phone to Flutter;
- use ADB (Android Debug Bridge);
- run Veilmi on a physical device;
- troubleshoot device detection problems.

### [Android Release Signing and App Bundle](android-release-signing.md)

A beginner-friendly explanation of preparing Veilmi for an Android
release.

It covers the complete release build path, including:

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

It also records the commands and configuration used to create Veilmi's
signed Android App Bundle for Google Play.

### [Google Play Screenshot Preparation](google-play-screenshot-preparation.md)

A short practical record of preparing Veilmi screenshots for Google Play.

It explains how the English and Traditional Chinese screenshots were:

- captured from a real Android test device;
- cropped and resized;
- checked with a Bash script for the required image dimensions and
  aspect ratio;
- reused to create the Veilmi Usage Guide.

### [Google Play Release Process](google-play-release-process.md)

A first-time developer's practical record of preparing Veilmi for
publication through Google Play Console.

Rather than describing the entire release process in advance, this document
is updated stage by stage as each part is completed.

It currently covers:

- creating the developer account;
- developer and project identity;
- Google Play identity verification;
- the relationship between the developer identity and the Android
  Application ID.

Later stages will be added as the Google Play release process continues.

---

## 5. Privacy

### [Privacy Policy](privacy-policy.md)

The public Privacy Policy for Veilmi.

It explains how Veilmi handles:

- messages and shared passphrases;
- application preferences;
- clipboard data;
- network use;
- external links;
- data retention and deletion.

Veilmi performs its encryption and decryption locally and does not require
a Veilmi account or developer-operated messaging server.

Traditional Chinese version:

[隱私權政策](privacy-policy.zh.md)

---

For a general introduction, source code, and project overview, visit the
[Veilmi GitHub repository](https://github.com/noa-jou/Veilmi).