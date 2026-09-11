import 'package:shared_preferences/shared_preferences.dart';

import '../crypto/protection_level.dart';

// This service stores small user preferences in the device's local storage.
// It uses SharedPreferences, which is a simple key-value database for Flutter apps.
//
// In beginner terms:
// - remember which protection level the user chose,
// - remember the app language,
// - load those settings next time the app opens.
class SettingsService {
  const SettingsService();

  // These are the keys used in SharedPreferences.
  // They are like names for the saved values.
  static const String _protectionLevelKey = 'protection_level';
  static const String _languageCodeKey = 'language_code';

  // Supported language values used by Veilmi.
  // 'en' = English
  // 'zh_Hant' = Traditional Chinese
  static const String englishLanguageCode = 'en';
  static const String traditionalChineseLanguageCode = 'zh_Hant';

  // Save the selected protection level so it remains when the app is reopened.
  Future<void> saveProtectionLevel(ProtectionLevel level) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_protectionLevelKey, level.name);
  }

  // Load the saved protection level.
  // If nothing was saved before, return the default value.
  Future<ProtectionLevel> loadProtectionLevel() async {
    final preferences = await SharedPreferences.getInstance();

    final savedValue = preferences.getString(_protectionLevelKey);

    if (savedValue == null) {
      return ProtectionLevel.balanced;
    }

    for (final level in ProtectionLevel.values) {
      if (level.name == savedValue) {
        return level;
      }
    }

    // If the saved value is invalid or unexpected, use the default again.
    return ProtectionLevel.balanced;
  }

  // Save the current language code.
  Future<void> saveLanguageCode(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();

    final normalizedLanguageCode = _normalizeLanguageCode(languageCode);

    await preferences.setString(_languageCodeKey, normalizedLanguageCode);
  }

  // Load the saved language code.
  // If the value is invalid, normalize it to a supported value.
  Future<String> loadLanguageCode() async {
    final preferences = await SharedPreferences.getInstance();

    final savedValue = preferences.getString(_languageCodeKey);

    final normalizedLanguageCode = _normalizeLanguageCode(savedValue);

    if (savedValue != normalizedLanguageCode) {
      await preferences.setString(_languageCodeKey, normalizedLanguageCode);
    }

    return normalizedLanguageCode;
  }

  // Only the supported locale codes are accepted.
  // This project uses English and Traditional Chinese only.
  String _normalizeLanguageCode(String? languageCode) {
    switch (languageCode) {
      case traditionalChineseLanguageCode:
        return traditionalChineseLanguageCode;

      case englishLanguageCode:
      default:
        return englishLanguageCode;
    }
  }
}
