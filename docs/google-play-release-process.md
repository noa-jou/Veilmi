
# Google Play Release Process

This document records my first Google Play release journey for **Veilmi**.

It is **not** intended to be a field-by-field copy of everything I entered in
Google Play Console. Google changes the Console over time, and another app or
developer account may have different requirements.

Instead, this document focuses on the parts that confused me, the mistakes I
made, what blocked progress, and how I eventually understood the process.

The biggest lesson from my first release was that building a valid Android App
Bundle was only one part of publishing an Android app.

Much of the difficulty came from understanding how Google Play separates:

- developer-account setup;
- app setup;
- testing tracks;
- tester eligibility;
- store listings;
- policy declarations;
- review;
- and Production access.

> **Note:** Page names, button labels, and requirements may change over time or
> appear differently depending on the Play Console language.

---

## Release Milestones

My first Veilmi Closed Testing submission was sent to Google for review on
**14 September 2026**.

By **16 September 2026**, the Closed Testing track was active and I had reached
the next stage: recruiting testers and running the actual test.

```text
Developer identity verified

        ↓

Production access unavailable

        ↓

Closed Testing required

        ↓

Closed Test created

        ↓

Tester Google Group created

        ↓

Signed Android App Bundle uploaded

        ↓

Store Listing and policy requirements completed

        ↓

Blocking issues resolved

        ↓

Changes sent for review
14 September 2026

        ↓

Closed Test became active

        ↓

Tester onboarding process clarified

        ↓

Current stage:
Recruit at least 12 testers
and run the Closed Test
for at least 14 continuous days
````

This is still a **Closed Testing** release.

Veilmi is **not yet publicly available in Production**.

---

## 0. Identity Verification Was Only the Beginning

Before using the release tools, I had to complete the developer-account and
identity-verification requirements.

I do not record identification numbers, verification documents, passwords, or
other private account information in this repository.

After the account was verified, I expected the rest of the process to be mostly
about uploading the app.

It was not.

The difficult part was learning how Google Play divides a release across several
different areas of Play Console.

The pages I eventually learned to recognize included:

```text
Dashboard
└── App setup checklist

Policy and programs
└── App content

Test and release
└── Testing
    ├── Internal testing
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
necessarily the Android build.

The unfinished requirement may be on a completely different page.

---

## 1. I Could Not Go Straight to Production

After my developer identity was verified, I initially thought that once the app
was ready I would be able to prepare a Production release.

That was not the next step for my account.

For newer personal Google Play developer accounts, Google requires a qualifying
**Closed Test** before the developer can apply for Production access.

For my account, the requirement is:

```text
At least 12 testers

        +

Continuously opted in
for at least 14 days

        ↓

Apply for Production access
```

This means completing the Closed Test does not automatically publish Veilmi to
Production.

It allows me to **apply for Production access**. Google then asks additional
questions about the app, the testing process, and its readiness for Production.

### Lesson learned

Not being able to use Production did not mean anything was wrong with Veilmi.

Closed Testing was simply the next required stage.

---

## 2. I Created the Closed Test and Needed a Real Tester Group

Once I understood that Closed Testing was the next stage, I created a Closed
Testing track for Veilmi.

I decided to use a **Google Group** to control who could access the test.

At first, I tried to enter a group-style email address into Play Console before
I had actually created the Google Group.

Play Console rejected it.

The correct order was:

```text
Create the Google Group

        ↓

Configure the group

        ↓

Add the Google Group address
to the Closed Test in Play Console
```

My tester group is:

```text
veilmi-testers@googlegroups.com
```

### Lesson learned

The Google Group is a real external group.

Typing a group-shaped email address into Play Console does not create the group.

---

## 3. The AAB Uploaded Successfully, but the Release Was Still Blocked

I built and uploaded the signed Veilmi Android App Bundle.

Google Play accepted the AAB and recognized the release correctly.

For a moment, I thought that meant the difficult part was over.

It did not.

The release still could not be submitted.

The problem was not the Android App Bundle.

Google Play was waiting for other required app setup and policy information to
be completed elsewhere in Play Console.

### Lesson learned

A successful AAB upload only means that the Android build itself has been
accepted.

It does not mean that the entire Google Play submission is ready.

---

## 4. Some Requirements Only Became Obvious When They Blocked Submission

Google Play requires several app-information and policy declarations.

Even when a particular feature does not apply to the app, the relevant
declaration may still need to be opened and completed.

One confusing example was the **Advertising ID** declaration.

I had already completed the normal advertising-related questions, but
Advertising ID later appeared as a separate blocking requirement.

The most useful place to look was:

```text
Publishing overview

        ↓

View issues
```

Instead of guessing what might be wrong, I learned to follow the blocking issue
reported by Play Console.

I also had to think carefully about how to describe Veilmi.

Veilmi works alongside messaging apps, but it does not provide its own messaging
service or social network.

### Lesson learned

When Play Console shows a blocker, follow the issue it identifies before
changing the Android project.

The problem may be a declaration or store setting rather than code.

---

## 5. Adding Multiple Store Listing Languages Was More Confusing Than Translating Them

I wanted the Veilmi Store Listing to support:

```text
English (United Kingdom)

Traditional Chinese (Taiwan)

Chinese (Hong Kong)
```

The difficult part was not translating the text.

It was finding the correct place to add ordinary language versions of the Store
Listing.

At one point, I ended up looking at translation services and custom store
listings, neither of which was what I needed.

The normal language versions were managed from the main Store Listing through
its language options.

The Taiwan and Hong Kong listings could share most of the same Traditional
Chinese text.

There was no reason to make the two translations artificially different where
the same wording worked naturally for both.

### Lesson learned

**Store Listing languages**, **translation services**, and **custom store
listings** are different features.

---

## 6. Store Listing Images Can Be Localized Too

The Store Listing needed its own graphics.

I prepared a Play Store version of the Veilmi icon and another promotional image
for the listing.

For the phone screenshots, I used real screenshots of Veilmi so that the store
page would show what the app actually looks like.

When I opened the Chinese Store Listings, the English screenshots initially
appeared faded.

At first, I thought the images could not be changed.

They were simply being inherited from the default language.

After I uploaded the Chinese screenshots, the inherited images were replaced by
the localized versions.

I also discovered that screenshots can be reordered simply by dragging them.

### Lesson learned

A faded Store Listing image may simply be inherited from the default language.

Uploading a localized version replaces the inherited asset.

And screenshot order can be changed by dragging the images.

---

## 7. Saving Changes Was Not the Same as Sending Them to Google

This caused me unnecessary worry during my first release.

```text
Save

≠

Send for review
```

I was initially nervous that saving something or opening
**Publishing overview** might accidentally publish Veilmi.

It did not.

Publishing overview simply collected the changes I had saved and showed which
issues were still blocking submission.

Once all the blocking issues were cleared, the option to send the changes for
review became available.

### Lesson learned

I could safely save my work and inspect Publishing overview without accidentally
publishing Veilmi.

Saving a change and submitting a change are different actions.

---

## 8. I Finally Sent the Closed Test for Review

Once everything was ready, Publishing overview showed **15 changes** waiting to
be submitted.

I sent them for review and confirmed the submission.

The status changed to:

```text
Changes in review
```

That was the confirmation that Veilmi 1.0.0 and its Closed Testing setup had
entered Google's review process.

This was still **not** a public Production release.

It only meant that the Closed Test and its related store and policy changes were
being reviewed.

### Lesson learned

The final review button felt dramatic, but it did not publish Veilmi to
everyone.

It moved the Closed Test to the next stage.

---

## 9. The Closed Test Became Active

After Google's review, the Veilmi Closed Testing track became active.

At that point, I was no longer waiting for Google to review the initial Closed
Test setup.

The next task was to get real people into the test.

I initially thought this part would be simple:

```text
Send somebody a link

        ↓

They install the app
```

It turned out that tester access had its own structure that I still needed to
understand.

This led to several more mistakes.

---

## 10. I Wondered Whether Internal Testing Had to Come First

After the Closed Test became active, I noticed the **Internal Testing** section
in Play Console and started wondering whether I had skipped an important step.

I briefly thought I might need to complete Internal Testing before Closed
Testing could properly begin.

I did not.

Internal Testing and Closed Testing are different testing tracks.

Internal Testing is useful for quickly distributing builds to a small group of
trusted testers, but it is optional.

For my release journey, the qualifying track is Closed Testing.

```text
Internal Testing
Optional for this process

        vs.

Closed Testing
Required for my Production-access path
```

### Lesson learned

Seeing an unfinished Internal Testing section did not mean my Closed Test was
incomplete.

I did not need to go backwards and complete Internal Testing first.

---

## 11. Google Group Membership and Google Play Test Participation Are Different

This was probably the most important tester-access concept I had to understand.

At first, I treated membership in the Veilmi Testers Google Group as if it meant
the user had already joined the Google Play test.

That is not how the process works.

There are two separate stages:

```text
Stage 1

Join the Veilmi Testers Google Group

        ↓

The Google account becomes eligible
to access the Closed Test


Stage 2

Open the Google Play testing opt-in page

        ↓

Choose to become a tester

        ↓

The account actually joins
the Veilmi Closed Test
```

The Google Group answers:

> **Who is allowed to join this test?**

The Google Play opt-in process answers:

> **Has this person actually joined the test?**

A person can therefore be a member of the tester group without yet being an
opted-in Google Play tester.

### Lesson learned

**Eligible tester** and **opted-in tester** are not the same thing.

This distinction matters because the Production-access requirement is based on
testers who are actually opted into the Closed Test.

---

## 12. I Opened the Tester Group So People Could Join Themselves

Originally, I assumed that I would need to collect every tester's Google account
email address and manually add each person to the group.

That would have made public recruitment unnecessarily awkward.

It would also have meant asking strangers on LinkedIn to send me their Google
account information privately.

Instead, I changed the Veilmi Testers Google Group settings so that people on
the web can join the group themselves.

The group page is:

```text
https://groups.google.com/g/veilmi-testers
```

A tester still needs to sign in with a Google account.

They can then open the group and choose **Join group**.

Making the group open does not mean anonymous users automatically become
members.

It means people with Google accounts can add themselves without waiting for me
to manually enter each account.

### Lesson learned

Self-service group membership made public tester recruitment much simpler.

I no longer needed to collect individual tester email addresses manually.

---

## 13. I Confused Three Different Links

Another source of confusion was that several Google URLs were involved in the
testing process, and they looked related.

They had very different purposes.

### Google Group

```text
https://groups.google.com/g/veilmi-testers
```

This is where a tester becomes a member of the Veilmi Testers Google Group.

Group membership makes the Google account eligible for the Closed Test.

### Google Play testing opt-in page

```text
https://play.google.com/apps/testing/com.veilmi.app
```

This is the important page for actually joining the Veilmi Closed Test.

After becoming eligible through the Google Group, the tester opens this page and
chooses **Become a tester**.

### Google Play Store page

```text
https://play.google.com/store/apps/details?id=com.veilmi.app
```

This is Veilmi's normal Google Play Store URL.

Once the user's account has access to the test, this page can be used to view or
install the app.

### Lesson learned

The three URLs perform three separate jobs:

```text
Google Group
→ eligibility

/apps/testing/
→ opt into the test

/store/apps/details
→ view or install the app
```

The `/apps/testing/` URL is the important opt-in link for joining the test.

---

## 14. The Complete Tester Onboarding Flow Finally Made Sense

After making several mistakes and testing the process again, I finally understood
the full onboarding flow.

A new Veilmi tester should:

```text
1. Sign in to the Google account
   used with Google Play

        ↓

2. Open the Veilmi Testers Google Group

https://groups.google.com/g/veilmi-testers

        ↓

3. Choose "Join group"

        ↓

4. Open the Veilmi Google Play
   Closed Test opt-in page

https://play.google.com/apps/testing/com.veilmi.app

        ↓

5. Choose "Become a tester"

        ↓

6. Install Veilmi from Google Play

        ↓

7. Remain opted in
   for at least 14 continuous days
```

The same Google account should be used for the Google Group membership and the
Google Play test.

I added these instructions to the main Veilmi README so that future testers do
not need to discover the same process by trial and error.

### Lesson learned

Tester onboarding is part of the release experience too.

If the process confused me as the developer, it could easily confuse someone
who is only volunteering a few minutes of their time to help.

The instructions therefore need to be simple and explicit.

---

## 15. The Real Closed Test Begins Here

Getting the Closed Testing track active was not the end of the testing process.

It was the beginning of the real test.

For my account, I need at least **12 testers** to remain continuously opted into
the Closed Test for at least **14 days** before I can apply for Production
access.

I do not want those 14 days to be only a countdown.

I would also like testers to actually use Veilmi and help me find problems that
I did not notice while developing it myself.

I added testing suggestions to the Veilmi README.

For example, testers can try:

* encrypting and decrypting different messages;
* exchanging an encrypted message with another Veilmi user;
* trying different protection levels;
* copying encrypted text into another communication app and back into Veilmi;
* testing long messages;
* testing unusual characters;
* testing emoji;
* testing different languages;
* looking for confusing interface text or instructions;
* reporting unexpected behaviour;
* and reporting possible security problems.

Problems can be reported through the Veilmi GitHub Issues page:

```text
https://github.com/noa-jou/Veilmi/issues
```

Even a small observation can be useful.

### Lesson learned

The 14-day requirement should not only be treated as an administrative hurdle.

It is also an opportunity to let real people use Veilmi, collect feedback, fix
problems, and improve the app before a public release.

---

## Current Status

As of **16 September 2026**:

```text
Veilmi 1.0.0

        ↓

Closed Test active

        ↓

Veilmi Testers Google Group
open for testers to join

        ↓

Recruit at least 12 testers

        ↓

Each tester:

Join Google Group

        ↓

Opt into Google Play Closed Test

        ↓

Install Veilmi

        ↓

Use and test the app

        ↓

Remain continuously opted in
for at least 14 days

        ↓

Collect feedback
and fix problems

        ↓

Apply for Production access

        ↓

Future goal:

Public Google Play release
```

The first Google Play release journey is therefore no longer waiting for the
initial Closed Test review.

It has moved into the **real Closed Testing stage**.

Getting the Closed Test approved was not the end of the release process.

**It was the beginning of the real testing process.**

I will continue updating this document as Veilmi moves toward Production.

---

## Useful Official Google Play Documentation

* [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152)

* [Set up an open, closed, or internal test](https://support.google.com/googleplay/android-developer/answer/9845334)

* [Testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)

* [Control when app changes are reviewed and published](https://support.google.com/googleplay/android-developer/answer/9859654)

* [Create a group and choose Google Groups settings](https://support.google.com/groups/answer/2464926)


