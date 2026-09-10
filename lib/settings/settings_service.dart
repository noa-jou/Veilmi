import 'package:shared_preferences/shared_preferences.dart';

import '../crypto/protection_level.dart';

class SettingsService {
  const SettingsService();

  static const String _protectionLevelKey = 'protection_level';
  static const String _languageCodeKey = 'language_code';

  Future<void> saveProtectionLevel(ProtectionLevel level) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_protectionLevelKey, level.name);
  }

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

    return ProtectionLevel.balanced;
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_languageCodeKey, languageCode);
  }

  Future<String> loadLanguageCode() async {
    final preferences = await SharedPreferences.getInstance();

    final languageCode = preferences.getString(_languageCodeKey);

    if (languageCode == 'zh') {
      return 'zh';
    }

    return 'en';
  }
}
