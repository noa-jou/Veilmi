import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';
import '../settings/settings_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SettingsService _settingsService = const SettingsService();

  bool _isEncryptMode = true;
  bool _obscurePassphrase = true;

  ProtectionLevel _protectionLevel = ProtectionLevel.balanced;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProtectionLevel();
  }

  Future<void> _loadProtectionLevel() async {
    final level = await _settingsService.loadProtectionLevel();

    if (!mounted) {
      return;
    }

    setState(() {
      _protectionLevel = level;
    });
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          initialProtectionLevel: _protectionLevel,
        ),
      ),
    );

    await _loadProtectionLevel();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veilmi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.lock_outline),
                  label: Text('Encrypt'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.lock_open_outlined),
                  label: Text('Decrypt'),
                ),
              ],
              selected: {_isEncryptMode},
              onSelectionChanged: (selection) {
                setState(() {
                  _isEncryptMode = selection.first;
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              _isEncryptMode
                  ? 'Protect a message'
                  : 'Open a protected message',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isEncryptMode
                  ? 'Encrypt text locally with a shared passphrase.'
                  : 'Decrypt text locally with the shared passphrase.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: _isEncryptMode
                    ? 'Message'
                    : 'Encrypted message',
                hintText: _isEncryptMode
                    ? 'Type or paste the message you want to protect.'
                    : 'Paste a Veilmi encrypted message here.',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passphraseController,
              obscureText: _obscurePassphrase,
              decoration: InputDecoration(
                labelText: 'Shared passphrase',
                hintText: 'Enter the passphrase shared with the recipient.',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassphrase = !_obscurePassphrase;
                    });
                  },
                  icon: Icon(
                    _obscurePassphrase
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}