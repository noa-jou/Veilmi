// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cryptography/cryptography.dart';

// This script measures how long PBKDF2 takes on this machine.
// PBKDF2 is the algorithm used to make passwords slower to brute-force.
// This is useful because the app lets the user choose different protection levels.
Future<void> main() async {
  // A simple passphrase used for benchmarking.
  const passphrase = 'benchmark-passphrase';

  // A fixed salt so every test is using the same input.
  // This makes the results easier to compare.
  final salt = List<int>.generate(16, (index) => index);

  // These are the iteration counts we want to compare.
  // More iterations usually means better security, but slower performance.
  final testIterations = [100000, 300000, 600000];

  // Run each test 3 times and average the result.
  const runs = 3;

  // Loop over each iteration count.
  for (final iterations in testIterations) {
    // Create a PBKDF2 object with SHA-256 and 256-bit output.
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    // Store the time it takes for each run.
    final times = <int>[];

    // Run the same benchmark multiple times to reduce noise.
    for (var run = 1; run <= runs; run++) {
      final stopwatch = Stopwatch()..start();

      // Derive a key using PBKDF2.
      // This is the part we are timing.
      await pbkdf2.deriveKey(
        secretKey: SecretKey(utf8.encode(passphrase)),
        nonce: salt,
      );

      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);

      // Print the timing for this specific run.
      print(
        '$iterations iterations, run $run: '
        '${stopwatch.elapsedMilliseconds} ms',
      );
    }

    // Average all run times for this iteration count.
    final average = times.reduce((a, b) => a + b) / times.length;

    // Print the average result for the whole test set.
    print(
      '$iterations iterations average: '
      '${average.toStringAsFixed(1)} ms\n',
    );
  }
}
