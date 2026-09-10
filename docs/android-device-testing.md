
# Android Physical Device Testing

This guide explains how to prepare a physical Android phone for Veilmi
development, enable Developer options and USB debugging, connect the phone to
the development environment, and troubleshoot common ADB connection problems.

The examples in this guide assume Veilmi is being developed with Flutter on a
Linux environment.

---

## 1. Why Developer Mode Is Required

Android phones normally do not allow development tools to directly install and
debug applications.

To run Veilmi from Flutter on a physical phone, the development computer needs
to communicate with the device through Android Debug Bridge (ADB).

The connection works roughly like this:

```text
Flutter
   ↓
Android SDK
   ↓
ADB (Android Debug Bridge)
   ↓
USB connection
   ↓
Android phone
````

Before ADB can communicate with the phone, Android Developer options and USB
debugging must be enabled.

---

## 2. Enable Developer Options

Open the phone's Settings app and go to:

```text
About phone
```

Find:

```text
Build number
```

and tap it seven times.

The phone may ask for the screen-lock PIN, password, or pattern.

After Developer options are enabled, Android usually displays a message similar
to:

```text
You are now a developer!
```

Return to Settings and search for:

```text
Developer options
```

The exact menu location may vary depending on the Android manufacturer and
version.

---

## 3. Enable USB Debugging

Open:

```text
Developer options
```

Find:

```text
USB debugging
```

and enable it.

Android may display a warning explaining that USB debugging allows the phone to
communicate with development computers.

Confirm the warning.

USB debugging allows ADB to:

* detect the Android phone;
* install Veilmi debug builds;
* launch the application;
* display development logs;
* communicate with Flutter development tools.

Only enable USB debugging for development and only authorize computers that you
trust.

---

## 4. Connect the Phone by USB

Connect the Android phone to the Chromebook or development computer using a USB
cable.

The cable must support data transfer.

Some USB cables support charging only and cannot be used for ADB.

After connecting the phone:

1. Unlock the phone.
2. Open the Android USB notification.
3. Select a data-transfer mode.

Common options include:

```text
File Transfer
```

or:

```text
Transferring files / Android Auto
```

Avoid leaving the phone in charging-only mode if ADB cannot detect it.

---

## 5. Authorize the Development Computer

The first time an Android device connects to a development computer through
ADB, Android normally displays a dialog similar to:

```text
Allow USB debugging?
```

The dialog may also show the RSA fingerprint of the development computer.

If this is your own trusted development machine, you may select:

```text
Always allow from this computer
```

and then tap:

```text
Allow
```

If the phone does not authorize the computer, ADB may report the device as:

```text
unauthorized
```

---

## 6. Check the ADB Connection

In the current Veilmi development environment, ADB is located at:

```text
~/Android/Sdk/platform-tools/adb
```

Run:

```bash
~/Android/Sdk/platform-tools/adb devices
```

A successful connection looks similar to:

```text
List of devices attached
DEVICE_ID    device
```

The exact device ID is different for each phone.

For project documentation, use a placeholder such as:

```text
DEVICE_ID
```

instead of publishing a personal device serial number.

---

## 7. Understand ADB Device States

ADB can report several different states.

### Connected

```text
DEVICE_ID    device
```

This means:

* the USB connection is working;
* USB debugging is enabled;
* authorization succeeded;
* ADB can communicate with the phone.

### Unauthorized

```text
DEVICE_ID    unauthorized
```

This means the development computer can see the phone, but Android has not
authorized the ADB connection.

To fix it:

1. Unlock the phone.
2. Look for the "Allow USB debugging?" dialog.
3. Approve the connection.

If the dialog does not appear, disconnect and reconnect the USB cable.

### No device listed

```text
List of devices attached
```

with nothing underneath means ADB cannot currently see the phone.

Possible causes include:

* the USB cable is disconnected;
* the cable supports charging only;
* USB debugging is disabled;
* the phone is locked;
* the USB mode changed;
* the USB connection to Linux was lost;
* the ADB server stopped responding.

---

## 8. Restart ADB (Android Debug Bridge)

If the phone previously worked but suddenly disappears, restart the ADB server.

Run:

```bash
~/Android/Sdk/platform-tools/adb kill-server
~/Android/Sdk/platform-tools/adb start-server
~/Android/Sdk/platform-tools/adb devices
```

A successful restart may look like:

```text
* daemon not running; starting now at tcp:5037
* daemon started successfully
List of devices attached
DEVICE_ID    device
```

This is a useful first troubleshooting step before changing Flutter or Android
project settings.

---

## 9. Check Whether Flutter Can See the Device

Once ADB reports:

```text
DEVICE_ID    device
```

run:

```bash
flutter devices
```

Flutter should list the Android phone.

Example:

```text
Android Phone • DEVICE_ID • android-arm64 • Android 11
```

If ADB can see the phone but Flutter cannot, then investigate the Flutter or
Android SDK configuration.

If ADB cannot see the phone, fix the USB or ADB connection first.

---

## 10. Run Veilmi on the Android Device

Once the device appears in Flutter, run:

```bash
flutter run -d DEVICE_ID
```

Replace `DEVICE_ID` with the identifier shown by:

```bash
flutter devices
```

or:

```bash
~/Android/Sdk/platform-tools/adb devices
```

Flutter will then:

```text
Compile Veilmi
    ↓
Build the Android debug APK
    ↓
Install the APK through ADB
    ↓
Launch Veilmi on the phone
```

---

## 11. Recommended Testing Workflow

A normal physical-device testing session can follow this sequence:

```bash
flutter analyze
flutter test
~/Android/Sdk/platform-tools/adb devices
flutter devices
flutter run -d DEVICE_ID
```

This gives the following workflow:

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

---

## 12. If Flutter Cannot Find the Device

Flutter may display an error such as:

```text
No supported devices found with name or id matching 'DEVICE_ID'.
```

Do not immediately assume there is a problem with Veilmi.

First check ADB:

```bash
~/Android/Sdk/platform-tools/adb devices
```

If the device list is empty, restart ADB:

```bash
~/Android/Sdk/platform-tools/adb kill-server
~/Android/Sdk/platform-tools/adb start-server
~/Android/Sdk/platform-tools/adb devices
```

Then check Flutter again:

```bash
flutter devices
```

If the phone appears again, retry:

```bash
flutter run -d DEVICE_ID
```

---

## 13. Check the USB Connection at the Linux Level

If ADB still cannot see the phone, run:

```bash
lsusb
```

This helps determine whether Linux can see the USB device at all.

### Phone appears in `lsusb`

```text
Linux
  ✓ sees phone

ADB
  ✗ does not see phone
```

The physical USB connection exists.

Investigate:

* USB debugging;
* ADB authorization;
* Android USB mode;
* the ADB server.

### Phone does not appear in `lsusb`

```text
Linux
  ✗ does not see phone

ADB
  ✗ cannot see phone
```

Investigate:

* USB cable;
* USB port;
* ChromeOS USB access;
* Android USB connection mode.

Changing Veilmi application code will not fix this type of problem.

---

## 14. Re-authorize USB Debugging

If ADB repeatedly reports:

```text
unauthorized
```

Developer options usually contain an option similar to:

```text
Revoke USB debugging authorizations
```

Revoke the existing authorization and reconnect the phone.

Android should then display:

```text
Allow USB debugging?
```

again.

Only authorize trusted development computers.

---

## 15. Security Considerations

USB debugging gives a trusted development computer significant access to the
Android phone.

During development:

* only authorize computers you trust;
* do not approve unknown RSA fingerprints;
* revoke old USB debugging authorizations when necessary;
* disable USB debugging when it is no longer needed.

Veilmi encryption secrets have never been placed in source code or committed to Git.

This includes:

* shared passphrases;
* derived encryption keys;
* signing secrets;
* API secrets.

---

## 16. Troubleshooting Order

If Veilmi previously worked on the same Android phone but Flutter suddenly stops
detecting it, check the connection in this order:

```text
USB cable
   ↓
Android USB mode
   ↓
Developer options
   ↓
USB debugging
   ↓
ADB authorization
   ↓
adb devices
   ↓
flutter devices
   ↓
Flutter / Android project configuration
```

Do not immediately modify:

* Gradle versions;
* Kotlin versions;
* Android SDK versions;
* Flutter configuration;
* Veilmi application code.

A temporary USB or ADB disconnect can produce a Flutter device-not-found error
even when the application itself is working correctly.
