import 'crypto_constants.dart';

enum ProtectionLevel {
  compatibility,
  balanced,
  stronger;

  String get title {
    switch (this) {
      case ProtectionLevel.compatibility:
        return 'Compatibility';
      case ProtectionLevel.balanced:
        return 'Balanced';
      case ProtectionLevel.stronger:
        return 'Stronger';
    }
  }

  String get summary {
    switch (this) {
      case ProtectionLevel.compatibility:
        return 'Faster on older devices.';
      case ProtectionLevel.balanced:
        return 'A balance between protection and speed.';
      case ProtectionLevel.stronger:
        return 'More resistant to repeated passphrase guessing.';
    }
  }

  int get iterations {
    switch (this) {
      case ProtectionLevel.compatibility:
        return CryptoConstants.compatibilityIterations;
      case ProtectionLevel.balanced:
        return CryptoConstants.balancedIterations;
      case ProtectionLevel.stronger:
        return CryptoConstants.strongerIterations;
    }
  }
}
