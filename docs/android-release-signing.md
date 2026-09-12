# Android Release Signing and App Bundle

This document is a beginner-friendly explanation of the Android release process
used by Veilmi.

It explains:

- what a release build is;
- what an upload key is;
- what a keystore is;
- what `key.properties` does;
- how Gradle signs a release;
- what an Android App Bundle (`.aab`) is;
- which files must remain private.

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

For example:

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

The signature helps Android and Google Play determine that future versions of
an application belong to the same application identity.

For Veilmi, the Android application ID is:

```text
com.veilmi.app
```

Imagine that Veilmi version 1.0 is released today.

Later, version 1.1 is released.

Android needs a way to know:

```text
Veilmi 1.0
     ↓
and
     ↓
Veilmi 1.1
```

belong to the same application.

Digital signing is part of that system.

It is therefore very different from simply putting the developer's name inside
the app.

---

## 3. What Is a Cryptographic Key?

A signing key is part of a public-key cryptography system.

Very roughly, it contains:

```text
Private key
    +
Public information / certificate
```

The **private key** must remain private.

It is used to create digital signatures.

The certificate contains public information that can be used to identify and
verify the signing key.

When the Veilmi key was created, information such as the following was included
in its certificate:

```text
Name: Noa Jou
Organization: Veilmi
Location: Taipei
Country: TW
```

This information is not the secret part.

The private key and its password are the sensitive parts.

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

A useful mental model is:

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

Therefore it should not be opened and edited with VS Code.

To inspect it, use Java's `keytool`.

For example:

```bash
keytool -list -v \
  -keystore ~/veilmi-upload-keystore.jks \
  -alias upload
```

---

## 5. Why the Keystore Is Outside the Git Repository

The Veilmi repository is located at:

```text
~/Veilmi/
```

The upload keystore is stored outside it:

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

The repository can be public.

The private signing key must not be public.

The following would be dangerous:

```text
Veilmi/
└── veilmi-upload-keystore.jks
```

especially if the file were committed to Git.

The current Veilmi `.gitignore` also excludes common signing files such as:

```text
*.jks
*.keystore
key.properties
```

This provides another layer of protection.

---

## 6. What Is the `upload` Alias?

When the keystore was created, the key was given this alias:

```text
upload
```

The alias is simply a name used to identify a particular key inside a keystore.

Conceptually:

```text
veilmi-upload-keystore.jks
        │
        └── key named "upload"
```

A keystore can theoretically contain multiple keys, so the alias tells Java
which one should be used.

The alias itself is not secret.

---

## 7. What Does `key.properties` Do?

Veilmi contains this local configuration file:

```text
android/key.properties
```

It contains information needed by Gradle to locate and unlock the upload key.

Conceptually, it contains:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=...
```

The important distinction is:

```text
.jks file
    ↓
actually contains the key

key.properties
    ↓
tells Gradle where the key is
and how to access it
```

`key.properties` does **not** contain the private key itself.

However, it contains passwords and must therefore also remain private.

It must never be committed to the public GitHub repository.

---

## 8. What Does `build.gradle.kts` Do?

The Android release configuration is stored in:

```text
android/app/build.gradle.kts
```

Originally, the Flutter project used the debug signing configuration:

```kotlin
signingConfig = signingConfigs.getByName("debug")
```

That is useful during development, but it is not the signing configuration that
should be used for a production release.

Veilmi now loads:

```text
android/key.properties
```

and creates a release signing configuration.

Conceptually:

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
       release signing
```

Gradle can then use the Veilmi upload key when creating the release bundle.

---

## 9. The Complete Signing Flow

The signing process can be visualized like this:

```text
veilmi-upload-keystore.jks
          │
          │ contains the private key
          │
          ▼
android/key.properties
          │
          │ tells Gradle how to find the key
          │
          ▼
android/app/build.gradle.kts
          │
          │ configures release signing
          │
          ▼
flutter build appbundle --release
          │
          ▼
app-release.aab
```

The important point is that Flutter itself is not storing the secret key inside
the Dart source code.

The key remains outside the application source.

---

## 10. What Is an `.aab` File?

After running:

```bash
flutter build appbundle --release
```

Flutter created:

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

An APK is an Android application package that can be installed directly on an
Android device.

```text
APK
 ↓
install on phone
```

### AAB

An AAB is mainly a publishing format.

```text
AAB
 ↓
Google Play
 ↓
Google generates appropriate APKs
 ↓
user's device receives an optimized package
```

The AAB can contain resources and code for several kinds of Android devices.

Google Play can then generate the package appropriate for each user's device.

---

## 11. Why Was the AAB 51.4 MB?

The first Veilmi release bundle was built successfully as:

```text
app-release.aab
```

with a size of approximately:

```text
51.4 MB
```

This does not necessarily mean every user will download a 51.4 MB application.

The App Bundle contains material that Google Play can use to generate optimized
packages for different devices.

For example, different devices may require different:

- CPU architectures;
- resources;
- screen-density assets;
- native libraries.

Google Play can deliver only the required parts.

---

## 12. What Was the "Tree-Shaken MaterialIcons" Message?

During the release build, Flutter printed a message similar to:

```text
Font asset "MaterialIcons-Regular.otf" was tree-shaken...
```

This is normal.

Flutter analyzed which Material icons Veilmi actually uses.

Instead of packaging the entire Material Icons font, Flutter removed unused
icons.

Conceptually:

```text
Full Material Icons font
        ↓
Find icons actually used by Veilmi
        ↓
Remove unused icons
        ↓
Smaller release
```

This optimization is called **tree shaking**.

It is not an error.

---

## 13. Upload Key vs Google Play App Signing Key

There are two related keys that should not be confused.

### Upload key

This is the key created locally for Veilmi:

```text
veilmi-upload-keystore.jks
```

It is used to sign the bundle before uploading it to Google Play.

Its purpose is essentially to prove:

```text
This upload came from someone authorized
to publish Veilmi.
```

### App signing key

With Google Play App Signing, Google Play manages the key used to sign the APKs
that are ultimately distributed to users.

The simplified flow is:

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
    │ verifies upload
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

are related, but they are not necessarily the same key.

---

## 14. Why the Upload Key Still Matters

Even when Google Play manages the final app signing key, the upload key remains
important.

It is used when submitting future versions of Veilmi.

For example:

```text
Veilmi 1.0.0
     ↓
upload key
     ↓
Google Play

Veilmi 1.1.0
     ↓
same authorized upload identity
     ↓
Google Play
```

The upload keystore should therefore be backed up safely.

---

## 15. What Must Be Backed Up?

The most important release materials are:

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

The `.jks` file should have at least one secure backup outside the development
computer.

The password should preferably be stored separately in a password manager.

A reasonable model is:

```text
Chromebook
    └── working copy of .jks

Secure backup
    └── backup copy of .jks

Password manager
    └── keystore password
```

Do not store all of these secrets together in the public repository.

---

## 16. What Can Be Public?

These values do not need to remain secret:

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

is public information.

Certificate fingerprints are also public identifiers.

The sensitive items are:

```text
private key
keystore file
keystore password
key password
```

---

## 17. Files That Must Never Be Committed

Do not commit files such as:

```text
*.jks
*.keystore
key.properties
.env
```

if they contain secrets.

Before committing release configuration changes, it is useful to run:

```bash
git status
```

The following should **not** appear as files waiting to be committed:

```text
android/key.properties
veilmi-upload-keystore.jks
```

If they appear, stop and fix `.gitignore` before pushing.

---

## 18. Building a Release Bundle

Once signing is configured, Veilmi can build an Android release bundle with:

```bash
flutter build appbundle --release
```

Before building, it is useful to run:

```bash
flutter analyze
flutter test
```

The complete basic sequence is:

```bash
flutter analyze
flutter test
flutter build appbundle --release
```

A successful build produces:

```text
build/app/outputs/bundle/release/app-release.aab
```

---

## 19. Version Numbers

Veilmi currently uses the Flutter version declaration in:

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

When a new version is uploaded to Google Play, the version code must increase.

For example:

```yaml
version: 1.0.1+2
```

or:

```yaml
version: 1.1.0+2
```

depending on the kind of release.

---

## 20. Veilmi's Current Android Release Configuration

At the time this document was written, Veilmi uses:

```text
Application ID: com.veilmi.app
Version:        1.0.0+1
Flutter:        3.47.3 stable
Android SDK:    36
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

## 21. A Simple Mental Model

The easiest way to remember the whole process is:

```text
Source code
    │
    ▼
Flutter builds the app
    │
    ▼
Gradle prepares Android release
    │
    ▼
Upload key signs the release
    │
    ▼
app-release.aab
    │
    ▼
Google Play
    │
    ▼
Google Play signs packages for users
    │
    ▼
Android phones
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

---

## 22. Important Security Rule

The source code of Veilmi can be public.

The signing private key cannot.

These are separate ideas:

```text
Open-source application
        ≠
Public signing key
```

Publishing Veilmi's source code allows other people to study and verify how the
application works.

Keeping the upload private key secret prevents unauthorized people from
pretending to be the authorized Veilmi publisher.

---

## 23. Release Checklist

Before uploading a new Android release:

```text
[ ] Update and review the app
[ ] Run flutter analyze
[ ] Run flutter test
[ ] Test important features on a real Android device
[ ] Update the version number
[ ] Confirm key.properties is not tracked by Git
[ ] Confirm the .jks file is not tracked by Git
[ ] Build with flutter build appbundle --release
[ ] Confirm app-release.aab was created
[ ] Upload the AAB to Google Play
```

The private signing materials should never be uploaded to GitHub.