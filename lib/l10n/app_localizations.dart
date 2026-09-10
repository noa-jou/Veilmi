import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Veilmi'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @encrypt.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get encrypt;

  /// No description provided for @decrypt.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get decrypt;

  /// No description provided for @protectMessage.
  ///
  /// In en, this message translates to:
  /// **'Protect a message'**
  String get protectMessage;

  /// No description provided for @openProtectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Open a protected message'**
  String get openProtectedMessage;

  /// No description provided for @encryptDescription.
  ///
  /// In en, this message translates to:
  /// **'Encrypt text locally with a shared passphrase.'**
  String get encryptDescription;

  /// No description provided for @decryptDescription.
  ///
  /// In en, this message translates to:
  /// **'Decrypt text locally with the shared passphrase.'**
  String get decryptDescription;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @encryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypted message'**
  String get encryptedMessage;

  /// No description provided for @decryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Decrypted message'**
  String get decryptedMessage;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste the message you want to protect.'**
  String get messageHint;

  /// No description provided for @encryptedMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Paste a Veilmi encrypted message here.'**
  String get encryptedMessageHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @sharedPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Shared passphrase'**
  String get sharedPassphrase;

  /// No description provided for @passphraseHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the passphrase shared with the recipient.'**
  String get passphraseHint;

  /// No description provided for @protection.
  ///
  /// In en, this message translates to:
  /// **'Protection: {level}'**
  String protection(String level);

  /// No description provided for @protectionReadFromMessage.
  ///
  /// In en, this message translates to:
  /// **'The protection level is read from the encrypted message.'**
  String get protectionReadFromMessage;

  /// No description provided for @encrypting.
  ///
  /// In en, this message translates to:
  /// **'Encrypting...'**
  String get encrypting;

  /// No description provided for @decrypting.
  ///
  /// In en, this message translates to:
  /// **'Decrypting...'**
  String get decrypting;

  /// No description provided for @encryptMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypt Message'**
  String get encryptMessage;

  /// No description provided for @decryptMessage.
  ///
  /// In en, this message translates to:
  /// **'Decrypt Message'**
  String get decryptMessage;

  /// No description provided for @copyEncryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy encrypted message'**
  String get copyEncryptedMessage;

  /// No description provided for @copyDecryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy decrypted message'**
  String get copyDecryptedMessage;

  /// No description provided for @encryptedMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Encrypted message copied.'**
  String get encryptedMessageCopied;

  /// No description provided for @decryptedMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Decrypted message copied.'**
  String get decryptedMessageCopied;

  /// No description provided for @enterMessageAndPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Enter both a message and a shared passphrase.'**
  String get enterMessageAndPassphrase;

  /// No description provided for @enterEncryptedMessageAndPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Enter both an encrypted message and the shared passphrase.'**
  String get enterEncryptedMessageAndPassphrase;

  /// No description provided for @encryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not encrypt this message.'**
  String get encryptionFailed;

  /// No description provided for @invalidEncryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid Veilmi encrypted message.'**
  String get invalidEncryptedMessage;

  /// No description provided for @decryptionAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not decrypt the message. Check the passphrase and message integrity.'**
  String get decryptionAuthenticationFailed;

  /// No description provided for @decryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not decrypt this message.'**
  String get decryptionFailed;

  /// No description provided for @protectionLevel.
  ///
  /// In en, this message translates to:
  /// **'Protection Level'**
  String get protectionLevel;

  /// No description provided for @protectionLevelDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how much work Veilmi should require when preparing your shared passphrase.'**
  String get protectionLevelDescription;

  /// No description provided for @compatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get compatibility;

  /// No description provided for @compatibilitySummary.
  ///
  /// In en, this message translates to:
  /// **'Faster on older devices.'**
  String get compatibilitySummary;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @balancedSummary.
  ///
  /// In en, this message translates to:
  /// **'A balance between protection and speed.'**
  String get balancedSummary;

  /// No description provided for @stronger.
  ///
  /// In en, this message translates to:
  /// **'Stronger'**
  String get stronger;

  /// No description provided for @strongerSummary.
  ///
  /// In en, this message translates to:
  /// **'More resistant to repeated passphrase guessing.'**
  String get strongerSummary;

  /// No description provided for @protectionDeviceCheck.
  ///
  /// In en, this message translates to:
  /// **'Protection & Device Check'**
  String get protectionDeviceCheck;

  /// No description provided for @protectionDeviceCheckDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn how protection levels work and find a suitable level for this device.'**
  String get protectionDeviceCheckDescription;

  /// No description provided for @deviceCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Protection & Device Check'**
  String get deviceCheckTitle;

  /// No description provided for @howProtectionWorks.
  ///
  /// In en, this message translates to:
  /// **'How protection works'**
  String get howProtectionWorks;

  /// No description provided for @lockedDoor.
  ///
  /// In en, this message translates to:
  /// **'Think of your message as a locked door.'**
  String get lockedDoor;

  /// No description provided for @sharedPassphraseKey.
  ///
  /// In en, this message translates to:
  /// **'Your shared passphrase is the key.'**
  String get sharedPassphraseKey;

  /// No description provided for @lockTurns.
  ///
  /// In en, this message translates to:
  /// **'Before the door opens, the lock has to turn many times.'**
  String get lockTurns;

  /// No description provided for @moreTurnsHarderGuessing.
  ///
  /// In en, this message translates to:
  /// **'More turns make it harder for someone to keep guessing the key.'**
  String get moreTurnsHarderGuessing;

  /// No description provided for @moreTurnsMoreWork.
  ///
  /// In en, this message translates to:
  /// **'But more turns also make the phone work harder.'**
  String get moreTurnsMoreWork;

  /// No description provided for @otherPhoneSameWork.
  ///
  /// In en, this message translates to:
  /// **'The other person\'s phone has to do the same work too, so a very strong setting may be slow on an older phone.'**
  String get otherPhoneSameWork;

  /// No description provided for @threeProtectionLevels.
  ///
  /// In en, this message translates to:
  /// **'The three protection levels'**
  String get threeProtectionLevels;

  /// No description provided for @compatibilityDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Fewer turns. Faster, especially on older phones.'**
  String get compatibilityDeviceDescription;

  /// No description provided for @balancedDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'More work for guessing, with a moderate phone workload.'**
  String get balancedDeviceDescription;

  /// No description provided for @strongerDeviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Many more turns. Harder to guess repeatedly, but slower on some phones.'**
  String get strongerDeviceDescription;

  /// No description provided for @whichLevelFits.
  ///
  /// In en, this message translates to:
  /// **'Which level fits this device?'**
  String get whichLevelFits;

  /// No description provided for @deviceCheckDescription.
  ///
  /// In en, this message translates to:
  /// **'Veilmi can measure how long each level takes on this phone and suggest one that should feel practical.'**
  String get deviceCheckDescription;

  /// No description provided for @checkingDevice.
  ///
  /// In en, this message translates to:
  /// **'Checking this device...'**
  String get checkingDevice;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @checkThisDevice.
  ///
  /// In en, this message translates to:
  /// **'Check This Device'**
  String get checkThisDevice;

  /// No description provided for @deviceCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Device check failed.'**
  String get deviceCheckFailed;

  /// No description provided for @recommendedForDevice.
  ///
  /// In en, this message translates to:
  /// **'Recommended for this device:'**
  String get recommendedForDevice;

  /// No description provided for @pbkdf2Implementation.
  ///
  /// In en, this message translates to:
  /// **'PBKDF2 implementation: {implementation}'**
  String pbkdf2Implementation(String implementation);

  /// No description provided for @protectionTime.
  ///
  /// In en, this message translates to:
  /// **'{level}: {seconds} s'**
  String protectionTime(String level, String seconds);

  /// No description provided for @turns.
  ///
  /// In en, this message translates to:
  /// **'{count} turns'**
  String turns(String count);

  /// No description provided for @aboutVeilmi.
  ///
  /// In en, this message translates to:
  /// **'About Veilmi'**
  String get aboutVeilmi;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSource;

  /// No description provided for @openSourceDescription.
  ///
  /// In en, this message translates to:
  /// **'Veilmi is an open-source project. If you are interested in how Veilmi is built, you are welcome to visit the project on GitHub.'**
  String get openSourceDescription;

  /// No description provided for @docsDescription.
  ///
  /// In en, this message translates to:
  /// **'The docs folder contains explanations of Veilmi\'s cryptographic design, security decisions, testing, and development process.'**
  String get docsDescription;

  /// No description provided for @viewOnGitHub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGitHub;

  /// No description provided for @readDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Read the Documentation'**
  String get readDocumentation;

  /// No description provided for @supportVeilmi.
  ///
  /// In en, this message translates to:
  /// **'Support Veilmi'**
  String get supportVeilmi;

  /// No description provided for @supportDescription.
  ///
  /// In en, this message translates to:
  /// **'Veilmi is free and open source. If you find it useful and would like to support its continued development, you can make a completely optional contribution.'**
  String get supportDescription;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link.'**
  String get couldNotOpenLink;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
