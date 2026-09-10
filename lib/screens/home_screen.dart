import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../crypto/crypto_service.dart';
import '../crypto/protection_level.dart';
import '../l10n/app_localizations.dart';
import '../settings/settings_service.dart';
import 'settings_screen.dart';

// This screen is the main place where the user encrypts and decrypts messages.
// It also lets the user switch the app language and open the settings screen.
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
  // This is the main encryption service used to protect or unlock messages.
  final CryptoService _cryptoService = const CryptoService();

  // This helps read and save user preferences like language and protection level.
  final SettingsService _settingsService = const SettingsService();

  // These controllers keep track of what the user types in the message and passphrase fields.
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();

  // These booleans represent the current mode and UI state.
  bool _isEncryptMode = true;
  bool _obscurePassphrase = true;
  bool _isProcessing = false;
  bool _settingsLoaded = false;

  // Default protection level for encrypting messages.
  ProtectionLevel _protectionLevel = ProtectionLevel.balanced;

  @override
  void initState() {
    super.initState();
    // Load the saved protection level when the screen is created.
    _loadProtectionLevel();
  }

  // Read the saved protection level from storage.
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

  // Toggle between English and Chinese for the app.
  Future<void> _toggleLanguage() async {
    final newLanguageCode = widget.currentLocale.languageCode == 'en'
        ? 'zh'
        : 'en';

    // Save the choice so it remains the next time the app is opened.
    await _settingsService.saveLanguageCode(newLanguageCode);

    if (!mounted) {
      return;
    }

    // Tell the parent widget to rebuild the app using the new locale.
    widget.onLocaleChanged(Locale(newLanguageCode));
  }

  // Open the settings screen and then refresh the saved protection level.
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

  // Encrypt the text the user entered.
  Future<void> _encryptMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final plaintext = _messageController.text;
    final passphrase = _passphraseController.text;

    // Make sure both fields are not empty before trying to encrypt.
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

      // Replace the message text with the encrypted result.
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

  // Decrypt the encrypted message the user entered.
  Future<void> _decryptMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final encodedMessage = _messageController.text.trim();
    final passphrase = _passphraseController.text;

    // Both fields are required before decrypting the message.
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

      // Replace the encrypted text with the original plain text after decrypting.
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

  // Copy the message into the device clipboard.
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

  // Clear the message box.
  void _clearMessage() {
    _messageController.clear();
    setState(() {});
  }

  // Show a small floating message at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Convert the selected protection level into a string for display.
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
    // Clean up text inputs when the screen is removed.
    _messageController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // The page color changes depending on whether the user is encrypting or decrypting.
    final pageBackgroundColor = _isEncryptMode
        ? Colors.white
        : Colors.amber.shade100;

    final primaryTextColor = _isEncryptMode
        ? colorScheme.primary
        : Colors.black87;

    final secondaryTextColor = _isEncryptMode ? Colors.black54 : Colors.black87;

    final actionBackgroundColor = _isEncryptMode
        ? colorScheme.primary
        : Colors.amber.shade600;

    final actionForegroundColor = _isEncryptMode
        ? colorScheme.onPrimary
        : Colors.black87;

    // The main screen layout includes:
    // - top app bar
    // - mode switcher (Encrypt/Decrypt)
    // - text fields for message and passphrase
    // - message action buttons
    // - main action button to encrypt or decrypt
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        foregroundColor: primaryTextColor,
        centerTitle: true,
        leading: TextButton(
          // This button toggles between English and Chinese.
          onPressed: _toggleLanguage,
          style: TextButton.styleFrom(foregroundColor: primaryTextColor),
          child: Text(widget.currentLocale.languageCode == 'en' ? '中文' : 'EN'),
        ),
        title: Text(
          l10n.appTitle,
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            // This lets the user switch between encrypting and decrypting mode.
            SegmentedButton<bool>(
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(120, 54)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return _isEncryptMode
                        ? colorScheme.primary
                        : Colors.amber.shade600;
                  }

                  return _isEncryptMode ? Colors.grey.shade100 : Colors.white;
                }),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return _isEncryptMode
                        ? colorScheme.onPrimary
                        : Colors.black87;
                  }

                  return _isEncryptMode ? Colors.grey.shade700 : Colors.black54;
                }),
                textStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                  states,
                ) {
                  return TextStyle(
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.bold
                        : FontWeight.w500,
                  );
                }),
                side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return BorderSide(
                      color: _isEncryptMode
                          ? colorScheme.primary
                          : Colors.amber.shade800,
                      width: 2,
                    );
                  }

                  return BorderSide(
                    color: _isEncryptMode
                        ? Colors.grey.shade400
                        : Colors.amber.shade700,
                  );
                }),
              ),
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

            // This text changes based on whether the user is encrypting or decrypting.
            Text(
              _isEncryptMode ? l10n.protectMessage : l10n.openProtectedMessage,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isEncryptMode
                  ? l10n.encryptDescription
                  : l10n.decryptDescription,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: secondaryTextColor),
            ),
            const SizedBox(height: 24),

            // Buttons for clearing and copying the current message.
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: l10n.clear,
                  color: primaryTextColor,
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
                  color: primaryTextColor,
                  onPressed: _messageController.text.isEmpty
                      ? null
                      : _copyMessage,
                ),
              ],
            ),

            // This is the main message field.
            TextField(
              controller: _messageController,
              maxLines: 8,
              onChanged: (_) {
                setState(() {});
              },
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
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

            // Passphrase field. It can be hidden or shown using the eye icon.
            TextField(
              controller: _passphraseController,
              obscureText: _obscurePassphrase,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
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

            // Tell the user which protection level is currently selected,
            // or that the protection level is being read from the message.
            if (_isEncryptMode)
              Text(
                l10n.protection(_protectionTitle(l10n, _protectionLevel)),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: secondaryTextColor),
              )
            else
              Text(
                l10n.protectionReadFromMessage,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: secondaryTextColor),
              ),
            const SizedBox(height: 24),

            // This is the main action button.
            // It encrypts in encrypt mode and decrypts in decrypt mode.
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: actionBackgroundColor,
                foregroundColor: actionForegroundColor,
                minimumSize: const Size.fromHeight(54),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _isProcessing || (_isEncryptMode && !_settingsLoaded)
                  ? null
                  : _isEncryptMode
                  ? _encryptMessage
                  : _decryptMessage,
              icon: _isProcessing
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: actionForegroundColor,
                      ),
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
