import 'package:flutter/material.dart';

import 'about_screen.dart';
import '../crypto/protection_level.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_service.dart';
import 'device_check_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.initialProtectionLevel});

  final ProtectionLevel initialProtectionLevel;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ProtectionLevel _protectionLevel;

  final SettingsService _settingsService = const SettingsService();

  @override
  void initState() {
    super.initState();
    _protectionLevel = widget.initialProtectionLevel;
  }

  Future<void> _saveProtectionLevel(ProtectionLevel level) async {
    setState(() {
      _protectionLevel = level;
    });

    await _settingsService.saveProtectionLevel(level);
  }

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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.protectionLevel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(l10n.protectionLevelDescription),
          const SizedBox(height: 20),
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
