# Project Renaming Notes

This document records a one-time cleanup that happened after the project was
renamed from:

```text
Veil
```

to:

```text
Veilmi
```

The application had already been renamed, but some local Android Studio /
IntelliJ files still contained the old project name.

This did not mean that the real application was still called Veil.

The remaining names were mainly local IDE metadata left from an earlier stage
of development.

---

## The Old Module File

One local file was still named:

```text
veil.iml
```

An `.iml` file is used by Android Studio and IntelliJ to describe a project
module.

It is not part of the Veilmi application itself.

I checked whether Git was intentionally ignoring it:

```bash
git check-ignore -v veil.iml
```

The result showed that `.gitignore` contains:

```gitignore
*.iml
```

so the file was only local IDE information.

I renamed it:

```bash
mv veil.iml veilmi.iml
```

---

## Updating the IDE Reference

After renaming the file, I checked whether Android Studio still referred to the
old filename:

```bash
grep -R "veil.iml" .idea 2>/dev/null
```

This found a reference inside:

```text
.idea/modules.xml
```

The old entry referred to:

```text
veil.iml
```

so I updated it to:

```text
veilmi.iml
```

This made the module filename and the IDE configuration match again.

---

## The Android Module File

There was also an Android module file using the old name:

```text
android/veil_android.iml
```

I renamed it to:

```text
android/veilmi_android.iml
```

and updated the matching reference inside:

```text
.idea/modules.xml
```

---

## Other Old IDE Names

I searched the `.idea` directory for other old references:

```bash
grep -Rni "veil" .idea 2>/dev/null
```

This also found older names inside:

```text
.idea/workspace.xml
```

including:

```text
Veil
Veil.app
```

These were local workspace and module names.

I updated them to match the current Veilmi name.

---

## Checking the Cleanup

Because the word `Veilmi` itself contains `veil`, a general search for `veil`
will still find valid Veilmi references.

A more precise check for the old names is:

```bash
grep -RniE \
  'veil\.iml|veil_android\.iml|name="Veil"|name="Veil\.app"' \
  .idea 2>/dev/null
```

If this produces no output, those specific old IDE names are gone.

---

## What This Did Not Change

This cleanup only changed local IDE metadata.

It did not change the actual Android Application ID:

```text
com.veilmi.app
```

It did not change the public application name:

```text
Veilmi
```

and it did not change Veilmi's source code or cryptographic behavior.

For that reason, cleaning up these `.iml` and `.idea` names did not require a
new Android App Bundle.

---

## Why I Recorded This

This is not something I expect to do regularly.

Normally, `.iml` and `.idea` files can simply be managed by the IDE.

I recorded this because Veilmi happened to begin under an earlier project name,
so some local development files continued to use the old name after the
application itself had been renamed.

The important lesson was:

```text
Application identity
    ↓
Veilmi
com.veilmi.app

Local IDE metadata
    ↓
.iml
.idea/
workspace and module names
```

An old name inside IDE metadata does not necessarily mean that the application
itself has the wrong name.

In this case, I changed the local IDE names simply to keep the development
environment consistent with the current project name.