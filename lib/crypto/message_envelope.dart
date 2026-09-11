import 'dart:convert';

import 'crypto_constants.dart';

import 'package:cryptography/cryptography.dart';

// This class wraps the encrypted content in a standard message format.
//
// In simple terms, it says:
// - which version of the format is being used,
// - which key-derivation function was used,
// - how many PBKDF2 iterations were used,
// - the random salt,
// - the nonce,
// - the ciphertext,
// - and the authentication tag.
//
// This allows the app to later decode the message and verify that it was not changed.
class MessageEnvelope {
  // Every Veilmi message starts with this prefix so the app knows how to parse it.
  static const String prefix = 'VEILMI1:';

  // Message format version.
  // If the app later introduces a new format, the version number will change.
  static const int version = 1;

  // The random salt used during key derivation.
  final List<int> salt;

  // This contains the actual encrypted data and authentication tag.
  final SecretBox secretBox;

  // Name of the key derivation algorithm used.
  static const String kdf = 'PBKDF2-SHA256';

  // How many PBKDF2 rounds were used when deriving the encryption key.
  final int iterations;

  const MessageEnvelope({
    required this.salt,
    required this.secretBox,
    required this.iterations,
  });

  // Encode the encrypted data into a single string that can be copied and sent.
  String encode() {
    final data = {
      // 'v' = version
      'v': version,
      // 'k' = key derivation algorithm name
      'k': kdf,
      // 'i' = PBKDF2 iterations
      'i': iterations,
      // 's' = salt, stored as Base64URL text
      's': base64UrlEncode(salt),
      // 'n' = nonce used by AES-GCM
      'n': base64UrlEncode(secretBox.nonce),
      // 'c' = ciphertext
      'c': base64UrlEncode(secretBox.cipherText),
      // 'm' = MAC / authentication tag; used to detect tampering
      'm': base64UrlEncode(secretBox.mac.bytes),
    };

    // Convert the JSON map to bytes and then base64-url encode it.
    final jsonBytes = utf8.encode(jsonEncode(data));
    final encoded = base64UrlEncode(jsonBytes);

    // Add the app-specific prefix so the receiving code knows it is a Veilmi message.
    return '$prefix$encoded';
  }

  // Decode a Veilmi string back into a MessageEnvelope.
  static MessageEnvelope decode(String encodedMessage) {
    // Every valid message must start with the expected prefix.
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

      // Read all required fields from the JSON object.
      final versionValue = decodedJson['v'];
      final saltValue = decodedJson['s'];
      final nonceValue = decodedJson['n'];
      final cipherTextValue = decodedJson['c'];
      final macValue = decodedJson['m'];
      final kdfValue = decodedJson['k'];
      final iterationsValue = decodedJson['i'];

      // Make sure all expected fields are present and have the correct basic types.
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

      // Make sure the message format is supported.
      if (versionValue != version) {
        throw const FormatException('Unsupported Veilmi message version.');
      }

      if (kdfValue != kdf) {
        throw const FormatException(
          'Unsupported Veilmi key derivation function.',
        );
      }

      if (!CryptoConstants.supportedPbkdf2Iterations.contains(
        iterationsValue,
      )) {
        throw const FormatException(
          'Unsupported Veilmi PBKDF2 iteration count.',
        );
      }

      // Convert the stored Base64URL strings back into raw bytes.
      final salt = base64Url.decode(saltValue);
      final nonce = base64Url.decode(nonceValue);
      final cipherText = base64Url.decode(cipherTextValue);
      final macBytes = base64Url.decode(macValue);

      // Validate sizes so the message is not malformed.
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

      // Rebuild the SecretBox object from the decoded values.
      final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

      // Return a new MessageEnvelope object with the decoded data.
      return MessageEnvelope(
        salt: salt,
        secretBox: secretBox,
        iterations: iterationsValue,
      );
    } on FormatException {
      // Let the app-specific validation errors pass through.
      rethrow;
    } catch (_) {
      // Catch any unexpected problem and convert it into a clean message format error.
      throw const FormatException('Invalid Veilmi message encoding.');
    }
  }
}
