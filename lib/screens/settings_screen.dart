import 'package:flutter/material.dart';

import 'about_screen.dart';
import '../crypto/protection_level.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_service.dart';
import 'device_check_screen.dart';

// This screen lets the user change the app's security settings.
// It also contains links to the device check screen and the About screen.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.initialProtectionLevel});

  // The protection level that was already selected before this screen opened.
  final ProtectionLevel initialProtectionLevel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // This is the current selected protection level for this screen.
  late ProtectionLevel _protectionLevel;

  // Used to save the selection so it remains when the app opens again.
  final SettingsService _settingsService = const SettingsService();

  @override
  void initState() {
    super.initState();
    // Start with the protection level that was passed in from the previous screen.
    _protectionLevel = widget.initialProtectionLevel;
  }

  // Save the selected protection level and update the UI immediately.
  Future<void> _saveProtectionLevel(ProtectionLevel level) async {
    setState(() {
      _protectionLevel = level;
    });

    await _settingsService.saveProtectionLevel(level);
  }

  // Return a readable label for each protection level.
  String _protectionTitle(AppLocalizations l10n, ProtectionLevel level) {
    switch (level) {
      case ProtectionLevel.compatibility:
        return l10n.compatibility;
      case ProtectionLevel.balanced:
        return l10n.balanced;
      case ProtectionLevel.stronger:
        return l10n.stronger;
    }
  }

  // Return a short explanation for each protection level.
  String _protectionSummary(AppLocalizations l10n, ProtectionLevel level) {
    switch (level) {
      case ProtectionLevel.compatibility:
        return l10n.compatibilitySummary;
      case ProtectionLevel.balanced:
        return l10n.balancedSummary;
      case ProtectionLevel.stronger:
        return l10n.strongerSummary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // The screen is a vertical list of settings.
    // It starts with the security settings, then has navigation tiles to other screens.
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Section title for protection level settings.
          Text(
            l10n.protectionLevel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(l10n.protectionLevelDescription),
          const SizedBox(height: 20),

          // RadioGroup is used so only one protection level can be selected at a time.
          RadioGroup<ProtectionLevel>(
            groupValue: _protectionLevel,
            onChanged: (value) {
              if (value == null) {
                return;
              }

              _saveProtectionLevel(value);
            },
            child: Column(
              children: ProtectionLevel.values.map((level) {
                return RadioListTile<ProtectionLevel>(
                  title: Text(_protectionTitle(l10n, level)),
                  subtitle: Text(_protectionSummary(l10n, level)),
                  value: level,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // This row opens the device benchmark screen.
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.security_outlined),
            title: Text(l10n.protectionDeviceCheck),
            subtitle: Text(l10n.protectionDeviceCheckDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceCheckScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // This row opens the About screen.
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutVeilmi),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
