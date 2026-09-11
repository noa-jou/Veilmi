// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Veilmi';

  @override
  String get settings => 'Settings';

  @override
  String get encrypt => 'Encrypt';

  @override
  String get decrypt => 'Decrypt';

  @override
  String get protectMessage => 'Protect a message';

  @override
  String get openProtectedMessage => 'Open a protected message';

  @override
  String get encryptDescription =>
      'Encrypt text locally with a shared passphrase.';

  @override
  String get decryptDescription =>
      'Decrypt text locally with the shared passphrase.';

  @override
  String get message => 'Message';

  @override
  String get encryptedMessage => 'Encrypted message';

  @override
  String get decryptedMessage => 'Decrypted message';

  @override
  String get messageHint => 'Type or paste the message you want to protect.';

  @override
  String get encryptedMessageHint => 'Paste a Veilmi encrypted message here.';

  @override
  String get clear => 'Clear';

  @override
  String get sharedPassphrase => 'Shared passphrase';

  @override
  String get passphraseHint =>
      'Enter the passphrase shared with the recipient.';

  @override
  String protection(String level) {
    return 'Protection: $level';
  }

  @override
  String get protectionReadFromMessage =>
      'The protection level is read from the encrypted message.';

  @override
  String get encrypting => 'Encrypting...';

  @override
  String get decrypting => 'Decrypting...';

  @override
  String get encryptMessage => 'Encrypt Message';

  @override
  String get decryptMessage => 'Decrypt Message';

  @override
  String get copyEncryptedMessage => 'Copy message';

  @override
  String get copyDecryptedMessage => 'Copy message';

  @override
  String get encryptedMessageCopied => 'Message copied.';

  @override
  String get decryptedMessageCopied => 'Message copied.';

  @override
  String get enterMessageAndPassphrase =>
      'Enter both a message and a shared passphrase.';

  @override
  String get enterEncryptedMessageAndPassphrase =>
      'Enter both an encrypted message and the shared passphrase.';

  @override
  String get encryptionFailed => 'Could not encrypt this message.';

  @override
  String get invalidEncryptedMessage =>
      'This is not a valid Veilmi encrypted message.';

  @override
  String get decryptionAuthenticationFailed =>
      'Could not decrypt the message. Check the passphrase and message integrity.';

  @override
  String get decryptionFailed => 'Could not decrypt this message.';

  @override
  String get protectionLevel => 'Protection Level';

  @override
  String get protectionLevelDescription =>
      'Choose how much work Veilmi should require when preparing your shared passphrase.';

  @override
  String get compatibility => 'Weaker';

  @override
  String get compatibilitySummary => 'Faster on older devices.';

  @override
  String get balanced => 'Balanced';

  @override
  String get balancedSummary => 'A balance between protection and speed.';

  @override
  String get stronger => 'Stronger';

  @override
  String get strongerSummary =>
      'More resistant to repeated passphrase guessing.';

  @override
  String get protectionDeviceCheck => 'Protection & Device Check';

  @override
  String get protectionDeviceCheckDescription =>
      'Learn how protection levels work and find a suitable level for this device.';

  @override
  String get deviceCheckTitle => 'Protection & Device Check';

  @override
  String get howProtectionWorks => 'How protection works';

  @override
  String get lockedDoor => 'Think of your message as a locked door.';

  @override
  String get sharedPassphraseKey => 'Your shared passphrase is the key.';

  @override
  String get lockTurns =>
      'Before the door opens, the lock has to turn many times.';

  @override
  String get moreTurnsHarderGuessing =>
      'More turns make it harder for someone to keep guessing the key.';

  @override
  String get moreTurnsMoreWork =>
      'But more turns also make the phone work harder.';

  @override
  String get otherPhoneSameWork =>
      'The other person\'s phone has to do the same work too, so a very strong setting may be slow on an older phone.';

  @override
  String get threeProtectionLevels => 'The three protection levels';

  @override
  String get compatibilityDeviceDescription =>
      'Fewer turns. Faster, especially on older phones.';

  @override
  String get balancedDeviceDescription =>
      'More work for guessing, with a moderate phone workload.';

  @override
  String get strongerDeviceDescription =>
      'Many more turns. Harder to guess repeatedly, but slower on some phones.';

  @override
  String get whichLevelFits => 'Which level fits this device?';

  @override
  String get deviceCheckDescription =>
      'Veilmi can measure how long each level takes on this phone and suggest one that should feel practical.';

  @override
  String get checkingDevice => 'Checking this device...';

  @override
  String get checking => 'Checking...';

  @override
  String get checkThisDevice => 'Check This Device';

  @override
  String get deviceCheckFailed => 'Device check failed.';

  @override
  String get recommendedForDevice => 'Recommended for this device:';

  @override
  String pbkdf2Implementation(String implementation) {
    return 'PBKDF2 implementation: $implementation';
  }

  @override
  String protectionTime(String level, String seconds) {
    return '$level: $seconds s';
  }

  @override
  String turns(String count) {
    return '$count turns';
  }

  @override
  String get aboutVeilmi => 'About Veilmi';

  @override
  String get openSource => 'Open Source';

  @override
  String get openSourceDescription =>
      'Veilmi is an open-source project. If you are interested in how Veilmi is built, you are welcome to visit the project on GitHub.';

  @override
  String get docsDescription =>
      'The docs folder contains explanations of Veilmi\'s cryptographic design, security decisions, testing, and development process.';

  @override
  String get viewOnGitHub => 'View on GitHub';

  @override
  String get readDocumentation => 'Read the Documentation';

  @override
  String get supportVeilmi => 'Support Veilmi';

  @override
  String get supportDescription =>
      'Veilmi is free and open source. If you find it useful and would like to support its continued development, you can make a completely optional contribution.';

  @override
  String get couldNotOpenLink => 'Could not open this link.';

  @override
  String get deviceCheckWarning =>
      'Device Check may take a minute or longer on older phones. You can leave this page and come back later while Veilmi remains open.';
}
