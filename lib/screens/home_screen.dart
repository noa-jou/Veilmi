import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../crypto/crypto_service.dart';
import '../crypto/protection_level.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

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
      _settingsLoaded = true;
    });
  }

  Future<void> _toggleLanguage() async {
    final newLanguageCode = widget.currentLocale.languageCode == 'en'
        ? 'zh'
        : 'en';

    await _settingsService.saveLanguageCode(newLanguageCode);

    if (!mounted) {
      return;
    }

    widget.onLocaleChanged(Locale(newLanguageCode));
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
    final l10n = AppLocalizations.of(context)!;
    final plaintext = _messageController.text;
    final passphrase = _passphraseController.text;

    if (plaintext.isEmpty || passphrase.isEmpty) {
      _showMessage(l10n.enterMessageAndPassphrase);
      return;
    }

    setState(() {
      _isProcessing = true;
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

      _messageController.text = encryptedMessage;

      setState(() {});
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(l10n.encryptionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _decryptMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final encodedMessage = _messageController.text.trim();
    final passphrase = _passphraseController.text;

    if (encodedMessage.isEmpty || passphrase.isEmpty) {
      _showMessage(l10n.enterEncryptedMessageAndPassphrase);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final plaintext = await _cryptoService.decryptMessage(
        encodedMessage: encodedMessage,
        passphrase: passphrase,
      );

      if (!mounted) {
        return;
      }

      _messageController.text = plaintext;

      setState(() {});
    } on FormatException {
      if (!mounted) {
        return;
      }

      _showMessage(l10n.invalidEncryptedMessage);
    } on SecretBoxAuthenticationError {
      if (!mounted) {
        return;
      }

      _showMessage(l10n.decryptionAuthenticationFailed);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(l10n.decryptionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _copyMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final message = _messageController.text;

    if (message.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: message));

    if (!mounted) {
      return;
    }

    _showMessage(
      _isEncryptMode
          ? l10n.encryptedMessageCopied
          : l10n.decryptedMessageCopied,
    );
  }

  void _clearMessage() {
    _messageController.clear();
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

  @override
  void dispose() {
    _messageController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: TextButton(
          onPressed: _toggleLanguage,
          child: Text(widget.currentLocale.languageCode == 'en' ? '中文' : 'EN'),
        ),
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
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
              segments: [
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(l10n.encrypt),
                ),
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.lock_open_outlined),
                  label: Text(l10n.decrypt),
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
              _isEncryptMode ? l10n.protectMessage : l10n.openProtectedMessage,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isEncryptMode
                  ? l10n.encryptDescription
                  : l10n.decryptDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: l10n.clear,
                  onPressed: _messageController.text.isEmpty
                      ? null
                      : _clearMessage,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: _isEncryptMode
                      ? l10n.copyEncryptedMessage
                      : l10n.copyDecryptedMessage,
                  onPressed: _messageController.text.isEmpty
                      ? null
                      : _copyMessage,
                ),
              ],
            ),

            TextField(
              controller: _messageController,
              maxLines: 8,
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: _isEncryptMode
                    ? l10n.message
                    : l10n.encryptedMessage,
                hintText: _isEncryptMode
                    ? l10n.messageHint
                    : l10n.encryptedMessageHint,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passphraseController,
              obscureText: _obscurePassphrase,
              decoration: InputDecoration(
                labelText: l10n.sharedPassphrase,
                hintText: l10n.passphraseHint,
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
            if (_isEncryptMode)
              Text(
                l10n.protection(_protectionTitle(l10n, _protectionLevel)),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Text(
                l10n.protectionReadFromMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isProcessing || (_isEncryptMode && !_settingsLoaded)
                  ? null
                  : _isEncryptMode
                  ? _encryptMessage
                  : _decryptMessage,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isEncryptMode
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,
                    ),
              label: Text(
                _isProcessing
                    ? _isEncryptMode
                          ? l10n.encrypting
                          : l10n.decrypting
                    : _isEncryptMode
                    ? l10n.encryptMessage
                    : l10n.decryptMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
