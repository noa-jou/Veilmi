# Google Play Release Log

This is a dated record of my first Google Play release journey for **Veilmi**.

It is not a field-by-field Play Console guide. I want this file to help my future
self remember:

- where the project had reached;
- what blocked progress;
- what I misunderstood;
- and how I solved each problem.

Google Play Console changes over time, so exact page names and buttons may also
change.

---

## 2026-09-11 — Preparing Veilmi for Release

### Progress

Before dealing with Google Play, I first made sure Veilmi itself was ready for a
real Android release.

```text
flutter analyze
→ no issues

flutter test
→ all 22 tests passed
```

I then prepared proper release signing instead of relying on the normal debug
signing used during development.

The private upload keystore and passwords were kept outside the public GitHub
repository.

Finally, I built the release Android App Bundle:

```text
flutter build appbundle --release
```

This produced the signed `.aab` file that I would later upload to Google Play.

### What I learned

A project working in Debug mode is not enough.

Before worrying about the Play Console, I wanted to know that the real release
build could actually be produced successfully.

---

## 2026-09-12 to 2026-09-13 — Waiting for Google Verification and Preparing the Public Release

### Progress

I had already submitted the required developer-account and identity information
to Google.

At this point, part of the release process had to wait for Google to finish
reviewing my developer identity.

```text
Developer account created
        ↓
Identity information submitted
        ↓
Waiting for Google review
        ↓
Identity verification approved
        ↓
Phone verification completed
```

There was nothing useful to fix in the Android project while the account review
was still pending.

So instead of repeatedly checking the Console, I used the waiting time to prepare
the public side of the release.

### What I prepared while waiting

I worked on:

```text
public documentation
        +
Privacy Policy
        +
English screenshots
        +
Traditional Chinese screenshots
        +
Play Store icon
        +
a new promotional feature graphic
```

The documentation explained what Veilmi does, how its cryptography works, and
what its protection does **not** cover.

For the phone screenshots, I used real Veilmi screens rather than promotional
mockups.

### Result

By the time the developer verification was complete, both sides were ready:

```text
Technical side
→ signed Android release bundle ready

Public side
→ documentation ready
→ Privacy Policy ready
→ screenshots ready
→ store graphics ready
```

The next challenge was no longer building Veilmi.

It was understanding Google Play Console.

---

## 2026-09-14 — First Closed Test Submission

### Progress

My developer identity and phone verification were complete, so I could finally
continue with the actual Play Console release setup.

This was the day when most of the confusing Google Play problems appeared.

---

### Problem: I could not go straight to Production

I originally expected that once the app was ready, I could publish it.

Instead, my account required a **Closed Test** before I could later apply for
Production access.

The requirement was:

```text
At least 12 testers
        +
continuously opted in
for at least 14 days
```

### Solution

I stopped trying to reach Production immediately and created a Closed Testing
track for Veilmi.

This did not mean anything was wrong with the app.

Closed Testing was simply the next required stage.

---

### Problem: Play Console would not accept my tester group

I wanted to use a Google Group for testers.

At first, I entered a group-style email address before the Google Group actually
existed.

Play Console rejected it.

### Solution

The correct order was:

```text
Create the Google Group
        ↓
Configure it
        ↓
Return to Play Console
        ↓
Add it to the Closed Test
```

Play Console does not create the Google Group automatically.

---

### Problem: The AAB uploaded successfully, but submission was still blocked

Google Play accepted the signed Android App Bundle.

For a moment, I thought the hard part was over.

It was not.

Other app-information and policy requirements were still incomplete.

One example was the **Advertising ID declaration**, which appeared later as a
separate blocker.

### Solution

Instead of changing the Android project, I learned to follow the problem shown by
Play Console:

```text
Cannot submit?
        ↓
Publishing overview
        ↓
View issues
        ↓
Fix the exact blocker
```

A successful AAB upload only means the build itself was accepted.

It does not mean the whole Google Play submission is ready.

---

### Problem: Store Listing languages and images were confusing

I wanted the Store Listing to support:

```text
English (UK)
Traditional Chinese (Taiwan)
Chinese (Hong Kong)
```

The translation itself was easy.

The confusing part was finding the normal language selector instead of ending up
in translation services or custom store listings.

The Chinese Store Listings also showed the English screenshots in a faded state,
which initially looked as though they could not be changed.

### Solution

I used the normal Store Listing language selector.

The Taiwan and Hong Kong listings could share most of the same Traditional
Chinese wording.

The faded screenshots were simply inherited from the default English listing.
Uploading the Chinese screenshots replaced them.

I also discovered that screenshot order could be changed by dragging the images.

---

### Problem: I was afraid that saving changes might publish the app

These actions were not the same:

```text
Save
≠
Send for review
```

and:

```text
Open Publishing overview
≠
Publish to Production
```

### Solution

I learned that Publishing overview is mainly where saved changes are collected,
blocking problems are shown, and the final review submission is made.

Once the blockers were cleared, I sent **15 changes** for review.

The status changed to:

```text
Changes in review
```

### Result

Veilmi 1.0.0 had officially entered Google's review process for **Closed
Testing**.

It was still not a public Production release.

---

## 2026-09-16 — Closed Test Became Active

### Progress

Google finished the initial review and the Veilmi Closed Test became active.

The release had moved from:

```text
Prepare the Closed Test
```

to:

```text
Find real testers
and run the test
```

---

### Problem: I wondered whether Internal Testing had to come first

Seeing the unfinished Internal Testing section made me worry that I had skipped
a required step.

### Solution

I learned that Internal Testing and Closed Testing are separate tracks.

Internal Testing can be useful, but it was not required before my Closed Test.

I did not need to go backwards.

---

### Problem: Google Group membership was not the same as joining the test

This was probably the most important tester-access concept I had to understand.

A person could join the Veilmi Testers Google Group and still not be an opted-in
Google Play tester.

### Solution

I separated the onboarding flow into two stages:

```text
Join Google Group
        ↓
Become eligible for the test
        ↓
Open Google Play opt-in page
        ↓
Choose "Become a tester"
        ↓
Actually join the Closed Test
```

The same Google account should be used for both steps.

---

### Problem: There were too many related links

Several Google URLs looked similar but had different jobs.

### Solution

I reduced them to three purposes:

```text
Google Group
→ become eligible

Google Play /apps/testing/ page
→ opt into the Closed Test

Google Play Store page
→ view or install Veilmi
```

That made the process much easier to explain to testers.

---

### Problem: Manually collecting tester email addresses was awkward

I did not want to ask strangers to send me their Google account email just so I
could add them one by one.

### Solution

I changed the Veilmi Testers Google Group so people could join it themselves.

I also added simple tester instructions to the Veilmi README.

### Result

At this point, the technical Closed Testing setup was basically finished.

The remaining problem was no longer Google Play Console.

It was finding enough real people who genuinely wanted to test Veilmi.

---

## 2026-09-19 — Pausing Tester Recruitment

### Progress

The Veilmi Closed Test is still active and available.

The app, Play Console setup, tester group, and onboarding instructions are all
ready.

However, I have **not found 12 genuine testers** who are willing to join the
Closed Test and remain opted in for the required period.

### Decision

I do not want to chase people simply to fill a number.

There is no project deadline forcing me to complete this stage immediately, so I
am leaving the Closed Test where it is and moving on to other work for now.

```text
Veilmi Closed Test
        ↓
Still available
        ↓
Not enough real testers yet
        ↓
Pause recruitment
        ↓
Work on other things
        ↓
Return when I am ready
```

This is not a cancelled release.

I can continue from this point later instead of starting again.

---

## Current Status — 2026-09-19

```text
Veilmi 1.0.0
        ↓
Release build completed
        ↓
Developer verification completed
        ↓
Closed Test approved and active
        ↓
Tester onboarding understood
        ↓
12 qualifying testers not yet reached
        ↓
Release work paused for now
```

Veilmi is **not yet publicly available in Production**.

The next Google Play milestone remains:

```text
12 testers
        ↓
remain opted in for at least 14 continuous days
        ↓
apply for Production access
```

For now, I am intentionally leaving that milestone for later and focusing on
other work.

---

## Useful Official Google Play Documentation

- [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152)
- [Set up an open, closed, or internal test](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465)
- [Control when app changes are reviewed and published](https://support.google.com/googleplay/android-developer/answer/9859654)
- [Create a group and choose Google Groups settings](https://support.google.com/groups/answer/2464926)
