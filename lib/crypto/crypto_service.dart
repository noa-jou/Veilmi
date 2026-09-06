import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'message_envelope.dart';

import 'package:cryptography/cryptography.dart';

class CryptoService {
  const CryptoService();

  static const int saltLength = 16;
  static const int pbkdf2Iterations = 600000;

  Uint8List generateRandomBytes(int length) {
    final random = Random.secure();

    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List generateSalt() {
    return generateRandomBytes(saltLength);
  }

  Future<SecretKey> deriveKey({
    required String passphrase,
    required List<int> salt,
    int iterations = pbkdf2Iterations,
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

  Future<SecretBox> encrypt({
    required String plaintext,
    required SecretKey secretKey,
  }) async {
    final algorithm = AesGcm.with256bits();

    return algorithm.encrypt(utf8.encode(plaintext), secretKey: secretKey);
  }

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

  Future<String> encryptMessage({
    required String plaintext,
    required String passphrase,
  }) async {
    final salt = generateSalt();

    final secretKey = await deriveKey(passphrase: passphrase, salt: salt);

    final secretBox = await encrypt(plaintext: plaintext, secretKey: secretKey);

    final envelope = MessageEnvelope(
      salt: salt,
      secretBox: secretBox,
      iterations: pbkdf2Iterations,
    );

    return envelope.encode();
  }

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
