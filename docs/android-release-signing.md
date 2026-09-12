# Android Release Signing and App Bundle

This document is a beginner-friendly explanation of the Android release process
used by Veilmi.

It explains:

- what a debug build and a release build are;
- why Android apps need digital signing;
- what an upload key and keystore are;
- how Veilmi's upload key was created;
- what `key.properties` does;
- what Gradle does;
- how Gradle uses the signing configuration;
- what an Android App Bundle (`.aab`) is;
- which release files must remain private;
- what should be backed up for future Veilmi releases.

The goal is not only to record the commands, but also to explain why each step
exists.

---

## 1. Debug Build vs Release Build

During development, Flutter usually runs Veilmi as a **debug build**.

For example:

```bash
flutter run
```

A debug build is intended for development.

It includes tools that help developers test and inspect the application.

A Play Store release should instead use a **release build**.

For Veilmi, the release bundle is created with:

```bash
flutter build appbundle --release
```

Conceptually:

```text
Development
    ↓
Debug build
    ↓
Test the app


Release preparation
    ↓
Release build
    ↓
Sign it
    ↓
Create .aab
    ↓
Upload to Google Play
```

---

## 2. Why Android Apps Need Signing

Android applications are digitally signed.

This signature helps Android and Google Play confirm that future versions of an
app belong to the same app identity.

For Veilmi, the Android application ID is:

```text
com.veilmi.app
```

Imagine that Veilmi version 1.0 is released today.

Later, version 1.1 is released.

Android needs a way to recognize:

```text
Veilmi 1.0
     ↓
same application
     ↑
Veilmi 1.1
```

Digital signing is part of that system.

It is different from simply putting the developer's name inside the app.

A digital signature is based on a cryptographic key.

---

## 3. What Is a Cryptographic Signing Key?

A signing key uses public-key cryptography.

Very roughly, there are two sides:

```text
Private key
    +
Public certificate information
```

The **private key** is the sensitive part.

It is used to create digital signatures.

The certificate contains public information that can be used to identify and
verify the key.

When the Veilmi key was created, certificate information included:

```text
Name: Noa Jou
Organization: Veilmi
Location: Taipei
Country: TW
```

This certificate information is not the secret.

The private key and the passwords protecting it are the important secrets.

---

## 4. What Is a Keystore?

Android signing keys are commonly stored inside a **keystore**.

For Veilmi, the file is:

```text
~/veilmi-upload-keystore.jks
```

The `.jks` extension means:

```text
Java KeyStore
```

A simple mental model is:

```text
veilmi-upload-keystore.jks
        │
        └── contains
              │
              ├── private signing key
              └── certificate
```

The keystore itself is protected by a password.

It is a binary file, not a normal text file.

Therefore, it should not be opened and edited with VS Code.

---

## 5. How the Veilmi Upload Key Was Created

Veilmi's upload keystore was created with Java's `keytool`.

The command was:

```bash
keytool -genkeypair -v \
  -keystore ~/veilmi-upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

This command can be read piece by piece.

```text
keytool
```

uses Java's key-management tool.

```text
-genkeypair
```

asks it to create a new public/private key pair.

```text
-keystore ~/veilmi-upload-keystore.jks
```

says where the keystore should be created.

The `~` means the current user's home directory.

Therefore the file is outside the Veilmi Git repository.

```text
-keyalg RSA
```

selects RSA as the key algorithm.

```text
-keysize 2048
```

creates a 2048-bit RSA key.

```text
-validity 10000
```

makes the certificate valid for 10,000 days.

```text
-alias upload
```

gives this key the name:

```text
upload
```

During creation, `keytool` asks for passwords and certificate information.

The passwords must remain private.

---

## 6. How to Check the Keystore

After the key has been created, it can be inspected with:

```bash
keytool -list -v \
  -keystore ~/veilmi-upload-keystore.jks \
  -alias upload
```

For Veilmi, this showed information such as:

```text
Alias name: upload
Entry type: PrivateKeyEntry
Subject Public Key Algorithm: 2048-bit RSA key
```

It also displayed SHA-1 and SHA-256 certificate fingerprints.

Those fingerprints are public identifiers.

They are not the private key.

---

## 7. What Is the `upload` Alias?

The key inside the keystore was given the alias:

```text
upload
```

An alias is simply a name used to identify a key inside a keystore.

Conceptually:

```text
veilmi-upload-keystore.jks
        │
        └── key named "upload"
```

A keystore can contain more than one key.

The alias tells Java and Gradle which key should be used.

The alias itself is not secret.

---

## 8. Why Is the Keystore Outside the Git Repository?

The Veilmi repository is:

```text
~/Veilmi/
```

The signing keystore is outside it:

```text
~
├── Veilmi/
│   ├── android/
│   ├── lib/
│   ├── docs/
│   └── ...
│
└── veilmi-upload-keystore.jks
```

This separation is intentional.

Veilmi's source code can be public.

The private signing key must not be public.

The dangerous version would be:

```text
Veilmi/
└── veilmi-upload-keystore.jks
```

especially if that file were accidentally committed to GitHub.

Veilmi's `.gitignore` also excludes common signing files such as:

```text
*.jks
*.keystore
key.properties
```

---

## 9. What Does `key.properties` Do?

The keystore contains the actual key.

However, Gradle still needs to know:

```text
Where is the keystore?
Which key should I use?
What passwords unlock it?
```

Veilmi uses:

```text
android/key.properties
```

for this purpose.

It contains values similar to:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/path/to/veilmi-upload-keystore.jks
```

The important distinction is:

```text
.jks file
    ↓
contains the actual private key


key.properties
    ↓
tells Gradle where the key is
and how to access it
```

`key.properties` does not contain the private key itself.

However, it contains passwords, so it must also remain private.

It is ignored by Git and must not be committed to the public repository.

---

## 10. What Is Gradle?

Gradle is the build system used by Android projects.

A simple way to think about it is:

> Gradle is the Android project's build manager.

Most of Veilmi is written using Flutter and Dart.

However, when Veilmi becomes an Android application, Android-specific work still
has to happen.

For example:

- choosing the Android SDK;
- setting the application ID;
- setting the minimum and target Android versions;
- choosing debug or release mode;
- loading the signing configuration;
- packaging Android libraries and resources;
- creating an APK or AAB.

Gradle coordinates these Android build tasks.

Conceptually:

```text
Dart / Flutter source code
          │
          ▼
       Flutter
          │
          │ asks Android to build the app
          ▼
       Gradle
          │
          ├── reads Android configuration
          ├── prepares dependencies
          ├── configures release signing
          ├── builds Android components
          └── packages the application
          │
          ▼
       APK / AAB
```

When Veilmi runs:

```bash
flutter build appbundle --release
```

Flutter starts the process.

For the Android-specific part, Flutter uses Gradle.

This is why the terminal showed:

```text
Running Gradle task 'bundleRelease'...
```

`bundleRelease` is the Gradle task used to create the release App Bundle.

### Gradle Is Not Android Studio

These are different things:

```text
Android Studio
    = development environment / IDE

Flutter
    = cross-platform application framework

Android SDK
    = Android tools and platform files

Gradle
    = Android build system
```

This is why Veilmi can be built from the terminal without manually opening
Android Studio.

### What Does `.kts` Mean?

Veilmi has this file:

```text
android/app/build.gradle.kts
```

The `.kts` part means:

```text
Kotlin Script
```

Veilmi therefore uses:

```text
Gradle
+
Kotlin DSL
```

Some older Android projects use a file called:

```text
build.gradle
```

which often uses Groovy instead.

---

## 11. What Does `build.gradle.kts` Do?

Gradle is the tool that performs the Android build.

`build.gradle.kts` contains instructions telling Gradle how Veilmi should be
built.

For example, it contains:

```kotlin
applicationId = "com.veilmi.app"
```

and Android SDK settings such as:

```kotlin
minSdk = flutter.minSdkVersion
targetSdk = flutter.targetSdkVersion
```

It also contains the release signing configuration.

Originally, the Flutter project used:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

That is useful during development.

A production release instead needs Veilmi's release signing configuration.

The new setup works approximately like this:

```text
key.properties
      │
      ├── keystore location
      ├── alias
      └── passwords
             │
             ▼
      build.gradle.kts
             │
             ▼
          Gradle
             │
             ▼
       release signing
```

So:

```text
key.properties
```

contains the local secret configuration,

while:

```text
build.gradle.kts
```

tells Gradle how to use that configuration.

---

## 12. The Complete Signing Flow

The whole signing process can now be visualized as:

```text
veilmi-upload-keystore.jks
          │
          │ contains the private key
          │
          ▼
android/key.properties
          │
          │ tells Gradle where the key is
          │
          ▼
android/app/build.gradle.kts
          │
          │ tells Gradle how release signing works
          │
          ▼
Gradle
          │
          │ builds and signs the Android release
          │
          ▼
app-release.aab
```

Another way to remember it is:

```text
Keystore
   = the key

key.properties
   = how to find and unlock the key

build.gradle.kts
   = signing instructions

Gradle
   = the tool that follows those instructions

AAB
   = the finished release package
```

---

## 13. What Is an `.aab` File?

Veilmi created its Android release bundle with:

```bash
flutter build appbundle --release
```

The resulting file was:

```text
build/app/outputs/bundle/release/app-release.aab
```

`.aab` means:

```text
Android App Bundle
```

It is the release package uploaded to Google Play.

An AAB is different from an APK.

### APK

An APK can be installed directly on an Android phone.

```text
APK
 ↓
Android phone
```

### AAB

An AAB is mainly a publishing format.

```text
AAB
 ↓
Google Play
 ↓
Google creates suitable APKs
 ↓
Android devices
```

The App Bundle can contain resources and code for several types of Android
devices.

Google Play can then deliver packages appropriate for each user's device.

---

## 14. Why Was the AAB 51.4 MB?

Veilmi's first release bundle was approximately:

```text
51.4 MB
```

This does not necessarily mean every user will download a 51.4 MB app.

The bundle can contain resources for different devices.

For example:

- different CPU architectures;
- screen-density resources;
- native libraries;
- other device-specific resources.

Google Play can generate optimized packages from the bundle.

---

## 15. What Was the "Tree-Shaken MaterialIcons" Message?

During the release build, Flutter printed a message similar to:

```text
Font asset "MaterialIcons-Regular.otf" was tree-shaken...
```

This is normal.

Flutter checked which Material icons Veilmi actually uses.

Instead of packaging the full Material Icons font, it removed unused icons.

Conceptually:

```text
Full Material Icons font
        ↓
Find icons Veilmi actually uses
        ↓
Remove unused icons
        ↓
Smaller release
```

This optimization is called **tree shaking**.

It is not an error.

---

## 16. Upload Key vs Google Play App Signing Key

There are two related keys that are easy to confuse.

### Upload Key

This is the key created locally for Veilmi:

```text
veilmi-upload-keystore.jks
```

Veilmi uses it to sign the AAB before uploading the bundle to Google Play.

Its purpose is roughly:

```text
This upload came from an authorized Veilmi publisher.
```

### App Signing Key

With Google Play App Signing, Google manages the key used to sign the packages
that are ultimately distributed to users.

The simplified process is:

```text
Developer
    │
    │ signs AAB with upload key
    ▼
app-release.aab
    │
    ▼
Google Play
    │
    │ verifies the upload
    ▼
Google Play App Signing
    │
    │ signs packages distributed to users
    ▼
Android devices
```

Therefore:

```text
Upload key
```

and:

```text
App signing key
```

have different jobs.

---

## 17. Why the Upload Key Still Matters

The upload key will also be used when future versions of Veilmi are submitted.

For example:

```text
Veilmi 1.0
    ↓
authorized upload key
    ↓
Google Play


Veilmi 1.1
    ↓
authorized upload key
    ↓
Google Play
```

This is why the upload keystore should be backed up safely.

---

## 18. What Is Secret and What Can Be Public?

The easiest rule is:

```text
Public source code
does not mean
public private keys
```

These values can be public:

```text
Application ID
Key alias
Certificate fingerprints
Public certificate information
SHA-1 fingerprint
SHA-256 fingerprint
```

For example:

```text
com.veilmi.app
```

and:

```text
upload
```

are not secrets.

These must remain private:

```text
private key
veilmi-upload-keystore.jks
keystore password
key password
android/key.properties
```

Before pushing release changes to GitHub, run:

```bash
git status
```

The following should not appear as files waiting to be committed:

```text
android/key.properties
veilmi-upload-keystore.jks
```

---

## 19. What Must Be Backed Up?

The important release information is:

```text
veilmi-upload-keystore.jks
keystore password
key password
key alias
```

For Veilmi, the alias is:

```text
upload
```

A reasonable backup arrangement is:

```text
Development computer
    └── working copy of .jks

Secure backup
    └── another copy of .jks

Password manager
    └── passwords
```

The signing key should not exist only on one computer.

It should also never be stored in the public Git repository.

---

## 20. Building a Release Bundle

Before building a release, Veilmi can first run:

```bash
flutter analyze
flutter test
```

Then build the Android App Bundle:

```bash
flutter build appbundle --release
```

The full basic sequence is:

```bash
flutter analyze
flutter test
flutter build appbundle --release
```

A successful build creates:

```text
build/app/outputs/bundle/release/app-release.aab
```

The successful Veilmi build showed:

```text
Built build/app/outputs/bundle/release/app-release.aab
```

That means the Android release build and signing configuration worked.

---

## 21. Version Numbers

Veilmi's version is defined in:

```text
pubspec.yaml
```

For example:

```yaml
version: 1.0.0+1
```

This contains two pieces:

```text
1.0.0
```

is the human-readable version name.

```text
+1
```

is the Android version code.

Conceptually:

```text
version: 1.0.0+1
         │     │
         │     └── versionCode
         │
         └── versionName
```

When a new release is uploaded to Google Play, the version code must increase.

For example:

```yaml
version: 1.0.1+2
```

or:

```yaml
version: 1.1.0+2
```

depending on the release.

---

## 22. Veilmi's Current Android Release Configuration

At the time this document was written, Veilmi uses:

```text
Application ID: com.veilmi.app
Version:        1.0.0+1
Flutter:        3.47.3 stable
Android SDK:    36
Upload alias:   upload
```

The release bundle was successfully built with:

```bash
flutter build appbundle --release
```

and produced:

```text
build/app/outputs/bundle/release/app-release.aab
```

---

## 23. A Simple Mental Model

The easiest way to remember the whole process is:

```text
Write Veilmi
    ↓
Flutter prepares the app
    ↓
Gradle handles the Android build
    ↓
Gradle uses the upload key
    ↓
Release is signed
    ↓
app-release.aab
    ↓
Google Play
    ↓
Android users
```

Or even more simply:

```text
Code
 ↓
Build
 ↓
Sign
 ↓
AAB
 ↓
Google Play
 ↓
Users
```

A factory analogy can also help:

```text
Dart source code
    = design and raw materials

Flutter
    = cross-platform production system

Gradle
    = Android factory manager

build.gradle.kts
    = instructions for the factory manager

key.properties
    = instructions for finding the release stamp

keystore
    = protected release stamp

AAB
    = finished package sent to Google Play
```

---

## 24. Release Checklist

Before uploading a future Veilmi Android release:

```text
[ ] Update the app version
[ ] Run flutter analyze
[ ] Run flutter test
[ ] Test important features on a real Android device
[ ] Check git status
[ ] Confirm key.properties is not tracked by Git
[ ] Confirm the .jks file is not tracked by Git
[ ] Run flutter build appbundle --release
[ ] Confirm app-release.aab was created
[ ] Upload the AAB to Google Play
```

The most important security rule is:

> Veilmi's source code can be public. Its private signing key must remain private.