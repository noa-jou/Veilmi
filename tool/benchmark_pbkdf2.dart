import 'dart:convert';

import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  const passphrase = 'benchmark-passphrase';
  final salt = List<int>.generate(16, (index) => index);

  final testIterations = [100000, 300000, 600000];

  const runs = 3;

  for (final iterations in testIterations) {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    final times = <int>[];

    for (var run = 1; run <= runs; run++) {
      final stopwatch = Stopwatch()..start();

      await pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(passphrase)),
        nonce: salt,
      );

      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);

      print(
        '$iterations iterations, run $run: '
        '${stopwatch.elapsedMilliseconds} ms',
      );
    }

    final average = times.reduce((a, b) => a + b) / times.length;

    print(
      '$iterations iterations average: '
      '${average.toStringAsFixed(1)} ms\n',
    );
  }
}
