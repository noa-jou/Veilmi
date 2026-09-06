import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../crypto/crypto_service.dart';
import '../crypto/protection_level.dart';
import '../settings/settings_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CryptoService _cryptoService = const CryptoService();
  final SettingsService _settingsService = const SettingsService();

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();

  bool _isEncryptMode = true;
  bool _obscurePassphrase = true;
  bool _isProcessing = false;
  bool _settingsLoaded = false;

  ProtectionLevel _protectionLevel = ProtectionLevel.balanced;

  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadProtectionLevel();
  }

  Future<void> _loadProtectionLevel() async {
    final level = await _settingsService.loadProtectionLevel();

    if (!context.mounted) {
      return;
    }

    setState(() {
      _protectionLevel = level;
      _settingsLoaded = true;
    });
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SettingsScreen(initialProtectionLevel: _protectionLevel),
      ),
    );

    await _loadProtectionLevel();
  }

  Future<void> _encryptMessage() async {
    final plaintext = _messageController.text;
    final passphrase = _passphraseController.text;

    if (plaintext.isEmpty || passphrase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter both a message and a shared passphrase.'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _result = '';
    });

    try {
      final encryptedMessage = await _cryptoService.encryptMessage(
        plaintext: plaintext,
        passphrase: passphrase,
        protectionLevel: _protectionLevel,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = encryptedMessage;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not encrypt this message.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _copyResult() async {
    await Clipboard.setData(ClipboardData(text: _result));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Encrypted message copied.')));
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
                  _result = '';
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              _isEncryptMode ? 'Protect a message' : 'Open a protected message',
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
                labelText: _isEncryptMode ? 'Message' : 'Encrypted message',
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
            const SizedBox(height: 12),
            Text(
              'Protection: ${_protectionLevel.title}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            if (_isEncryptMode)
              FilledButton.icon(
                onPressed: !_settingsLoaded || _isProcessing
                    ? null
                    : _encryptMessage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  _isProcessing ? 'Encrypting...' : 'Encrypt Message',
                ),
              ),

            if (!_isEncryptMode)
              const FilledButton(
                onPressed: null,
                child: Text('Decrypt Message'),
              ),

            if (_result.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Encrypted message',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_outlined),
                    tooltip: 'Copy encrypted message',
                    onPressed: _copyResult,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(_result),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
