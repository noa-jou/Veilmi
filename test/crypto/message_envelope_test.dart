import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/crypto/message_envelope.dart';
import 'package:veilmi/crypto/crypto_service.dart';

import 'dart:convert';

final cryptoService = CryptoService();

void main() {
  test('encodes and decodes a Veilmi message envelope', () {
    final salt = List<int>.generate(16, (index) => index);

    final nonce = List<int>.generate(12, (index) => index + 16);

    final macBytes = List<int>.generate(16, (index) => index + 32);

    final secretBox = SecretBox(
      [10, 20, 30, 40],
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final envelope = MessageEnvelope(
      salt: salt,
      secretBox: secretBox,
      iterations: 600000,
    );

    final encoded = envelope.encode();
    final decoded = MessageEnvelope.decode(encoded);

    expect(encoded.startsWith('VEILMI1:'), isTrue);

    expect(decoded.salt, equals(salt));
    expect(decoded.secretBox.cipherText, equals(secretBox.cipherText));
    expect(decoded.secretBox.nonce, equals(secretBox.nonce));
    expect(decoded.secretBox.mac.bytes, equals(secretBox.mac.bytes));
  });
  test('rejects messages without the VEILMI1 prefix', () {
    expect(() => MessageEnvelope.decode('NOTVEIL:abc'), throwsFormatException);
  });

  test('encrypts and decrypts a complete Veilmi message', () async {
    const passphrase = 'correct horse battery staple';
    const plaintext = '這是一封秘密訊息 🔐';

    final encodedMessage = await cryptoService.encryptMessage(
      plaintext: plaintext,
      passphrase: passphrase,
    );

    expect(encodedMessage.startsWith('VEILMI1:'), isTrue);
    expect(encodedMessage, isNot(contains(plaintext)));

    final decrypted = await cryptoService.decryptMessage(
      encodedMessage: encodedMessage,
      passphrase: passphrase,
    );

    expect(decrypted, plaintext);
  });

  test('rejects an incorrect passphrase', () async {
    final encodedMessage = await cryptoService.encryptMessage(
      plaintext: 'Top secret',
      passphrase: 'correct passphrase',
    );

    expect(
      () => cryptoService.decryptMessage(
        encodedMessage: encodedMessage,
        passphrase: 'wrong passphrase',
      ),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('rejects tampered ciphertext', () async {
    const passphrase = 'correct horse battery staple';

    final encodedMessage = await cryptoService.encryptMessage(
      plaintext: 'Top secret',
      passphrase: passphrase,
    );

    final envelope = MessageEnvelope.decode(encodedMessage);

    final tamperedCipherText = List<int>.from(envelope.secretBox.cipherText);

    tamperedCipherText[0] ^= 1;

    final tamperedEnvelope = MessageEnvelope(
      salt: envelope.salt,
      secretBox: SecretBox(
        tamperedCipherText,
        nonce: envelope.secretBox.nonce,
        mac: envelope.secretBox.mac,
      ),
      iterations: envelope.iterations,
    );

    expect(
      () => cryptoService.decryptMessage(
        encodedMessage: tamperedEnvelope.encode(),
        passphrase: passphrase,
      ),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('rejects tampered nonce', () async {
    const passphrase = 'correct horse battery staple';

    final encodedMessage = await cryptoService.encryptMessage(
      plaintext: 'Top secret',
      passphrase: passphrase,
    );

    final envelope = MessageEnvelope.decode(encodedMessage);

    final tamperedNonce = List<int>.from(envelope.secretBox.nonce);

    tamperedNonce[0] ^= 1;

    final tamperedEnvelope = MessageEnvelope(
      salt: envelope.salt,
      secretBox: SecretBox(
        envelope.secretBox.cipherText,
        nonce: tamperedNonce,
        mac: envelope.secretBox.mac,
      ),
      iterations: envelope.iterations,
    );

    expect(
      () => cryptoService.decryptMessage(
        encodedMessage: tamperedEnvelope.encode(),
        passphrase: passphrase,
      ),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('rejects tampered authentication tag', () async {
    const passphrase = 'correct horse battery staple';

    final encodedMessage = await cryptoService.encryptMessage(
      plaintext: 'Top secret',
      passphrase: passphrase,
    );

    final envelope = MessageEnvelope.decode(encodedMessage);

    final tamperedMac = List<int>.from(envelope.secretBox.mac.bytes);

    tamperedMac[0] ^= 1;

    final tamperedEnvelope = MessageEnvelope(
      salt: envelope.salt,
      secretBox: SecretBox(
        envelope.secretBox.cipherText,
        nonce: envelope.secretBox.nonce,
        mac: Mac(tamperedMac),
      ),
      iterations: envelope.iterations,
    );

    expect(
      () => cryptoService.decryptMessage(
        encodedMessage: tamperedEnvelope.encode(),
        passphrase: passphrase,
      ),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('encrypting the same message twice produces different output', () async {
    const passphrase = 'correct horse battery staple';
    const plaintext = 'Same secret message';

    final first = await cryptoService.encryptMessage(
      plaintext: plaintext,
      passphrase: passphrase,
    );

    final second = await cryptoService.encryptMessage(
      plaintext: plaintext,
      passphrase: passphrase,
    );

    expect(first, isNot(equals(second)));
  });

  test('rejects an empty payload', () {
    expect(() => MessageEnvelope.decode('VEILMI1:'), throwsFormatException);
  });

  test('rejects invalid Base64URL', () {
    expect(() => MessageEnvelope.decode('VEILMI1:%%%'), throwsFormatException);
  });

  test('rejects unsupported message version', () {
    final data = {
      'v': 99,
      'k': 'PBKDF2-SHA256',
      'i': 600000,
      's': base64UrlEncode(List<int>.filled(16, 1)),
      'n': base64UrlEncode(List<int>.filled(12, 2)),
      'c': base64UrlEncode([3]),
      'm': base64UrlEncode(List<int>.filled(16, 4)),
    };

    final encoded = base64UrlEncode(utf8.encode(jsonEncode(data)));

    expect(
      () => MessageEnvelope.decode('VEIMI1:$encoded'),
      throwsFormatException,
    );
  });

  test('rejects an invalid nonce length', () {
    final data = {
      'v': 1,
      'k': 'PBKDF2-SHA256',
      'i': 600000,
      's': base64UrlEncode(List<int>.filled(16, 1)),
      'n': base64UrlEncode([1, 2]),
      'c': base64UrlEncode([3]),
      'm': base64UrlEncode(List<int>.filled(16, 4)),
    };

    final encoded = base64UrlEncode(utf8.encode(jsonEncode(data)));

    expect(
      () => MessageEnvelope.decode('VEILMI1:$encoded'),
      throwsFormatException,
    );
  });

  test('rejects an invalid authentication tag length', () {
    final data = {
      'v': 1,
      'k': 'PBKDF2-SHA256',
      'i': 600000,
      's': base64UrlEncode(List<int>.filled(16, 1)),
      'n': base64UrlEncode(List<int>.filled(12, 2)),
      'c': base64UrlEncode([3]),
      'm': base64UrlEncode([4, 5]),
    };

    final encoded = base64UrlEncode(utf8.encode(jsonEncode(data)));

    expect(
      () => MessageEnvelope.decode('VEIMI1:$encoded'),
      throwsFormatException,
    );
  });
  test('rejects unsupported PBKDF2 iteration count', () {
    final data = {
      'v': 1,
      'k': 'PBKDF2-SHA256',
      'i': 999999999,
      's': base64UrlEncode(List<int>.generate(16, (index) => index)),
      'n': base64UrlEncode(List<int>.generate(12, (index) => index + 16)),
      'c': base64UrlEncode([1, 2, 3]),
      'm': base64UrlEncode(List<int>.generate(16, (index) => index + 32)),
    };

    final encoded =
        'VEILMI1:${base64UrlEncode(utf8.encode(jsonEncode(data)))}';

    expect(
      () => MessageEnvelope.decode(encoded),
      throwsA(isA<FormatException>()),
    );
});


}
