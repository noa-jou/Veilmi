# Veilmi

> Encrypt the message before you send it.

[中文 README](README.zh.md)

Veilmi is a free and open-source app for locally encrypting text before sending
it through an existing communication platform.

Instead of asking a messaging service to protect the original message for you,
Veilmi lets you encrypt the text on your own device first.

```text
Your message
     ↓
   Veilmi
     ↓
Encrypted text
     ↓
LINE / Messenger / WhatsApp / email / other channels
     ↓
Encrypted text
     ↓
   Veilmi
     ↓
Original message
```

The communication platform transports the encrypted text, while the plaintext
is handled locally by Veilmi.
---

## Documentation

Veilmi includes documentation for both users and developers.

If you want to see how the app works before reading the technical details,
start with the visual usage guide:

- [Veilmi Usage Guide](docs/usage-guide.md)
- [Veilmi 使用指南](docs/usage-guide.zh.md)

For the complete documentation collection, see:

- [Veilmi Documentation](docs/README.md)

The documentation includes information about:

- how to use Veilmi;
- cryptographic design and current implementation;
- protection levels and future cryptographic direction;
- localization;
- Android device testing;
- Android release signing and App Bundles;
- the Flutter development environment;
- GitHub publication and GitHub Pages;
- the Privacy Policy.

---

## Why I Built Veilmi

Private conversations between family, friends, and people we trust should
belong to the people having those conversations.

Many of us communicate through large messaging platforms every day. Some of
these services already provide strong encryption, while others may provide
different levels of protection depending on the feature or configuration.

I do not want the privacy of my conversations to depend entirely on the
platform carrying them.

The idea behind Veilmi is simple:

> **Protect the message yourself before handing it to the communication
> platform.**

Veilmi is not intended to replace messaging apps. It is a small tool that works
alongside them.

Users agree on a shared passphrase separately, encrypt text locally, and then
copy the encrypted message into whatever communication channel they choose.

Veilmi protects message content, but it does not hide information such as who is
communicating with whom, when messages are sent, or how often people communicate.

It also cannot protect a compromised phone or make a weak passphrase strong.

 It is intended to give users another layer of control
over the content of their conversations only.

---

## Cryptographic Design

Veilmi does not depend on keeping its source code or encryption method secret.

The project is open source so that its design can be inspected, questioned,
tested, and improved.

If you are interested in how Veilmi currently works, start here:

- [`docs/crypto-notes.md`](docs/crypto-notes.md) — a beginner-friendly
  explanation of the current encryption and decryption process.
- [`docs/crypto-design-and-future.md`](docs/crypto-design-and-future.md) —
  why the current cryptographic technologies were chosen, the standards and
  guidance behind them, their limitations, and possible future improvements.

More development, testing, release, and project documentation can be found in
the [Veilmi Documentation](https://noa-jou.github.io/Veilmi/).

---

## Current Cryptography

Veilmi1 currently uses:

- AES-256-GCM for authenticated encryption;
- PBKDF2-HMAC-SHA256 for passphrase-based key derivation;
- random salts and nonces;
- versioned encrypted-message envelopes;
- selectable PBKDF2 protection levels.

The details and reasoning are documented in the files above.

Veilmi is still under development and has **not undergone an independent
professional security audit**.

Please do not treat it as a formally audited security product.

---

## A Learning Project

Veilmi is my first app built with Flutter, but it is not my first experience
with software development.

I have around four years of professional software-engineering experience.

About six years before starting Veilmi, I also studied some basic programming
and mobile-development courses at **LCCNET (聯成電腦)**. During those courses,
I was guided through building my first small Android app using **Java and
Android Studio**.

That was a small beginning, and I did not come into Veilmi already knowing
Flutter or modern cross-platform mobile development.

I started Veilmi mainly with an idea, the general software-engineering
knowledge I had accumulated through work, some older programming foundations,
and a willingness to learn what I did not know.

AI tools have also been part of that learning and development process.

Veilmi has been built with assistance from:

- ChatGPT
- GitHub Copilot
- Gemini

I use these tools to help me understand unfamiliar technologies, discuss
implementation choices, review code, write tests and documentation, and turn
ideas into something I can actually test.

The original idea, product decisions, testing, review, and responsibility for
what I publish remain mine.

Veilmi is carefully made, but it is also part of my learning process.

Those two things can be true at the same time.

---

## Found a Problem?

If you find a bug, incorrect documentation, interoperability problem, or a
security weakness, please tell me.

You are also welcome to disclose security findings publicly, including
technical details.

I would rather know that a weakness exists — and let users know that it exists
— than hide it because it is embarrassing.

I may not have the knowledge or time to fix every problem immediately, but
knowing about a problem is still valuable.

This is a learning project, and constructive criticism is part of that
process.

If you find something wrong, you are welcome to report it publicly through the
GitHub repository.

---

## How to report an issue

1. Open this repository on GitHub.
2. Click **Issues** near the top of the repository.
3. Click **New issue**.
4. Give the issue a short, clear title.
5. Describe what you found.
6. Click **Submit new issue**.

A useful report can include:

- what you expected to happen;
- what actually happened;
- the steps that caused the problem;
- your phone model and Android/iOS version, if relevant;
- screenshots or error messages, if available.

For example:

```text
Title:
Decrypt button stays disabled after entering a message

Description:
I expected the Decrypt button to become available after entering
an encrypted message and passphrase.

Steps:
1. Open Veilmi.
2. Switch to Decrypt.
3. Paste an encrypted message.
4. Enter the passphrase.

Result:
The button remains disabled.

Device:
Android 14
```

--

## Support My Work

I enjoy building independent apps and projects that I genuinely care about.

My goal is to keep creating useful and interesting things and, eventually, to
make a living from my own work.

If Veilmi is useful to you and you would like to support what I build, you can
buy me a coffee:

**☕ [Buy Me a Coffee](https://buymeacoffee.com/noajou)**

Support is completely optional and does not unlock additional Veilmi features.


---

## License

Copyright © 2026 Shin Jou (Noa)

Veilmi is licensed under the
[GNU General Public License v3.0](LICENSE).

You are free to use, study, modify, and redistribute the software under the
terms of the GPLv3.