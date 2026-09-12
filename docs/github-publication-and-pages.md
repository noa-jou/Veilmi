# Publishing the Veilmi Repository and GitHub Pages

This document records how Veilmi was prepared for public release on GitHub and
how the project documentation was published with GitHub Pages.

The goal is to explain both:

- what should be checked before making a repository public;
- how the `docs/` folder becomes a public documentation website.

---

## 1. Why Check the Repository Before Making It Public?

A private repository can contain files that are visible only to the repository
owner and collaborators.

After changing it to public:

```text
Private repository
        ↓
Change visibility
        ↓
Public repository
        ↓
Anyone can read the tracked files
```

Therefore, before publishing Veilmi, it is important to check that sensitive
information is not accidentally stored in the repository.

Examples of things that should not be public include:

```text
signing keys
keystore files
passwords
API keys
tokens
private configuration files
personal device serial numbers
personal machine paths
```

---

## 2. Check the Git Working Tree

First, check whether there are uncommitted changes:

```bash
git status
```

A clean result looks like:

```text
nothing to commit, working tree clean
```

This makes it easier to understand exactly what version is about to become
public.

---

## 3. Check for Signing Files

Before Veilmi was made public, the project was searched for Android signing
files.

For example:

```bash
find . \
  -path './.git' -prune -o \
  -path './build' -prune -o \
  -path './.dart_tool' -prune -o \
  \( -name "*.jks" -o -name "*.keystore" -o -name "key.properties" \) \
  -print
```

Sensitive signing files include:

```text
*.jks
*.keystore
key.properties
```

These should not be committed to the public repository.

Veilmi's `.gitignore` also excludes these files.

---

## 4. Search Tracked Files for Possible Secrets

A useful Git-specific search is:

```bash
git grep -nEi \
  "password|api[_-]?key|secret|token|private[_-]?key|client[_-]?secret"
```

This command searches files that are tracked by Git.

A match does **not** automatically mean that a secret has been exposed.

For example, Veilmi contains normal technical words such as:

```text
SecretKey
password
private key
API secrets
```

because the project discusses cryptography.

The purpose of the search is to manually review suspicious matches.

The important question is:

> Is this a real credential or secret value, or is it only documentation or
> source-code terminology?

---

## 5. Check for Sensitive File Types

Another useful check is:

```bash
git ls-files | grep -Ei \
  '\.(jks|keystore|pem|p12|pfx)$|key\.properties$|\.env$'
```

Ideally, this produces no output.

It checks whether Git is currently tracking common sensitive file types.

---

## 6. Check Git History Too

Deleting a sensitive file from the current working tree is not always enough.

If the file was previously committed, it may still exist in Git history.

A simple filename check is:

```bash
git log --all --name-only --pretty=format: |
grep -Ei \
  '\.(jks|keystore|pem|p12|pfx)$|key\.properties$|\.env$' |
sort -u
```

Ideally, this also produces no output.

This does not replace a full secret-scanning system, but it is a useful
beginner-friendly check before making a repository public.

---

## 7. Check for Personal Machine Information

Public developer documentation should avoid exposing unnecessary personal
machine information.

For example:

```bash
git grep -nEi '/home/|device serial|serial number'
```

Safe generic paths include:

```text
~/Android/Sdk
$HOME/Android/Sdk
```

because they do not reveal the actual Linux username.

A path such as:

```text
/home/real-user-name/...
```

would reveal more personal information and is better avoided in public
documentation.

The same principle applies to real phone serial numbers.

---

## 8. Making the Repository Public

After checking the repository, its visibility can be changed on GitHub.

The GitHub path is:

```text
Veilmi repository
    ↓
Settings
    ↓
General
    ↓
Danger Zone
    ↓
Change repository visibility
    ↓
Public
```

GitHub asks for confirmation before the change is completed.

Once a repository becomes public:

```text
source code
documentation
commit history
Actions history
```

can be visible to other GitHub users.

Anyone can also fork a public repository.

---

## 9. What Is GitHub Pages?

GitHub Pages turns files from a GitHub repository into a public website.

For Veilmi, the source is:

```text
main branch
    ↓
docs/ folder
    ↓
GitHub Pages
```

This means files inside:

```text
docs/
```

can be presented as web pages instead of requiring readers to browse raw
repository files.

For example:

```text
docs/README.md
```

becomes the documentation website's main page.

---

## 10. Why Use GitHub Pages?

Without GitHub Pages, documentation may be viewed through URLs such as:

```text
https://github.com/noa-jou/Veilmi/blob/main/docs/privacy-policy.md
```

That works, but it looks like a source-code file.

GitHub Pages provides cleaner public URLs.

For Veilmi:

```text
https://noa-jou.github.io/Veilmi/
```

is the documentation homepage.

The Privacy Policy can have a cleaner URL such as:

```text
https://noa-jou.github.io/Veilmi/privacy-policy/
```

This is more suitable for:

```text
About screen links
Google Play Privacy Policy
public documentation
```

---

## 11. Preparing the `docs/` Folder

GitHub Pages needs an entry file at the top level of the publishing source.

GitHub supports entry files such as:

```text
index.html
index.md
README.md
```

Veilmi already uses:

```text
docs/README.md
```

as the documentation homepage.

The structure is approximately:

```text
docs/
├── README.md
├── android-device-testing.md
├── android-release-signing.md
├── chromebook-flutter-environment.md
├── crypto-notes.md
├── crypto-design-and-future.md
├── localization.md
└── privacy-policy.md
```

---

## 12. Adding a Clean Privacy Policy URL

Veilmi's Privacy Policy is stored in:

```text
docs/privacy-policy.md
```

At the top of this file, Veilmi uses **Jekyll front matter**:

```markdown
---
permalink: /privacy-policy/
---
```

### What Is Jekyll Front Matter?

**Jekyll** is a static site generator that can be used by GitHub Pages to turn
Markdown files into web pages.

**Front matter** is a small configuration block placed at the very beginning
of a Markdown file. It starts and ends with three dashes:

```text
---
page settings go here
---
```

These settings tell Jekyll how to handle the page. They are not part of the
Privacy Policy that visitors read.

For example, front matter can contain information such as a page title,
layout, or URL.

Veilmi currently needs only one setting:

```yaml
permalink: /privacy-policy/
```

### What Is a Permalink?

A **permalink** means the permanent public path assigned to a web page.

In this case:

```yaml
permalink: /privacy-policy/
```

tells Jekyll that this Markdown file should be available at the
`/privacy-policy/` path of the Veilmi documentation website.

The result is:

```text
File:
docs/privacy-policy.md

GitHub Pages site:
https://noa-jou.github.io/Veilmi/

Permalink:
                 /privacy-policy/
                          ↓
Final URL:
https://noa-jou.github.io/Veilmi/privacy-policy/
```

Therefore, the beginning of the actual file looks like:

```markdown
---
permalink: /privacy-policy/
---

# Veilmi Privacy Policy
```

A simple way to remember the two terms is:

```text
Jekyll front matter = settings for the web page
permalink            = the public path chosen for that page
```

This gives Veilmi a clean Privacy Policy URL that can be used both inside the
app and for Google Play.

---

## 13. Enable GitHub Pages

After the repository is public, GitHub Pages can be enabled from the repository
settings.

The GitHub path is:

```text
Veilmi repository
    ↓
Settings
    ↓
Pages
```

Under:

```text
Build and deployment
```

choose:

```text
Source:
Deploy from a branch
```

Then select:

```text
Branch:
main

Folder:
/docs
```

and save the settings.

Conceptually:

```text
main branch
     ↓
docs/
     ↓
GitHub Pages build
     ↓
public website
```

GitHub currently supports publishing Pages directly from a selected branch and
folder such as `main` + `/docs`.

---

## 14. Wait for the First Deployment

The site may not appear immediately after enabling GitHub Pages.

GitHub needs time to build and deploy it.

During this period, a URL such as:

```text
https://noa-jou.github.io/Veilmi/
```

may temporarily return:

```text
404
```

This does not necessarily mean that the URL is wrong.

The deployment should be checked after GitHub finishes the Pages build.

GitHub notes that Pages changes can take several minutes to appear.

---

## 15. GitHub Pages Uses GitHub Actions

GitHub Pages deployments appear as workflow runs.

After a push, GitHub may automatically run something similar to:

```text
pages build and deployment
```

The flow is:

```text
git push
    ↓
GitHub detects docs changes
    ↓
Pages build runs
    ↓
website is updated
```

This is why updating documentation can trigger GitHub Actions notifications.

---

## 16. Reduce GitHub Actions Email Notifications

GitHub may email the account owner after successful workflow runs.

If successful Pages deployment emails become repetitive, GitHub notification
settings can be changed.

Go to:

```text
GitHub account
    ↓
Settings
    ↓
Notifications
    ↓
System
    ↓
Actions
```

A useful option is:

```text
Only notify for failed workflows
```

With this setting:

```text
successful Pages deployment
    → no email

failed Pages deployment
    → notification
```

This keeps failure warnings without receiving an email after every successful
documentation update.

---

## 17. Repository vs GitHub Pages URLs

Veilmi now uses two different kinds of public URLs.

### GitHub Repository

For source code and the main project overview:

```text
https://github.com/noa-jou/Veilmi
```

This is where readers can find:

```text
source code
main README
Issues
commit history
license
```

### GitHub Pages

For documentation:

```text
https://noa-jou.github.io/Veilmi/
```

This is where readers can browse the contents of:

```text
docs/
```

The two sites have different purposes:

```text
GitHub repository
    = project and source code

GitHub Pages
    = readable documentation website
```

This is why the documentation homepage should not assume that:

```text
../README.md
```

will lead to the repository's main README.

Instead, the documentation can link directly to:

```text
https://github.com/noa-jou/Veilmi
```

---

## 18. Privacy Policy Flow

Veilmi's Privacy Policy now follows this path:

```text
docs/privacy-policy.md
        ↓
GitHub Pages
        ↓
https://noa-jou.github.io/Veilmi/privacy-policy/
        ↓
Veilmi About screen
        ↓
Privacy Policy button
```

The same public URL can also be used later in Google Play Console.

This keeps the Privacy Policy location consistent between:

```text
GitHub Pages
Veilmi app
Google Play
```

---

## 19. Updating the Documentation Website

Once GitHub Pages is configured, there is no need to manually upload the
website again.

The normal Git workflow is enough:

```bash
git add .
git commit -m "Update documentation"
git push
```

After the push:

```text
GitHub Pages
    ↓
builds the new documentation
    ↓
publishes the updated website
```

---

## 20. A Simple Mental Model

The whole process can be remembered like this:

```text
Private Veilmi repository
        ↓
Check secrets and personal information
        ↓
Make repository public
        ↓
Enable GitHub Pages
        ↓
Publish main:/docs
        ↓
GitHub Actions builds the Pages site
        ↓
https://noa-jou.github.io/Veilmi/
```

Or more simply:

```text
Check
 ↓
Public
 ↓
Pages
 ↓
Docs website
```

---

## 21. Public Release Checklist

Before making a future repository public:

```text
[ ] Run git status
[ ] Check for keystores and private configuration files
[ ] Search tracked files for possible credentials
[ ] Check sensitive file types
[ ] Review Git history for sensitive filenames
[ ] Check documentation for personal paths or device serial numbers
[ ] Confirm .gitignore protects secrets
[ ] Make the repository public
```

For GitHub Pages:

```text
[ ] Keep an entry file in docs/
[ ] Configure Pages to Deploy from a branch
[ ] Select main
[ ] Select /docs
[ ] Wait for the first Pages deployment
[ ] Test the documentation homepage
[ ] Test the Privacy Policy URL
[ ] Keep the repository and documentation URLs separate
```