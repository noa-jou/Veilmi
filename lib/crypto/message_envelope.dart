import 'dart:convert';

import 'crypto_constants.dart';

import 'package:cryptography/cryptography.dart';

class MessageEnvelope {
  static const String prefix = 'VEILMI1:';
  static const int version = 1;

  final List<int> salt;
  final SecretBox secretBox;

  static const String kdf = 'PBKDF2-SHA256';

  final int iterations;

  const MessageEnvelope({
    required this.salt,
    required this.secretBox,
    required this.iterations,
  });

  String encode() {
    final data = {
      'v': version,
      'k': kdf,
      'i': iterations,
      's': base64UrlEncode(salt),
      'n': base64UrlEncode(secretBox.nonce),
      'c': base64UrlEncode(secretBox.cipherText),
      'm': base64UrlEncode(secretBox.mac.bytes),
    };

    final jsonBytes = utf8.encode(jsonEncode(data));
    final encoded = base64UrlEncode(jsonBytes);

    return '$prefix$encoded';
  }

  static MessageEnvelope decode(String encodedMessage) {
    if (!encodedMessage.startsWith(prefix)) {
      throw const FormatException('Invalid Veilmi message prefix.');
    }

    final payload = encodedMessage.substring(prefix.length);

    if (payload.isEmpty) {
      throw const FormatException('Veilmi message payload is empty.');
    }

    try {
      final jsonBytes = base64Url.decode(payload);
      final decodedJson = jsonDecode(utf8.decode(jsonBytes));

      if (decodedJson is! Map<String, dynamic>) {
        throw const FormatException('Invalid Veilmi message format.');
      }

      final versionValue = decodedJson['v'];
      final saltValue = decodedJson['s'];
      final nonceValue = decodedJson['n'];
      final cipherTextValue = decodedJson['c'];
      final macValue = decodedJson['m'];
      final kdfValue = decodedJson['k'];
      final iterationsValue = decodedJson['i'];

      if (versionValue is! int ||
          kdfValue is! String ||
          iterationsValue is! int ||
          saltValue is! String ||
          nonceValue is! String ||
          cipherTextValue is! String ||
          macValue is! String) {
        throw const FormatException(
          'Veilmi message contains invalid or missing fields.',
        );
      }

      if (versionValue != version) {
        throw const FormatException('Unsupported Veilmi message version.');
      }

      if (kdfValue != kdf) {
        throw const FormatException(
          'Unsupported Veilmi key derivation function.',
        );
      }

      if (iterationsValue != CryptoConstants.pbkdf2Iterations) {
        throw const FormatException(
          'Unsupported Veilmi PBKDF2 iteration count.',
        );
      }

      final salt = base64Url.decode(saltValue);
      final nonce = base64Url.decode(nonceValue);
      final cipherText = base64Url.decode(cipherTextValue);
      final macBytes = base64Url.decode(macValue);

      if (salt.length != CryptoConstants.saltLength) {
        throw const FormatException('Invalid Veilmi salt length.');
      }

      if (nonce.length != CryptoConstants.nonceLength) {
        throw const FormatException('Invalid Veilmi nonce length.');
      }

      if (macBytes.length != CryptoConstants.macLength) {
        throw const FormatException('Invalid authentication tag length.');
      }

      if (cipherText.isEmpty) {
        throw const FormatException('Ciphertext must not be empty.');
      }

      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

      return MessageEnvelope(
        salt: salt,
        secretBox: secretBox,
        iterations: iterationsValue,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Invalid Veilmi message encoding.');
    }
  }
}
