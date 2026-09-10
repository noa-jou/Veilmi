import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/crypto/crypto_service.dart';
import 'package:veilmi/crypto/crypto_constants.dart';
import 'package:veilmi/crypto/message_envelope.dart';
import 'package:veilmi/crypto/protection_level.dart';

// These tests check that the crypto service works correctly.
// A beginner can think of these as small checks:
// "Does it create random bytes? Does it encrypt and decrypt properly?"
void main() {
  // One shared service instance is enough for all tests in this file.
  const cryptoService = CryptoService();

  // This test checks that the app creates the exact number of random bytes requested.
  test('generates the requested number of random bytes', () {
    final bytes = cryptoService.generateRandomBytes(16);

    expect(bytes.length, 16);
  });

  // This test checks that random bytes are not the same every time.
  test('generates different random bytes each time', () {
    final first = cryptoService.generateRandomBytes(16);
    final second = cryptoService.generateRandomBytes(16);

    expect(first, isNot(equals(second)));
  });

  // This test checks the basic encrypt/decrypt flow using a secret key.
  test('encrypts and decrypts a message', () async {
    // Create a new AES-GCM key for this test.
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();

    const plaintext = 'Hello, Veilmi!';

    // Encrypt the message.
    final secretBox = await cryptoService.encrypt(
      plaintext: plaintext,
      secretKey: secretKey,
    );

    // Decrypt it back.
    final decrypted = await cryptoService.decrypt(
      secretBox: secretBox,
      secretKey: secretKey,
    );

    expect(decrypted, plaintext);
  });

  // This test checks that the same passphrase + salt always creates the same key.
  test('same passphrase and salt derive the same key', () async {
    final salt = cryptoService.generateSalt();

    final firstKey = await cryptoService.deriveKey(
      passphrase: 'correct horse battery staple',
      salt: salt,
    );

    final secondKey = await cryptoService.deriveKey(
      passphrase: 'correct horse battery staple',
      salt: salt,
    );

    final firstBytes = await firstKey.extractBytes();
    final secondBytes = await secondKey.extractBytes();

    expect(firstBytes, equals(secondBytes));
  });

  // This test checks that a passphrase-based encryption works in real use.
  test('encrypts and decrypts using a shared passphrase', () async {
    const passphrase = 'correct horse battery staple';
    const plaintext = '你好，Veilmi! 🔐';

    final salt = cryptoService.generateSalt();

    // Derive the same encryption key from the passphrase and salt.
    final encryptionKey = await cryptoService.deriveKey(
      passphrase: passphrase,
      salt: salt,
    );

    final secretBox = await cryptoService.encrypt(
      plaintext: plaintext,
      secretKey: encryptionKey,
    );

    // Derive the same decryption key using the same passphrase and salt.
    final decryptionKey = await cryptoService.deriveKey(
      passphrase: passphrase,
      salt: salt,
    );

    final decrypted = await cryptoService.decrypt(
      secretBox: secretBox,
      secretKey: decryptionKey,
    );

    expect(decrypted, plaintext);
  });

  // This test checks that the chosen protection level affects the final encryption parameters.
  test('encryptMessage uses the selected protection level', () async {
    const service = CryptoService();

    final encodedMessage = await service.encryptMessage(
      plaintext: 'Hello Veilmi',
      passphrase: 'shared-secret',
      protectionLevel: ProtectionLevel.balanced,
    );

    // Decode the message envelope to see which PBKDF2 iteration count was used.
    final envelope = MessageEnvelope.decode(encodedMessage);

    expect(envelope.iterations, CryptoConstants.balancedIterations);
  });
}
