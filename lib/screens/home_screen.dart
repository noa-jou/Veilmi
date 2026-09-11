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
  // This object does the real encryption and decryption work.
  // In beginner terms: it takes your text + passphrase and turns it into protected data.
  final CryptoService _cryptoService = const CryptoService();

  // This object remembers app settings such as:
  // - selected language
  // - saved protection strength
  // It uses a small local storage called SharedPreferences.
  final SettingsService _settingsService = const SettingsService();

  // These controllers are linked to the text fields.
  // They let us read what the user types and also change the text programmatically.
  // Example: after encryption, we replace the message text with the encrypted version.
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _passphraseController = TextEditingController();

  // These flags control the current screen behavior.
  // _isEncryptMode: false means the screen is in decrypt mode.
  // _obscurePassphrase: true means the passphrase is hidden.
  // _isProcessing: true means the app is busy encrypting or decrypting.
  // _settingsLoaded: false means the saved protection level has not finished loading yet.
  bool _isEncryptMode = true;
  bool _obscurePassphrase = true;
  bool _isProcessing = false;
  bool _settingsLoaded = false;

  // This is the security setting used for encryption.
  // A higher/stronger setting takes more time, but is more secure.
  // We start with balanced as the default.
  ProtectionLevel _protectionLevel = ProtectionLevel.balanced;

  @override
  void initState() {
    super.initState();
    // When the screen first appears, we load the saved protection level.
    // This ensures the user sees the same security setting they chose before.
    _loadProtectionLevel();
  }

  // Load the saved protection level from local storage.
  // This does not change the UI immediately; after it returns, we call setState.
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

  // Change the app language between English and Traditional Chinese.
  // The app remembers the chosen language so it stays the same next time you open it.
  Future<void> _toggleLanguage() async {
    final isEnglish = widget.currentLocale.languageCode == 'en';

    final newLanguageCode = isEnglish
        ? SettingsService.traditionalChineseLanguageCode
        : SettingsService.englishLanguageCode;

    // Save the selected language to local storage.
    await _settingsService.saveLanguageCode(newLanguageCode);

    if (!mounted) {
      return;
    }

    // In Flutter, Traditional Chinese is represented as:
    // languageCode = 'zh', scriptCode = 'Hant'
    // This is the proper locale for Traditional Chinese.
    final newLocale = isEnglish
        ? const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
        : const Locale('en');

    // Tell the parent widget to rebuild the whole app with the new locale.
    widget.onLocaleChanged(newLocale);
  }

  // Open the Settings screen.
  // After returning, we reload the saved protection level in case the user changed it.
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

  // Encrypt the user text.
  // This means: take plain text + passphrase + chosen security level,
  // then create an encrypted string that can only be opened with the same passphrase.
  Future<void> _encryptMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final plaintext = _messageController.text;
    final passphrase = _passphraseController.text;

    // Do not allow empty inputs. Otherwise the app cannot encrypt anything useful.
    if (plaintext.isEmpty || passphrase.isEmpty) {
      _showMessage(l10n.enterMessageAndPassphrase);
      return;
    }

    // This tells Flutter to rebuild the UI while the app is busy.
    // It also disables the main button temporarily.
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

      // After encryption, replace the message text with the encrypted result.
      // The user can then copy it or save it elsewhere.
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

  // Decrypt the encrypted message.
  // This takes the encoded string and the passphrase and tries to recover the original text.
  Future<void> _decryptMessage() async {
    final l10n = AppLocalizations.of(context)!;
    final encodedMessage = _messageController.text.trim();
    final passphrase = _passphraseController.text;

    // The input must not be empty, or there is nothing to decrypt.
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

      // Replace the encrypted text with the original plain text.
      _messageController.text = plaintext;

      setState(() {});
    } on FormatException {
      // This happens when the text is not in the expected encrypted format.
      if (!mounted) {
        return;
      }

      _showMessage(l10n.invalidEncryptedMessage);
    } on SecretBoxAuthenticationError {
      // This happens when the passphrase is wrong or the encrypted data was changed.
      if (!mounted) {
        return;
      }

      _showMessage(l10n.decryptionAuthenticationFailed);
    } catch (error) {
      // Any other unexpected error is shown as a general decryption failure.
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

  // Copy the current message to the phone clipboard.
  // This is useful after encryption, so the user can paste the protected text elsewhere.
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

  // Clear the message field.
  void _clearMessage() {
    _messageController.clear();
    setState(() {});
  }

  // Show a small popup message at the bottom of the screen.
  // This is the app's way to tell the user what happened, for example: copied, failed, or invalid input.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Convert the chosen protection level into a user-friendly name.
  // Example: ProtectionLevel.balanced -> "Balanced"
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
    // This is important for memory cleanup.
    // When the screen is closed, we remove the text field listeners and free the memory.
    _messageController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // These colors are chosen based on the current mode.
    // Encrypt mode uses a clean white style.
    // Decrypt mode uses a warm yellow background to make it feel different.
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

    // The whole screen is built from widgets.
    // In beginner terms, the screen is like a layout made of pieces:
    // - app bar
    // - mode switch
    // - message input
    // - passphrase input
    // - action buttons
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        foregroundColor: primaryTextColor,
        centerTitle: true,
        leading: TextButton(
          // This is the language button in the app bar.
          // If the app is currently in English, the button shows Chinese.
          // If it is already Chinese, the button shows EN to switch back.
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
            // This segmented control lets the user choose the current action.
            // It is basically a toggle between two pages: encrypt and decrypt.
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

            // This headline text changes depending on the selected mode.
            // For example: "Protect message" in encrypt mode or "Open protected message" in decrypt mode.
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

            // These small buttons are quick actions for the text field.
            // One clears the content, and the other copies it to the clipboard.
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

            // This is the main text box where the user writes or reads the message.
            // It is connected to _messageController so the app can read and update the text.
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

            // This is the passphrase input.
            // The user enters the secret key here.
            // The eye icon lets them show or hide the passphrase while typing.
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

            // This text tells the user which protection level is currently selected.
            // In decrypt mode, it says the app is reading the level from the encrypted message.
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
            // It performs the main job:
            // - encrypt the text when in encrypt mode
            // - decrypt the text when in decrypt mode
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
