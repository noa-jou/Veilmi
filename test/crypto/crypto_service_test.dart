import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/crypto/crypto_service.dart';
import 'package:veilmi/crypto/crypto_constants.dart';
import 'package:veilmi/crypto/message_envelope.dart';
import 'package:veilmi/crypto/protection_level.dart';

void main() {
  const cryptoService = CryptoService();

  test('generates the requested number of random bytes', () {
    final bytes = cryptoService.generateRandomBytes(16);

    expect(bytes.length, 16);
  });

  test('generates different random bytes each time', () {
    final first = cryptoService.generateRandomBytes(16);
    final second = cryptoService.generateRandomBytes(16);

    expect(first, isNot(equals(second)));
  });

  test('encrypts and decrypts a message', () async {
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();

    const plaintext = 'Hello, Veilmi!';

    final secretBox = await cryptoService.encrypt(
      plaintext: plaintext,
      secretKey: secretKey,
    );

    final decrypted = await cryptoService.decrypt(
      secretBox: secretBox,
      secretKey: secretKey,
    );

    expect(decrypted, plaintext);
  });

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

  test('encrypts and decrypts using a shared passphrase', () async {
    const passphrase = 'correct horse battery staple';
    const plaintext = '你好，Veilmi! 🔐';

    final salt = cryptoService.generateSalt();

    final encryptionKey = await cryptoService.deriveKey(
      passphrase: passphrase,
      salt: salt,
    );

    final secretBox = await cryptoService.encrypt(
      plaintext: plaintext,
      secretKey: encryptionKey,
    );

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

  test('encryptMessage uses the selected protection level', () async {
    const service = CryptoService();

    final encodedMessage = await service.encryptMessage(
      plaintext: 'Hello Veilmi',
      passphrase: 'shared-secret',
      protectionLevel: ProtectionLevel.balanced,
    );

    final envelope = MessageEnvelope.decode(encodedMessage);

    expect(envelope.iterations, CryptoConstants.balancedIterations);
  });
}
