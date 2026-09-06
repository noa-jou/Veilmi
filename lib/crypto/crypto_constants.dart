class CryptoConstants {
  const CryptoConstants._();

  static const int compatibilityIterations = 50000;
  static const int balancedIterations = 100000;
  static const int strongerIterations = 600000;

  static const int pbkdf2Iterations = strongerIterations;

  static const Set<int> supportedPbkdf2Iterations = {
    compatibilityIterations,
    balancedIterations,
    strongerIterations,
  };

  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int macLength = 16;
}
