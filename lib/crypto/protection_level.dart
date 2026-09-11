import 'crypto_constants.dart';

// This enum represents the different security levels the app can choose.
//
// In simple terms:
// - Compatibility = fastest, weaker protection
// - Balanced = middle ground
// - Stronger = slowest, strongest protection
//
// The app uses these values to decide how much PBKDF2 work to do.
enum ProtectionLevel {
  compatibility,
  balanced,
  stronger;

  // A user-friendly display name for each level.
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

  // Short description shown in the UI.
  // It explains the trade-off between speed and security.
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

  // Returns the PBKDF2 iteration count for this level.
  // Higher numbers are more secure but slower.
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
