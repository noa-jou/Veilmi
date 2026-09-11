// This class stores the fixed values used by the app's encryption system.
// Think of it as a small "settings file" for cryptography.
//
// These values control:
// - how much work is required to turn a password into a key,
// - how long the random salt and nonce should be,
// - and which PBKDF2 iteration counts are accepted.
class CryptoConstants {
  // Private constructor so nobody creates an instance of this class.
  // It is meant to be used as a static utility only.
  const CryptoConstants._();

  // These are the three protection levels.
  // Larger numbers mean more CPU work, which makes password guessing harder,
  // but also makes the app slower on weaker devices.
  static const int compatibilityIterations = 50000;
  static const int balancedIterations = 100000;
  static const int strongerIterations = 600000;

  // The app's current default PBKDF2 iteration count.
  // In other words: if the app is not told otherwise, it uses the stronger setting.
  static const int pbkdf2Iterations = strongerIterations;

  // These are the allowed iteration counts for the encrypted message format.
  // If a message uses a number not in this set, it should be rejected as unsupported.
  static const Set<int> supportedPbkdf2Iterations = {
    compatibilityIterations,
    balancedIterations,
    strongerIterations,
  };

  // These sizes are used in the message envelope.
  // They define how many random bytes are generated for cryptographic values.
  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int macLength = 16;
}
