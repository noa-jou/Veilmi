# Google Play Release Process

This document records my first experience preparing and publishing Veilmi
through Google Play Console.

Rather than describing the entire process in advance, I am documenting each
stage as I complete it.

This is intended as a practical record for other first-time developers who may
be going through the same process.

---

## 1. Developer Account and Identity Verification

Before I could publish Veilmi on Google Play, I first needed to create a
Google Play Console developer account and complete the required developer
verification.

For a personal developer account, Google Play requires information such as:

- a developer name;
- legal name and address;
- contact information;
- a developer email address;
- a linked Google Payments profile;
- identity verification when required.

Google may also request an official government identity document as part of
verifying a personal developer account.

I completed the account setup and submitted the requested identity information
through Google Play Console.

At the time of writing, my identity verification has been submitted and is
still under review.

```text
Create developer account
        ↓
Provide developer information
        ↓
Link Google Payments profile
        ↓
Submit identity verification
        ↓
Wait for verification result
        ↓
Current stage
````

I am intentionally not recording document numbers, identification images,
account numbers, or other private verification information in this public
repository.

Some later verification steps cannot be completed until earlier requirements
have been approved. I will continue documenting the release process after my
developer verification progresses.

For the current official requirements, see the
[Google Play Console developer identity verification documentation](https://support.google.com/googleplay/android-developer/answer/10841920).


### Developer and Project Identity

While preparing the developer account and Android release, I also had to
decide how Veilmi should identify the developer and the application.

For the signing certificate, I used information such as:

```text
Name:         Noa Jou
Organization: Veilmi
Country:      TW
````

I used **Veilmi** as the organization name because the signing certificate is
associated with this project. It does not mean that Veilmi is a registered
company or legal organization.

The Android application itself uses this Application ID:

```text
com.veilmi.app
```

An Android Application ID is a unique technical identifier for the app. It is
not the same thing as the developer's personal name.

The structure can be read roughly as:

```text
com . veilmi . app
 │      │      │
 │      │      └── the application
 │      │
 │      └── the Veilmi project namespace
 │
 └── conventional reverse-domain-style prefix
```

I chose a project-based identifier instead of something such as:

```text
com.noajou.veilmi
```

because I wanted the application identity to belong to **Veilmi**, rather than
to my personal name.

Both approaches can be used for Android applications as long as the
Application ID is valid and unique, but once an app is published, the
Application ID becomes an important permanent part of the app's identity.

For Veilmi, I therefore chose:

```text
com.veilmi.app
```

and kept my personal developer identity separate from the application's
technical identifier.


## 2. Create the App in Play Console

## 3. Prepare the Store Listing

## 4. Add App Icon, Feature Graphic, and Screenshots

## 5. Add the Privacy Policy

## 6. Complete App Content and Data Safety

## 7. Upload the Signed Android App Bundle

## 8. Testing Track

## 9. Review Release Information

## 10. Submit for Review

## 11. What Happened After Submission