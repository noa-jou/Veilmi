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

## 1. Identity Verification Was Only the Beginning

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

## 2. Production Was Not the First Destination

One of my first important discoveries was that a new personal developer account
may need to complete Google Play's Closed Testing requirement before Production
access is available.

That changed the release plan.

Instead of trying to publish Veilmi directly to everyone, I created a Closed
Testing track:

```text
Veilmi Closed Test
```

This made the release path much clearer:

```text
Closed Test
    ↓
Invite eligible testers
    ↓
Complete the required testing period
    ↓
Apply for Production access later
```

### Lesson learned

A disabled or unavailable Production option does not necessarily mean that the
app has failed review or that the build is broken. It can simply mean that the
account must complete the testing requirement first.

---

## 3. Tester Management Was More Complicated Than Expected

For Closed Testing, Play Console allowed me to manage testers using an email
list or a Google Group.

I chose a Google Group because I wanted a reusable group that I could share when
recruiting testers.

I created:

```text
Veilmi Testers
veilmi-testers@googlegroups.com
```

### The problem

At first, I tried to enter the planned Google Group address in Play Console
before the group actually existed.

Play Console could not accept it.

### The solution

The correct order was:

```text
Create the Google Group
        ↓
Configure membership and privacy settings
        ↓
Return to Play Console
        ↓
Closed testing → Testers
        ↓
Add the real Google Group address
```

I also learned that three things that sound similar are actually different:

```text
Google Group membership
        ≠
Google Play test opt-in
        ≠
Feedback contact
```

The Google Group controls who is eligible for the test. After the release becomes
available, testers still need to use the Google Play tester opt-in link. The
feedback address is simply where testers can contact me.

### Lesson learned

Do not assume that Play Console creates or manages an external Google Group for
you. Create the group first, then connect it to the testing track.

---

## 4. The AAB Uploaded Successfully, but the Release Was Still Blocked

I uploaded the signed Android App Bundle to the Closed Testing release.

Google Play accepted the bundle and correctly detected the app information,
including the version and supported Android API range.

That was an important milestone because it showed that the Android release build
itself was valid.

However, I still could not submit the release.

### The problem

My first instinct was to wonder whether something was wrong with the AAB.
Instead, the real issue was that Play Console still had unfinished app-setup and
policy tasks.

Some declarations must be completed even when the answer is simply that the
feature does not apply to the app.

### The solution

I returned to the app setup checklist and completed the remaining required
items. When I later found another block, I used:

```text
Publishing overview
        ↓
View issues
```

rather than guessing what was wrong.

### Lesson learned

A successfully uploaded AAB does **not** mean the app is ready to submit.
Android build validation and Google Play policy/setup completion are separate
stages.

---

## 5. One Blocking Declaration Appeared Later

A particularly confusing example was the **Advertising ID** declaration.

I had already completed the normal advertising-related setup, but Publishing
overview later reported another unfinished Advertising ID declaration.

### The problem

It was easy to assume that the normal **Ads** declaration and the
**Advertising ID** declaration were the same thing.

They were not.

### The solution

I followed the issue from:

```text
Publishing overview
        ↓
View issues
        ↓
Advertising ID declaration
```

and completed the separate declaration according to what Veilmi actually uses.

### Lesson learned

When the submission button is disabled, **View issues** is more useful than
randomly revisiting old forms. Play Console may reveal an additional declaration
only after other parts of the release are ready.

---

## 6. App Classification Required Thinking About What Veilmi Actually Does

Some Play Console questions are not difficult because of the interface. They are
difficult because the developer has to describe the product accurately.

Veilmi is designed to work alongside communication apps, but Veilmi itself does
not provide a messaging network, social network, or message-delivery service.

That distinction mattered when answering the content-rating questions.

### Lesson learned

Classify the app based on the functionality the app itself provides, not merely
on the context in which people may use it.

This is especially important for a security tool such as Veilmi, which can be
used before sending text through another communication service without being a
communication service itself.

---

## 7. Store Listing Localization Was Hidden Behind an Unexpected Interface

I wanted the Google Play page to support:

```text
English (United Kingdom) — en-GB
Traditional Chinese (Taiwan) — zh-TW
Chinese (Hong Kong) — zh-HK
```

The difficult part was not translating the text. It was finding the correct
place to edit normal localized Store Listings.

### The wrong paths

I initially encountered options related to translation services and custom store
listings. Neither was what I needed.

A **custom store listing** is not required simply because an app supports another
language.

### The solution

The normal language versions were managed inside the default/main Store Listing
editor using its language selector.

Once I found that control, I could switch between the English, Taiwan Chinese,
and Hong Kong Chinese versions and edit them separately.

The Taiwan and Hong Kong listings could share most of the same Traditional
Chinese content. There was no need to artificially make them completely
different.

### Lesson learned

Localization in Play Console is easy to confuse with Google's translation
service and custom-listing features. They solve different problems.

---

## 8. Localized Screenshots Looked Locked, but They Were Only Inherited

Another confusing moment happened when I opened a Chinese Store Listing.

The English screenshots appeared in a faded or greyed-out state, which made it
look as though Play Console would not let me replace them.

### The problem

Those images were not broken or locked. They were inherited from the default
language because I had not yet supplied language-specific graphics.

### The solution

I added the Traditional Chinese screenshots to the localized Store Listing.
They then replaced the inherited default-language graphics.

For Veilmi, the Taiwan and Hong Kong Store Listings can use the same Traditional
Chinese screenshots because the app currently uses the same Traditional Chinese
interface for both.

### Another small UI lesson

The order of screenshots can be changed by dragging them, even though the
interface does not make this especially obvious.

### Lesson learned

A greyed-out asset can mean **inherited from the default language**, not
**uneditable**.

---

## 9. Store Assets Sometimes Need Release-Specific Versions

My original Veilmi artwork was not in the exact form required by the Play Store
listing, so I prepared a separate Play-specific app icon rather than changing
the original project artwork.

I also used real Veilmi screenshots instead of promotional mockups for the phone
screenshots.

### Lesson learned

Store assets are distribution assets. They do not all need to be identical to
the original source artwork, but they should accurately represent the real app
and satisfy the store's technical requirements.

---

## 10. Release Notes and Store Listing Languages Are Separate

Play Console showed multiple languages in the release-note editor. At first, it
was easy to read that as confirmation that the Store Listing itself had also been
localized.

It had not.

### Lesson learned

These are separate systems:

```text
Release-note languages
        ≠
Store Listing languages
```

A translated release note does not automatically create a translated Store
Listing.

---

## 11. Saving Is Not Submitting

One of the most important things I learned about Play Console is that saving a
change does not send it to Google for review.

```text
Save
≠
Send for review
```

I also accidentally opened **Publishing overview** before I was ready and was
worried that I had published something.

Nothing was published.

```text
Open Publishing overview
≠
Publish the app
```

Publishing overview is mainly a staging area that collects saved changes and
shows whether anything is preventing submission.

### Lesson learned

Do not treat navigation as publication. The release only moved into review after
I explicitly used the submission action and confirmed it.

---

## 12. The Final Block Was Solved by Following the Error, Not by Guessing

Near the end of the process, Publishing overview showed the release changes but
the submission action was not yet available.

Instead of editing the Android project or rebuilding the AAB, I used:

```text
Publishing overview
        ↓
View issues
        ↓
Fix the reported requirement
        ↓
Save
        ↓
Return to Publishing overview
```

I repeated that process until there were no blocking issues.

Eventually the submission button became active and showed:

```text
Send 15 changes for review
```

The number itself was not important. It represented the group of saved changes
that had accumulated across the Closed Test, Store Listing, and app setup.

After confirming the submission, the page changed from a state equivalent to:

```text
Changes not yet submitted
```

to:

```text
Changes in review
```

That was the confirmation I was looking for.

### Lesson learned

The most reliable way through Play Console is:

```text
Read the blocking issue
        ↓
Fix that specific issue
        ↓
Return to Publishing overview
        ↓
Repeat
```

This is much safer than changing unrelated parts of the project because the
submission button happens to be disabled.

---

## 13. What Was Actually Submitted

The first submission sent Veilmi's **Closed Testing** release and its related
changes to Google for review.

It did **not** make Veilmi publicly available as a Production app.

That distinction mattered because pressing the final confirmation button felt
much more dramatic than what was actually happening.

The state after submission was simply:

```text
Veilmi Closed Test
        ↓
Changes in review
        ↓
Wait for Google
```

At this point, there was nothing else that needed to be pressed immediately.

---

## 14. What Comes Next

After the Closed Testing release becomes available, the next challenge is not
another build. It is getting real testers through the complete opt-in flow.

For the Google Group approach, the intended tester journey is:

```text
Join Veilmi Testers Google Group
        ↓
Open the Google Play tester link
        ↓
Opt in to the Closed Test
        ↓
Install Veilmi from Google Play
        ↓
Test the app
        ↓
Send feedback
```

For new personal developer accounts covered by Google's testing requirement,
Production access can only be requested after the required Closed Testing period
and tester participation have been completed.

I will continue this document when Veilmi reaches that stage.

---

## Troubleshooting Map I Wish I Had at the Beginning

This is the shortest version of what I learned.

| Problem | Where I look first |
| --- | --- |
| Play says app setup is incomplete | Dashboard → App setup checklist |
| I need to reopen a declaration | Policy and programs → App content |
| I need to edit public store text or graphics | Grow users → Store presence → Store listings |
| I need to change Closed Test settings | Test and release → Testing → Closed testing |
| Google Group is rejected | Confirm the group exists first, then return to Closed testing → Testers |
| Chinese graphics look greyed out | They may be inherited assets; add localized graphics to override them |
| I uploaded an AAB but still cannot submit | Publishing overview → View issues |
| I saved everything but nothing is under review | Publishing overview → Send changes for review |
| I am afraid that opening Publishing overview published the app | It did not; submission requires a separate explicit action |

---

## Main Lessons From the First Submission

The hardest part of my first Google Play release was not producing the Android
bundle. It was understanding the release system around it.

The lessons I want to remember are:

1. **A valid AAB and a release that is ready for review are different things.**
2. **Closed Testing may be a required stage, not a failed attempt at Production.**
3. **External tester groups must exist before Play Console can use them.**
4. **A Google Group, tester opt-in, and feedback channel are separate concepts.**
5. **Policy declarations that do not apply may still need to be completed.**
6. **Ads and Advertising ID are separate declarations.**
7. **Normal localized Store Listings are not the same as translation services or custom listings.**
8. **Greyed-out localized graphics may simply be inherited default assets.**
9. **Release-note languages and Store Listing languages are separate.**
10. **Saving changes is not the same as submitting them.**
11. **Publishing overview is the best place to discover what is actually blocking submission.**
12. **Follow the reported problem instead of changing unrelated build settings.**

The release process became much less intimidating once I stopped treating Play
Console as one giant form and started treating each block as a separate problem
to solve.

---

## Useful Official Google Play Documentation

- [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152)
- [Set up an open, closed, or internal test](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)
- [Control when app changes are reviewed and published](https://support.google.com/googleplay/android-developer/answer/9859654)
