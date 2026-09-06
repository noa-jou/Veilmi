import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Protection Level',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose how much work Veilmi should require when preparing '
            'your shared passphrase.',
          ),
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
                  title: Text(level.title),
                  subtitle: Text(level.summary),
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
            title: const Text('Protection & Device Check'),
            subtitle: const Text(
              'Learn how protection levels work and find a suitable '
              'level for this device.',
            ),
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
        ],
      ),
    );
  }
}
