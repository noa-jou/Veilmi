# Veilmi Usage Guide

[中文](usage-guide.zh.md)

This page provides a visual walkthrough of Veilmi's main screens and core workflow.

## 1. Protect a Message

Enter the message you want to protect and the shared passphrase.

<p align="center">
  <img src="assets/app_screenshots/1_eeb.jpg"
       width="300"
       alt="Veilmi Protect a Message screen">
</p>

## 2. Create a Protected Message

Tap **Encrypt Message** to encrypt the plaintext locally.

Veilmi replaces the plaintext with a `VEILMI1:XXXXXX` protected message.

The result can then be copied and sent through another communication tool.

<p align="center">
  <img src="assets/app_screenshots/2_eea.jpg"
       width="300"
       alt="Veilmi protected message">
</p>

## 3. Open a Protected Message

The recipient can paste the `VEILMI1:XXXXXX` protected message into Veilmi's
**Decrypt** mode and enter the shared passphrase.

<p align="center">
  <img src="assets/app_screenshots/3_edb.jpg"
       width="300"
       alt="Veilmi Open a Protected Message screen">
</p>

## 4. Recover the Original Message

Tap **Decrypt Message** to decrypt the protected message locally.

If the protected message and passphrase are valid, Veilmi displays the
original plaintext.

<p align="center">
  <img src="assets/app_screenshots/4_eda.jpg"
       width="300"
       alt="Veilmi decrypted message">
</p>

## 5. Adjust Protection Levels

### If encryption or decryption takes too long

Tap the **gear icon** in the top-right corner to open the Settings page.

<p align="center">
  <img src="assets/app_screenshots/5_esl.jpg"
       width="300"
       alt="Veilmi Protection Level settings">
</p>

Before changing the protection level, you can learn more about it in
**Protection & Device Check**.

You can also visit **About Veilmi** to find more information and documentation
about the app.

## 6. Protection & Device Check

**Device Check** benchmarks Veilmi's protection levels on the current device
and helps you choose a practical balance between protection and performance.

The benchmark runs locally on the device.

<p align="center">
  <img src="assets/app_screenshots/6_epc.jpg"
       width="300"
       alt="Veilmi Protection and Device Check screen">
</p>

## 7. About Veilmi

The **About Veilmi** page provides direct access to project information,
including:

- the open-source GitHub repository
- Veilmi documentation
- the Privacy Policy
- project support information

<p align="center">
  <img src="assets/app_screenshots/7_eab.jpg"
       width="300"
       alt="About Veilmi screen">
</p>

---

For technical details about Veilmi's cryptographic design, threat model,
localization, Android testing, and release process, etc. See the
[Veilmi documentation website](https://noa-jou.github.io/Veilmi/).