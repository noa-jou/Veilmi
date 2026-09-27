# Android Physical Device Testing

This guide explains how to run and test Veilmi on a physical Android phone
after the local Android build environment is already working.

The expected starting point is:

```bash
flutter build apk --debug
```

finishing successfully.

For example:

```text
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

A successful Debug APK build means the local Flutter / Dart / Java / Gradle /
Android SDK build environment is working.

Physical-device testing is a separate layer:

```text
Veilmi builds locally
        ↓
Linux USB permissions
        ↓
ADB can access the phone
        ↓
Android authorizes the computer
        ↓
Flutter detects the phone
        ↓
flutter run
```

If the APK already builds successfully but the phone cannot be used, do not
immediately change:

```text
Veilmi source code
Gradle
Kotlin
Flutter
Android SDK versions
```

First diagnose the physical-device connection.

---

## Prepare the Linux Computer

This setup is normally needed once on a new Debian / Chromebook Linux
development environment.

### Install Debian's Android USB Rules

Install:

```bash
sudo apt-get update
sudo apt-get install -y android-sdk-platform-tools-common
```

This installs Debian's Android USB / udev support.

Check that the packaged rule exists:

```bash
ls -l /lib/udev/rules.d/51-android.rules
```

A normal result should point to:

```text
/lib/udev/rules.d/51-android.rules
```

Do **not** manually create or download:

```text
/etc/udev/rules.d/51-android.rules
```

Debian already provides the Android udev rules through
`android-sdk-platform-tools-common`.

A manually created file under `/etc/udev/rules.d/` may override Debian's
packaged rule.

---

### Make Sure the `plugdev` Group Exists

Check:

```bash
getent group plugdev
```

A result may look similar to:

```text
plugdev:x:46:
```

or:

```text
plugdev:x:46:USERNAME
```

If the command produces no output at all, create the group:

```bash
sudo groupadd plugdev
```

---

### Add the Current User to `plugdev`

Add the current Linux user:

```bash
sudo usermod -aG plugdev "$USER"
```

Check the saved system membership:

```bash
getent group plugdev
```

The current username should now appear.

For example:

```text
plugdev:x:46:USERNAME
```

There is an important difference between these two commands:

```bash
getent group plugdev
```

checks the saved system group membership.

```bash
groups
```

shows the groups that are active in the current shell.

Check the current shell:

```bash
groups
```

If `plugdev` is missing even though `getent group plugdev` already lists the
username, activate the new group membership:

```bash
newgrp plugdev
```

Then check again:

```bash
groups
```

The result should now include:

```text
plugdev
```

`newgrp plugdev` starts a shell with that group active.

When finished with that shell, `exit` returns to the previous shell.

---

### Reload the udev Rules

Reload the installed rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

If the Android phone was already connected, unplug it after this step.

The computer-side preparation is now complete.

---

## Prepare the Android Phone

The phone also needs to allow development access.

### Enable Developer Options

On the Android phone, open:

```text
Settings
```

A common path is:

```text
About phone
→ Build number
```

Tap:

```text
Build number
```

seven times.

The phone may ask for the screen-lock PIN, password, or pattern.

After Developer options are enabled, Android normally shows a message similar
to:

```text
You are now a developer!
```

The exact menu names may vary depending on the Android manufacturer and version.

---

### Enable USB Debugging

Open:

```text
Developer options
```

Find:

```text
USB debugging
```

and enable it.

Confirm Android's warning.

USB debugging allows ADB to:

```text
detect the phone
install Veilmi debug builds
launch Veilmi
read development logs
communicate with Flutter
```

Only authorize computers that are trusted.

---

## Connect the Phone

Use a USB cable that supports **data transfer**.

A charging-only cable cannot be used for ADB.

Connect the phone to the Chromebook or development computer.

Then:

1. Unlock the phone.
2. Keep the phone unlocked while establishing the connection.
3. If Android displays a USB notification, select a data-transfer mode.

Common options include:

```text
File Transfer
```

or:

```text
Transferring files / Android Auto
```

Do not leave the phone in charging-only mode if ADB cannot detect it.

---

### ChromeOS USB Access

On a Chromebook, ChromeOS may ask whether the USB device should be made
available to Linux.

Allow the Android phone to be shared with the Linux development environment.

If ChromeOS does not pass the USB device to Linux, ADB inside Linux cannot use
the phone.

---

## Check the USB Connection at the Linux Level

Run:

```bash
lsusb
```

If Linux can see the phone, it should appear somewhere in the USB device list.

The exact vendor and product IDs depend on the phone.

### If the Phone Appears in `lsusb`

This means:

```text
physical USB connection
        ✓
Linux can see the USB device
        ✓
```

Continue to ADB.

### If the Phone Does Not Appear in `lsusb`

Check:

```text
USB cable
USB port
ChromeOS USB sharing
Android USB mode
phone lock state
```

Changing Veilmi source code will not fix this type of problem.

---

## Check ADB

Run:

```bash
adb devices
```

A fully working connection looks similar to:

```text
List of devices attached
DEVICE_ID    device
```

Use a placeholder such as:

```text
DEVICE_ID
```

in public documentation instead of publishing a personal phone serial number.

The result from `adb devices` is diagnostic information.

The important states are:

| ADB result | Meaning | Next action |
| --- | --- | --- |
| `DEVICE_ID    device` | Linux permission and Android authorization are working | Continue to `flutter devices` |
| `DEVICE_ID    unauthorized` | Linux can access the phone, but Android has not authorized this computer | Approve the USB debugging prompt on the phone |
| `DEVICE_ID    no permissions` | Linux sees the phone, but the current Linux user cannot access it | Check `plugdev` and udev rules |
| Nothing below `List of devices attached` | ADB cannot currently see the phone | Check USB, ChromeOS sharing, USB debugging, and ADB |

Do not treat all four results as the same problem.

---

## If ADB Reports `unauthorized`

Example:

```text
DEVICE_ID    unauthorized
```

This means:

```text
Linux can see the phone
        ✓
ADB can reach the phone
        ✓
Android authorization
        ✗
```

Unlock the phone.

Android should display:

```text
Allow USB debugging?
```

The dialog may also display the RSA fingerprint of the development computer.

For your own trusted development computer, you may select:

```text
Always allow from this computer
```

and then tap:

```text
Allow
```

Check again:

```bash
adb devices
```

The expected result is:

```text
DEVICE_ID    device
```

---

### If the Authorization Dialog Does Not Appear

Disconnect and reconnect the USB cable.

Keep the phone unlocked.

If necessary, open Android Developer options and use:

```text
Revoke USB debugging authorizations
```

Then reconnect the phone.

Android should ask again:

```text
Allow USB debugging?
```

Authorize only a trusted computer.

---

## If ADB Reports `no permissions`

Example:

```text
DEVICE_ID    no permissions
```

This is a **Linux USB permission problem**.

It is different from:

```text
unauthorized
```

`unauthorized` means Android has not trusted the computer.

`no permissions` means Linux can see the phone, but the current Linux user
cannot access the USB device correctly.

---

### Check the Active Groups

Run:

```bash
groups
```

The output should include:

```text
plugdev
```

If it does not, check the saved group membership:

```bash
getent group plugdev
```

If the username appears in `getent group plugdev` but not in `groups`, activate
the membership:

```bash
newgrp plugdev
```

Check again:

```bash
groups
```

---

### Check the Debian Android Rules

Make sure the package is installed:

```bash
sudo apt-get install -y android-sdk-platform-tools-common
```

Check:

```bash
ls -l /lib/udev/rules.d/51-android.rules
```

The packaged Android rule should exist there.

Reload the rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Now unplug the Android phone and reconnect it.

---

### Restart ADB

Run:

```bash
adb kill-server
adb start-server
adb devices
```

A successful result should eventually become:

```text
DEVICE_ID    device
```

or possibly:

```text
DEVICE_ID    unauthorized
```

If it becomes `unauthorized`, approve the debugging prompt on the phone.

Do not change Flutter, Gradle, Kotlin, Android SDK versions, or Veilmi source
code to solve:

```text
no permissions
```

---

## Check for an Accidental Local udev Override

Normally, this file should not be manually created:

```text
/etc/udev/rules.d/51-android.rules
```

If `no permissions` continues even though Debian's packaged rules are installed,
check whether a local override exists:

```bash
ls -l /etc/udev/rules.d/51-android.rules 2>/dev/null
```

If the file exists, inspect it:

```bash
head -n 10 /etc/udev/rules.d/51-android.rules
```

Do not blindly delete a legitimate custom rule.

However, if the file is clearly an accidental or invalid download, for example:

```text
404: Not Found
```

remove it:

```bash
sudo rm -f /etc/udev/rules.d/51-android.rules
```

Then reload the valid Debian rules:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Unplug and reconnect the phone.

Restart ADB:

```bash
adb kill-server
adb start-server
adb devices
```

---

## If `adb devices` Shows Nothing

Example:

```text
List of devices attached
```

with nothing underneath.

This means ADB cannot currently see an Android debugging device.

Check in this order:

```text
USB cable supports data
        ↓
phone is unlocked
        ↓
Developer options enabled
        ↓
USB debugging enabled
        ↓
USB mode allows data
        ↓
ChromeOS shares USB device with Linux
        ↓
lsusb
        ↓
ADB
```

Restart ADB:

```bash
adb kill-server
adb start-server
adb devices
```

If:

```bash
lsusb
```

shows the phone but:

```bash
adb devices
```

remains empty, the physical USB connection exists and the problem is higher in
the Android debugging / ADB layer.

---

## Check Whether Flutter Can See the Phone

Do not move to Flutter until:

```bash
adb devices
```

shows:

```text
DEVICE_ID    device
```

Then run:

```bash
flutter devices
```

Flutter should list the Android phone.

Example:

```text
Android Phone • DEVICE_ID • android-arm64 • Android ...
```

If ADB reports:

```text
device
```

but Flutter still does not list the phone, then investigate the Flutter /
Android SDK configuration.

If ADB does not report `device`, fix the ADB connection first.

---

## Run Veilmi on the Phone

Use the device ID shown by:

```bash
flutter devices
```

Run:

```bash
flutter run -d DEVICE_ID
```

For example, if Flutter prints:

```text
Android Phone • ABC123XYZ • android-arm64 • Android ...
```

run:

```bash
flutter run -d ABC123XYZ
```

Using the exact device ID avoids accidentally selecting another runtime target.

---

## Normal Physical-Device Testing Workflow

After the computer and phone have already been prepared, a normal development
session is much shorter.

Run:

```bash
flutter analyze
flutter test
adb devices
flutter devices
flutter run -d DEVICE_ID
```

The flow is:

```text
Static analysis
        ↓
Automated tests
        ↓
ADB connection
        ↓
Flutter device detection
        ↓
Physical-device test
```

The Debian udev and `plugdev` setup normally does not need to be repeated every
time.

---

## Troubleshooting Decision Tree

Use this order:

```text
flutter build apk --debug
        ↓
build succeeds
        ↓
connect Android phone
        ↓
lsusb
        ↓
adb devices
        ↓
 ┌─────────────────────┬──────────────────────┬────────────────────────┬─────────────────────┐
 │ device              │ unauthorized         │ no permissions         │ nothing listed      │
 │                     │                      │                        │                     │
 │ continue            │ approve phone RSA    │ plugdev / udev rules   │ USB / ChromeOS /    │
 │                     │ prompt               │                        │ debugging / ADB     │
 └─────────────────────┴──────────────────────┴────────────────────────┴─────────────────────┘
        ↓
flutter devices
        ↓
flutter run -d DEVICE_ID
```

The key distinction is:

```text
flutter build apk --debug
→ Can this computer build Veilmi?

adb devices
→ Can Linux communicate with the Android phone?

flutter devices
→ Can Flutter use the phone as a runtime target?

flutter run
→ Can Veilmi be installed and launched on that target?
```

These are separate checks.

---

## What Not to Change First

If the Debug APK already builds successfully but the physical device is not
working, do not immediately modify:

```text
Gradle versions
Kotlin versions
Android SDK versions
Flutter configuration
Veilmi source code
```

A USB permission or authorization problem exists outside the Veilmi application
itself.

---

## Security Considerations

USB debugging gives an authorized development computer significant access to
the Android phone.

During development:

- only authorize computers you trust;
- do not approve unknown RSA fingerprints;
- revoke old USB debugging authorizations when appropriate;
- disable USB debugging when it is no longer needed.

