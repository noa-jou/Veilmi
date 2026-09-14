# Google Play Release Process

This document records my first Google Play release journey for **Veilmi**.

It is **not** intended to be a field-by-field copy of everything I entered in
Google Play Console. Google changes the Console over time, and another app may
need different answers.

Instead, this document focuses on the parts that were confusing, the mistakes I
made, what blocked the release, and how I worked through those problems.

The main lesson from my first release was that building the Android App Bundle
was only one part of the job. Most of the difficulty came from understanding how
Google Play separates app setup, store listings, testing, policy declarations,
and final submission.

> **Note:** Page names and button labels may change over time or appear
> differently depending on the Play Console language.

---

## Release Milestone

My first Closed Testing submission reached Google review on **14 September
2026**.

```text
Veilmi 1.0.0
        ↓
Signed Android App Bundle
        ↓
Closed Testing track
        ↓
Store Listing and policy setup
        ↓
Blocking issues resolved
        ↓
Changes sent for review
        ↓
Current stage: Google review
```

This was a **Closed Testing** submission, not a public Production release.

---

## 0. Identity Verification Was Only the Beginning

Before using the release tools, I had to complete the developer-account and
identity-verification requirements.

I do not record identification numbers, verification documents, passwords, or
other private account information in this repository.

After the account was verified, I expected the rest of the process to be mostly
about uploading the app. It was not.

The difficult part was learning how Google Play divides one release across
several different areas of the Console.

The pages I eventually learned to recognize were:

```text
Dashboard
└── App setup checklist

Policy and programs
└── App content

Test and release
└── Testing
    └── Closed testing

Grow users
└── Store presence
    ├── Store listings
    └── Store settings

Publishing overview
└── View issues / Send changes for review
```

### Lesson learned

When Play Console appears to be blocking progress, the problem is not
necessarily the Android build. The unfinished requirement may be on a completely
different page.

---

---

## 1. I Could Not Go Straight to Production

After my developer identity was verified, I discovered that a new personal
Google Play developer account may need to complete **Closed Testing** before it
can apply for Production access.

So I stopped trying to think about the public release and created a Closed Test
for Veilmi first.

For my account, the next goal is to have at least **12 testers** stay opted in for
at least **14 days** before applying for Production access.

**What I learned:** not being able to use Production did not mean anything was
wrong with Veilmi. Closed Testing was simply the next required stage.

---

## 2. The Tester Group Had to Exist First

I decided to use a Google Group to manage Closed Test users.

At first, I tried to add the group address in Play Console before I had actually
created the group. Play Console rejected it.

The fix was simple:

```text
Create the Google Group first
        ↓
Add it to the Closed Test
```

I also learned that joining the Google Group is **not** the same as joining the
Google Play test. After the release becomes available, testers will still need
the Google Play opt-in link.

**What I learned:** the Google Group controls who is allowed to test; the Play
opt-in link is what actually joins them to the test.

---

## 3. The AAB Was Fine, but Google Play Still Would Not Let Me Submit

The signed Veilmi Android App Bundle uploaded successfully. Google Play accepted
it and recognized the release correctly.

But the release still could not be submitted.

The problem was not the AAB. Google Play was waiting for other required setup and
policy information to be completed.

**What I learned:** a successful AAB upload only means the Android build is
acceptable. It does not mean the whole Play Store submission is ready.

---

## 4. Some Requirements Only Became Obvious When They Blocked the Release

Google Play asks for several app-information and policy declarations. Even when a
feature does not apply to the app, the declaration may still need to be opened
and completed.

One confusing example was the **Advertising ID** declaration. I had already
finished the normal advertising questions, but Advertising ID appeared later as
a separate blocking issue.

The useful place to look was:

```text
Publishing overview
        ↓
View issues
```

I also had to think carefully about what Veilmi actually is. It works alongside
messaging apps, but it does not provide its own messaging or social network.

**What I learned:** when Play Console blocks submission, follow the issue it
shows instead of guessing or changing the Android project.

---

## 5. Adding English, Taiwan Chinese, and Hong Kong Chinese Was More Confusing Than Translating Them

I wanted the Store Listing in:

```text
English (United Kingdom)
Traditional Chinese (Taiwan)
Chinese (Hong Kong)
```

The difficult part was finding the correct place to add normal language versions.
I briefly ended up looking at translation services and custom store listings,
which were not what I needed.

The normal language versions were all managed from the main/default Store Listing
using the language selector.

The Taiwan and Hong Kong versions could share most of the same Traditional
Chinese text. There was no need to force them to be very different.

**What I learned:** Store Listing languages, translation services, and custom
store listings are different features.

---

## 6. I Made Separate Images for the Google Play Store

The Store Listing needed its own graphics, so I prepared a Play Store version of
the Veilmi icon and generated another promotional image for the listing.

For the phone screenshots, I used real Veilmi screenshots so the store page would
show what the app actually looks like.

When I opened the Chinese listings, the English screenshots first appeared faded
and looked as if they could not be changed. They were only inherited from the
default language. After I added the Chinese screenshots, they replaced the faded
ones.

**What I learned:** Store Listing graphics can have their own versions. A faded
image may simply be inherited from the default language.

I just need to add the new ones to replace them. And the screenshots can be arranged by dragging!

---

## 7. Saving Changes Was Not the Same as Sending Them to Google

This caused unnecessary worry at first.

```text
Save
≠
Send for review
```

Opening **Publishing overview** also did not publish anything. It was simply the
place where Google collected the changes I had saved and showed me what was still
blocking the submission.

Once all the blockers were cleared, the button to send the changes for review
became available.

**What I learned:** I could safely save my work and visit Publishing overview
without accidentally publishing Veilmi.

---

## 8. I Finally Sent the Closed Test for Review

When everything was ready, Publishing overview showed **15 changes** waiting to
be submitted.

I sent them for review and confirmed the submission.

The status then changed to:

```text
Changes in review
```

That was the confirmation that Veilmi 1.0.0 had entered Google's review process.
It was still a **Closed Testing** release, not a public Production release.

For now, there is nothing else to do except wait for Google's result. After the
Closed Test becomes available, I can invite testers, share the opt-in link, and
start the testing period.

**What I learned:** the final button felt dramatic, but it did not publish Veilmi
to everyone. It only submitted the Closed Test and its related changes for
review.

---

## Current Status

```text
Veilmi 1.0.0
        ↓
Closed Test submitted
        ↓
Google review
        ↓
Next: invite testers after approval
```

This is where the first Google Play release journey currently stops. I will
continue this document when the Closed Test moves to the next stage.

## Useful Official Google Play Documentation

- [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152)
- [Set up an open, closed, or internal test](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)
- [Control when app changes are reviewed and published](https://support.google.com/googleplay/android-developer/answer/9859654)
