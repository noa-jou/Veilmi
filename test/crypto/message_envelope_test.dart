import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veilmi/crypto/crypto_constants.dart';
import 'package:veilmi/crypto/message_envelope.dart';
import 'package:veilmi/crypto/crypto_service.dart';

import 'dart:convert';

// We use one shared crypto service for the tests below.
final cryptoService = CryptoService();

// These tests check that the message envelope format is valid,
// that data can be safely encoded and decoded,
// and that tampering is detected.
void main() {
  // This test checks that a message envelope can be created,
  // encoded into a string, decoded back, and still contain the same data.
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

    // All valid Veilmi messages start with this prefix.
    expect(encoded.startsWith('VEILMI1:'), isTrue);

    // After decoding, the original values should still be present.
    expect(decoded.salt, equals(salt));
    expect(decoded.secretBox.cipherText, equals(secretBox.cipherText));
    expect(decoded.secretBox.nonce, equals(secretBox.nonce));
    expect(decoded.secretBox.mac.bytes, equals(secretBox.mac.bytes));
  });

  // This test checks that invalid messages are rejected.
  test('rejects messages without the VEILMI1 prefix', () {
    expect(() => MessageEnvelope.decode('NOTVEIL:abc'), throwsFormatException);
  });

  // This test checks the full real-world flow:
  // encrypt a message, then decrypt it back using the same passphrase.
  test('encrypts and decrypts a complete Veilmi message', () async {
    const passphrase = 'correct horse battery staple';
    const plaintext = '這是一封秘密訊息 🔐';

    final encodedMessage = await cryptoService.encryptMessage(
      plaintext: plaintext,
      passphrase: passphrase,
    );

    // The encoded result should start with a Veilmi header and should not contain plain text.
    expect(encodedMessage.startsWith('VEILMI1:'), isTrue);
    expect(encodedMessage, isNot(contains(plaintext)));

    final decrypted = await cryptoService.decryptMessage(
      encodedMessage: encodedMessage,
      passphrase: passphrase,
    );

    expect(decrypted, plaintext);
  });

  // This test checks that the wrong passphrase cannot decrypt the message.
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

  // This test changes the ciphertext and verifies the app rejects the tampered message.
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

  // This test changes the nonce and checks that the message is rejected.
  // A nonce is a random value used in encryption; changing it should break the authentication.
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

  // This test changes the authentication tag (MAC) and ensures the message is rejected.
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

  // This test checks that encrypting the same text twice does not produce exactly the same string.
  // Different random values should be used so attackers cannot tell that the plaintext is the same.
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

  // These tests verify that malformed envelope payloads are rejected.
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
      () => MessageEnvelope.decode('VEILMI1:$encoded'),
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
      () => MessageEnvelope.decode('VEILMI1:$encoded'),
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

    final encoded = 'VEILMI1:${base64UrlEncode(utf8.encode(jsonEncode(data)))}';

    expect(
      () => MessageEnvelope.decode(encoded),
      throwsA(isA<FormatException>()),
    );
  });
  // This test verifies that every valid supported iteration count is accepted.
  test('accepts all supported PBKDF2 iteration counts', () {
    for (final iterations in CryptoConstants.supportedPbkdf2Iterations) {
      final json = jsonEncode({
        'v': 1,
        'k': 'PBKDF2-SHA256',
        'i': iterations,
        's': base64UrlEncode(List<int>.filled(16, 1)),
        'n': base64UrlEncode(List<int>.filled(12, 2)),
        'c': base64UrlEncode([3]),
        'm': base64UrlEncode(List<int>.filled(16, 4)),
      });

      final encoded = 'VEILMI1:${base64UrlEncode(utf8.encode(json))}';

      final envelope = MessageEnvelope.decode(encoded);

      expect(envelope.iterations, iterations);
    }
  });
}
