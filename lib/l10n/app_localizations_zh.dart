// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Veilmi';

  @override
  String get settings => '設定';

  @override
  String get encrypt => '加密';

  @override
  String get decrypt => '解密';

  @override
  String get protectMessage => '保護訊息';

  @override
  String get openProtectedMessage => '開啟受保護的訊息';

  @override
  String get encryptDescription => '使用共享密碼在本機加密文字。';

  @override
  String get decryptDescription => '使用共享密碼在本機解密文字。';

  @override
  String get message => '訊息';

  @override
  String get encryptedMessage => '加密訊息';

  @override
  String get decryptedMessage => '解密訊息';

  @override
  String get messageHint => '輸入或貼上你想保護的訊息。';

  @override
  String get encryptedMessageHint => '在這裡貼上 Veilmi 加密訊息。';

  @override
  String get clear => '清除';

  @override
  String get sharedPassphrase => '共享密碼';

  @override
  String get passphraseHint => '輸入你與收件者共享的密碼。';

  @override
  String protection(String level) {
    return '保護等級：$level';
  }

  @override
  String get protectionReadFromMessage => '保護等級會自動從加密訊息中讀取。';

  @override
  String get encrypting => '加密中...';

  @override
  String get decrypting => '解密中...';

  @override
  String get encryptMessage => '加密訊息';

  @override
  String get decryptMessage => '解密訊息';

  @override
  String get copyEncryptedMessage => '複製加密訊息';

  @override
  String get copyDecryptedMessage => '複製解密訊息';

  @override
  String get encryptedMessageCopied => '已複製加密訊息。';

  @override
  String get decryptedMessageCopied => '已複製解密訊息。';

  @override
  String get enterMessageAndPassphrase => '請輸入訊息和共享密碼。';

  @override
  String get enterEncryptedMessageAndPassphrase => '請輸入加密訊息和共享密碼。';

  @override
  String get encryptionFailed => '無法加密這則訊息。';

  @override
  String get invalidEncryptedMessage => '這不是有效的 Veilmi 加密訊息。';

  @override
  String get decryptionAuthenticationFailed => '無法解密訊息。請檢查共享密碼和訊息是否完整。';

  @override
  String get decryptionFailed => '無法解密這則訊息。';

  @override
  String get protectionLevel => '保護等級';

  @override
  String get protectionLevelDescription => '選擇 Veilmi 在處理共享密碼時需要進行多少運算。';

  @override
  String get compatibility => '相容';

  @override
  String get compatibilitySummary => '在較舊的裝置上速度較快。';

  @override
  String get balanced => '平衡';

  @override
  String get balancedSummary => '在保護強度與速度之間取得平衡。';

  @override
  String get stronger => '較強';

  @override
  String get strongerSummary => '提高重複猜測共享密碼所需的成本。';

  @override
  String get protectionDeviceCheck => '保護與裝置檢查';

  @override
  String get protectionDeviceCheckDescription => '了解保護等級的運作方式，並找出適合這台裝置的設定。';

  @override
  String get deviceCheckTitle => '保護與裝置檢查';

  @override
  String get howProtectionWorks => '保護機制如何運作';

  @override
  String get lockedDoor => '把你的訊息想像成一扇上鎖的門。';

  @override
  String get sharedPassphraseKey => '共享密碼就是鑰匙。';

  @override
  String get lockTurns => '在門打開之前，這把鎖需要進行很多次運算。';

  @override
  String get moreTurnsHarderGuessing => '運算次數越多，持續猜測密碼所需的成本也越高。';

  @override
  String get moreTurnsMoreWork => '但運算次數越多，手機也需要做更多工作。';

  @override
  String get otherPhoneSameWork => '對方的手機也需要進行相同的運算，因此較強的設定在舊手機上可能會比較慢。';

  @override
  String get threeProtectionLevels => '三種保護等級';

  @override
  String get compatibilityDeviceDescription => '運算次數較少，在較舊的手機上速度較快。';

  @override
  String get balancedDeviceDescription => '提高猜測成本，同時維持中等的手機負擔。';

  @override
  String get strongerDeviceDescription => '運算次數更多，能提高重複猜測的成本，但在部分手機上會較慢。';

  @override
  String get whichLevelFits => '哪個等級適合這台裝置？';

  @override
  String get deviceCheckDescription =>
      'Veilmi 可以測量每個保護等級在這台手機上所需的時間，並提供一個較實用的建議。';

  @override
  String get checkingDevice => '正在檢查這台裝置...';

  @override
  String get checking => '檢查中...';

  @override
  String get checkThisDevice => '檢查這台裝置';

  @override
  String get deviceCheckFailed => '裝置檢查失敗。';

  @override
  String get recommendedForDevice => '建議這台裝置使用：';

  @override
  String pbkdf2Implementation(String implementation) {
    return 'PBKDF2 實作：$implementation';
  }

  @override
  String protectionTime(String level, String seconds) {
    return '$level：$seconds 秒';
  }

  @override
  String turns(String count) {
    return '$count 次運算';
  }
}
