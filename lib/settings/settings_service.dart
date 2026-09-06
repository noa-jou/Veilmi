import 'package:shared_preferences/shared_preferences.dart';

import '../crypto/protection_level.dart';

class SettingsService {
  const SettingsService();

  static const String _protectionLevelKey = 'protection_level';

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
}
