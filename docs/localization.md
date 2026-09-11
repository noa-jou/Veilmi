# Localization

Veilmi currently supports two interface languages:

- English (`en`)
- Traditional Chinese (`zh_Hant`)

English is the default language.

Users can switch languages directly from the Home screen, and the selected
language is saved locally for future launches.

---

## Files

Veilmi's localization files are located in:

```text
lib/l10n/
├── app_en.arb
├── app_zh_Hant.arb
└── app_localizations.dart
```

### English

```text
app_en.arb
```

uses:

```json
"@@locale": "en"
```

### Traditional Chinese

```text
app_zh_Hant.arb
```

uses:

```json
"@@locale": "zh_Hant"
```

Veilmi explicitly uses `zh_Hant` for Traditional Chinese rather than a generic
Chinese locale.

---

## AppLocalizations

Veilmi-specific interface text is loaded by:

```text
lib/l10n/app_localizations.dart
```

The loader selects the appropriate ARB file according to the active Flutter
locale.

Conceptually:

```text
English locale
     ↓
app_en.arb
     ↓
AppLocalizations
     ↓
Veilmi UI
```

and:

```text
Traditional Chinese locale
     ↓
app_zh_Hant.arb
     ↓
AppLocalizations
     ↓
Veilmi UI
```

Screens access translated strings through:

```dart
final l10n = AppLocalizations.of(context)!;
```

For example:

```dart
Text(l10n.encrypt);
Text(l10n.decrypt);
Text(l10n.settings);
```

Strings containing variables are exposed as methods.

For example:

```dart
l10n.protection(level);
```

uses strings such as:

```json
"protection": "Protection: {level}"
```

and:

```json
"protection": "保護等級：{level}"
```

---

## Flutter Framework Localization

Some text displayed inside the app belongs to Flutter rather than Veilmi.

Examples include text-selection actions such as:

```text
Cut
Copy
Paste
Select all
```

Veilmi uses Flutter's localization delegates for framework-provided interface
text:

```dart
GlobalMaterialLocalizations.delegate
GlobalWidgetsLocalizations.delegate
GlobalCupertinoLocalizations.delegate
```

Traditional Chinese is represented with:

```dart
const Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hant',
)
```

This allows both Veilmi and Flutter framework components to use the same
Traditional Chinese locale.

---

## Saving the Selected Language

Language preferences are handled by:

```text
lib/settings/settings_service.dart
```

The selected value is saved locally with `SharedPreferences`.

Supported stored values are:

```text
en
zh_Hant
```

If no valid language preference exists, Veilmi uses English.

---

## Startup Flow

When Veilmi starts:

```text
App starts
    ↓
SettingsService loads language_code
    ↓
en or zh_Hant
    ↓
Convert to Flutter Locale
    ↓
VeilmiApp receives the locale
    ↓
MaterialApp uses the locale
    ↓
AppLocalizations loads the matching ARB file
```

For English:

```dart
const Locale('en')
```

For Traditional Chinese:

```dart
const Locale.fromSubtags(
  languageCode: 'zh',
  scriptCode: 'Hant',
)
```

---

## Runtime Language Switching

The language button is located in the Home screen app bar.

When English is active, the button displays:

```text
中文
```

When Traditional Chinese is active, it displays:

```text
EN
```

When the user changes language:

```text
User presses language button
        ↓
Save new language preference
        ↓
Create the corresponding Locale
        ↓
Update VeilmiApp locale
        ↓
MaterialApp rebuilds
        ↓
UI changes language immediately
```

No application restart is required.

---

## Adding or Editing Translations

To edit English text:

```text
lib/l10n/app_en.arb
```

To edit Traditional Chinese text:

```text
lib/l10n/app_zh_Hant.arb
```

The two files should contain matching application keys.

For example:

```json
"checkThisDevice": "Check This Device"
```

and:

```json
"checkThisDevice": "檢查這台裝置"
```

When adding a new localization key, also expose it through:

```text
lib/l10n/app_localizations.dart
```

For example, if both ARB files add:

```json
"privacyPolicy": "Privacy Policy"
```

and:

```json
"privacyPolicy": "隱私權政策"
```

then `AppLocalizations` should also contain:

```dart
String get privacyPolicy => _text('privacyPolicy');
```

---

## Architecture Summary

```text
                 ┌─────────────────────┐
                 │   SettingsService   │
                 │    en / zh_Hant     │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │     MaterialApp     │
                 │        locale       │
                 └──────────┬──────────┘
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
    ┌──────────────────┐       ┌──────────────────────┐
    │ AppLocalizations │       │ Flutter localization │
    │                  │       │ delegates             │
    └────────┬─────────┘       └──────────┬───────────┘
             │                            │
      ┌──────┴──────┐                     │
      ▼             ▼                     ▼
 app_en.arb   app_zh_Hant.arb     Material / Widgets /
                                  Cupertino interface
```

Veilmi-specific text is maintained in the ARB files, while Flutter framework
components use Flutter's localization support with the same active locale.