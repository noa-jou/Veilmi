# Veilmi Documentation

This folder contains the main developer notes, technical documentation, setup
guides, and public project information for Veilmi.

The documents are organized to help a beginner understand the project in a
natural order.

## Development and Technical Documentation

1. [android-device-testing.md](android-device-testing.md)

   Learn how to connect a real Android phone to Flutter, enable Developer
   options, turn on USB debugging, and troubleshoot device detection problems.

2. [chromebook-flutter-environment.md](chromebook-flutter-environment.md)

   Learn how to configure a Chromebook Linux environment so Flutter, Dart,
   Java, Android SDK, and ADB can be used from the terminal.

3. [crypto-notes.md](crypto-notes.md)

   A beginner-friendly explanation of how Veilmi encrypts and decrypts
   messages, including PBKDF2, salt, nonce, AES-GCM, and the message envelope.

4. [crypto-design-and-future.md](crypto-design-and-future.md)

   A higher-level explanation of the cryptographic design choices, current
   trade-offs, and possible future direction such as Argon2id.

5. [localization.md](localization.md)

   Learn how Veilmi supports English and Traditional Chinese, how the selected
   language is stored and restored, how runtime language switching works, and
   how new translated strings can be added.

## Privacy

6. [privacy-policy.md](privacy-policy.md)

   The public Privacy Policy for Veilmi. It explains how messages,
   passphrases, application preferences, clipboard data, external links, and
   other information are handled.

   Veilmi performs its encryption and decryption locally and does not require
   a Veilmi account or developer-operated messaging server.

---

For a general introduction to the project, see the
[main Veilmi README](../README.md).