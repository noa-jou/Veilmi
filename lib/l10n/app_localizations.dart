import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// This file is the language helper for the whole app.
// It is generated from the ARB files in lib/l10n, and it gives Flutter a way to:
// - load the current locale,
// - use the right translation file,
// - and access text like AppLocalizations.of(context)!.encrypt.
//
// For a beginner:
// - this file acts like a translation dictionary,
// - each getter returns one text value,
// - and Flutter chooses the correct language automatically.
class AppLocalizations {
  AppLocalizations._(this.locale, this._messages);

  final Locale locale;
  final Map<String, dynamic> _messages;

  // These are the supported languages for the app.
  static const Locale englishLocale = Locale('en');

  // Traditional Chinese uses a languageCode + scriptCode combination.
  // This is the app's supported Chinese locale.
  static const Locale traditionalChineseLocale = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  static const List<Locale> supportedLocales = [
    englishLocale,
    traditionalChineseLocale,
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // These delegates tell Flutter how to load the proper localized data.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // This is the usual Flutter way to get localization data from the current context.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Read one translation value from the message map.
  // If the key is missing, throw a clear error so the problem is easy to debug.
  String _text(String key) {
    final value = _messages[key];

    if (value is String) {
      return value;
    }

    throw StateError(
      'Missing localization value for "$key" in ${locale.toLanguageTag()}.',
    );
  }

  // Replace placeholder values inside a string.
  // Example: "Hello {name}" becomes "Hello Ada".
  String _replace(String key, Map<String, String> replacements) {
    var value = _text(key);

    for (final entry in replacements.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }

    return value;
  }

  // These getters return the translated strings used by the app.
  // Each one reads a text key from the language JSON file.
  String get appTitle => _text('appTitle');
  String get settings => _text('settings');

  String get encrypt => _text('encrypt');
  String get decrypt => _text('decrypt');

  String get protectMessage => _text('protectMessage');
  String get openProtectedMessage => _text('openProtectedMessage');

  String get encryptDescription => _text('encryptDescription');
  String get decryptDescription => _text('decryptDescription');

  String get message => _text('message');
  String get encryptedMessage => _text('encryptedMessage');
  String get decryptedMessage => _text('decryptedMessage');

  String get messageHint => _text('messageHint');
  String get encryptedMessageHint => _text('encryptedMessageHint');

  String get clear => _text('clear');

  String get sharedPassphrase => _text('sharedPassphrase');
  String get passphraseHint => _text('passphraseHint');

  String protection(String level) {
    return _replace('protection', {'level': level});
  }

  String get protectionReadFromMessage => _text('protectionReadFromMessage');

  String get encrypting => _text('encrypting');
  String get decrypting => _text('decrypting');

  String get encryptMessage => _text('encryptMessage');
  String get decryptMessage => _text('decryptMessage');

  String get copyEncryptedMessage => _text('copyEncryptedMessage');
  String get copyDecryptedMessage => _text('copyDecryptedMessage');

  String get encryptedMessageCopied => _text('encryptedMessageCopied');
  String get decryptedMessageCopied => _text('decryptedMessageCopied');

  String get enterMessageAndPassphrase => _text('enterMessageAndPassphrase');

  String get enterEncryptedMessageAndPassphrase =>
      _text('enterEncryptedMessageAndPassphrase');

  String get encryptionFailed => _text('encryptionFailed');
  String get invalidEncryptedMessage => _text('invalidEncryptedMessage');

  String get decryptionAuthenticationFailed =>
      _text('decryptionAuthenticationFailed');

  String get decryptionFailed => _text('decryptionFailed');

  String get protectionLevel => _text('protectionLevel');

  String get protectionLevelDescription => _text('protectionLevelDescription');

  String get compatibility => _text('compatibility');
  String get compatibilitySummary => _text('compatibilitySummary');

  String get balanced => _text('balanced');
  String get balancedSummary => _text('balancedSummary');

  String get stronger => _text('stronger');
  String get strongerSummary => _text('strongerSummary');

  String get protectionDeviceCheck => _text('protectionDeviceCheck');

  String get protectionDeviceCheckDescription =>
      _text('protectionDeviceCheckDescription');

  String get deviceCheckTitle => _text('deviceCheckTitle');

  String get howProtectionWorks => _text('howProtectionWorks');

  String get lockedDoor => _text('lockedDoor');

  String get sharedPassphraseKey => _text('sharedPassphraseKey');

  String get lockTurns => _text('lockTurns');

  String get moreTurnsHarderGuessing => _text('moreTurnsHarderGuessing');

  String get moreTurnsMoreWork => _text('moreTurnsMoreWork');

  String get otherPhoneSameWork => _text('otherPhoneSameWork');

  String get threeProtectionLevels => _text('threeProtectionLevels');

  String get compatibilityDeviceDescription =>
      _text('compatibilityDeviceDescription');

  String get balancedDeviceDescription => _text('balancedDeviceDescription');

  String get strongerDeviceDescription => _text('strongerDeviceDescription');

  String get whichLevelFits => _text('whichLevelFits');

  String get deviceCheckDescription => _text('deviceCheckDescription');

  String get checkingDevice => _text('checkingDevice');
  String get checking => _text('checking');

  String get checkThisDevice => _text('checkThisDevice');

  String get deviceCheckFailed => _text('deviceCheckFailed');

  String get recommendedForDevice => _text('recommendedForDevice');

  String pbkdf2Implementation(String implementation) {
    return _replace('pbkdf2Implementation', {'implementation': implementation});
  }

  String protectionTime(String level, String seconds) {
    return _replace('protectionTime', {'level': level, 'seconds': seconds});
  }

  String turns(String count) {
    return _replace('turns', {'count': count});
  }

  String get aboutVeilmi => _text('aboutVeilmi');

  String get openSource => _text('openSource');

  String get openSourceDescription => _text('openSourceDescription');

  String get docsDescription => _text('docsDescription');

  String get viewOnGitHub => _text('viewOnGitHub');

  String get readDocumentation => _text('readDocumentation');

  String get supportVeilmi => _text('supportVeilmi');

  String get supportDescription => _text('supportDescription');

  String get couldNotOpenLink => _text('couldNotOpenLink');

  String get deviceCheckWarning => _text('deviceCheckWarning');

  String get privacy => _text('privacy');

  String get privacyDescription => _text('privacyDescription');

  String get privacyPolicy => _text('privacyPolicy');
}

// This delegate tells Flutter which language file to load for a locale.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // English is always supported.
    if (locale.languageCode == 'en') {
      return true;
    }

    // Traditional Chinese is also supported.
    // We specifically allow zh + Hant, which matches the app's locale settings.
    return locale.languageCode == 'zh' && locale.scriptCode == 'Hant';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final String assetPath;

    if (locale.languageCode == 'zh' && locale.scriptCode == 'Hant') {
      assetPath = 'lib/l10n/app_zh_Hant.arb';
    } else {
      assetPath = 'lib/l10n/app_en.arb';
    }

    // Load the JSON file that contains all text for the selected language.
    final jsonString = await rootBundle.loadString(assetPath);

    final decoded = jsonDecode(jsonString);

    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid localization file: $assetPath');
    }

    return AppLocalizations._(locale, decoded);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) {
    return false;
  }
}
