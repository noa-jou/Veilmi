import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto_constants.dart';
import 'message_envelope.dart';
import 'protection_level.dart';

// This class contains the main encryption and decryption operations.
// In beginner terms:
// - it turns the user's passphrase into a secure key,
// - encrypts the message,
// - wraps the result in a message envelope,
// - and later reads it back.
class CryptoService {
  const CryptoService();

  // Generate random bytes of a requested length.
  // This is used to create a salt, which makes the same password produce different keys.
  Uint8List generateRandomBytes(int length) {
    final random = Random.secure();

    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  // Create a random salt for password-based key derivation.
  // A salt makes the encryption stronger by preventing identical passwords
  // from producing the same key every time.
  Uint8List generateSalt() {
    return generateRandomBytes(CryptoConstants.saltLength);
  }

  // Turn a passphrase into a secret key using PBKDF2.
  // PBKDF2 is slow on purpose, so attackers need much more work to guess passwords.
  Future<SecretKey> deriveKey({
    required String passphrase,
    required List<int> salt,
    int iterations = CryptoConstants.pbkdf2Iterations,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  // Encrypt plain text with AES-GCM using the derived key.
  // AES-GCM hides the message and also verifies that it has not been modified.
  Future<SecretBox> encrypt({
    required String plaintext,
    required SecretKey secretKey,
  }) async {
    final algorithm = AesGcm.with256bits();

    return algorithm.encrypt(utf8.encode(plaintext), secretKey: secretKey);
  }

  // Decrypt a SecretBox back into readable text.
  // This will fail if the key is wrong or if the message was changed.
  Future<String> decrypt({
    required SecretBox secretBox,
    required SecretKey secretKey,
  }) async {
    final algorithm = AesGcm.with256bits();

    final clearTextBytes = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearTextBytes);
  }

  // This is the high-level encryption flow for the app.
  // It does these steps:
  // 1. create a random salt
  // 2. derive a key from passphrase + salt + chosen iterations
  // 3. encrypt the plaintext with AES-GCM
  // 4. store everything in a MessageEnvelope
  // 5. return the final encoded message string
  Future<String> encryptMessage({
    required String plaintext,
    required String passphrase,
    ProtectionLevel protectionLevel = ProtectionLevel.stronger,
  }) async {
    final salt = generateSalt();

    final secretKey = await deriveKey(
      passphrase: passphrase,
      salt: salt,
      iterations: protectionLevel.iterations,
    );

    final secretBox = await encrypt(plaintext: plaintext, secretKey: secretKey);

    final envelope = MessageEnvelope(
      salt: salt,
      secretBox: secretBox,
      iterations: protectionLevel.iterations,
    );

    return envelope.encode();
  }

  // This is the reverse process.
  // It reads the message envelope, rebuilds the key from the same passphrase,
  // and decrypts the ciphertext if everything matches.
  Future<String> decryptMessage({
    required String encodedMessage,
    required String passphrase,
  }) async {
    final envelope = MessageEnvelope.decode(encodedMessage);

    final secretKey = await deriveKey(
      passphrase: passphrase,
      salt: envelope.salt,
      iterations: envelope.iterations,
    );

    return decrypt(secretBox: envelope.secretBox, secretKey: secretKey);
  }
}
