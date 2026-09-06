import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';

class DeviceCheckScreen extends StatefulWidget {
  const DeviceCheckScreen({super.key});

  @override
  State<DeviceCheckScreen> createState() => _DeviceCheckScreenState();
}

class _DeviceCheckScreenState extends State<DeviceCheckScreen> {
  bool _isRunning = false;
  String _result = '';

  Future<void> _checkDevice() async {
    if (_isRunning) {
      return;
    }

    setState(() {
      _isRunning = true;
      _result = 'Checking this device...';
    });

    final buffer = StringBuffer();

    final times = <ProtectionLevel, double>{};

    try {
      final implementationCheck = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: ProtectionLevel.compatibility.iterations,
        bits: 256,
      );

      buffer.writeln(
        'PBKDF2 implementation: ${implementationCheck.runtimeType}',
      );
      buffer.writeln();

      final salt = List<int>.generate(16, (index) => index);

      const passphrase = 'veilmi-device-check';

      for (final level in ProtectionLevel.values) {
        final runTimes = <int>[];

        for (var run = 0; run < 3; run++) {
          final pbkdf2 = Pbkdf2(
            macAlgorithm: Hmac.sha256(),
            iterations: level.iterations,
            bits: 256,
          );

          final stopwatch = Stopwatch()..start();

          await pbkdf2.deriveKey(
            secretKey: SecretKey(passphrase.codeUnits),
            nonce: salt,
          );

          stopwatch.stop();

          runTimes.add(stopwatch.elapsedMilliseconds);
        }

        final averageMilliseconds =
            runTimes.reduce((a, b) => a + b) / runTimes.length;

        times[level] = averageMilliseconds;

        buffer.writeln(
          '${level.title}: '
          '${(averageMilliseconds / 1000).toStringAsFixed(1)} s',
        );
      }

      final strongerTime = times[ProtectionLevel.stronger] ?? double.infinity;

      final balancedTime = times[ProtectionLevel.balanced] ?? double.infinity;

      String recommendation;

      if (strongerTime <= 5000) {
        recommendation = ProtectionLevel.stronger.title;
      } else if (balancedTime <= 5000) {
        recommendation = ProtectionLevel.balanced.title;
      } else {
        recommendation = ProtectionLevel.compatibility.title;
      }

      buffer.writeln();
      buffer.writeln('Recommended for this device:');
      buffer.writeln(recommendation);

      if (!mounted) {
        return;
      }

      setState(() {
        _result = buffer.toString().trim();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _result = 'Device check failed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protection & Device Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How protection levels work',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Imagine your passphrase is the key to your front door. '
              'Before the key can open the door, the lock requires it '
              'to turn again and again.',
            ),
            const SizedBox(height: 12),
            const Text(
              'A higher protection level requires more turns. '
              'This makes each passphrase guess more expensive for '
              'an attacker, but your phone must also spend more time '
              'unlocking the message.',
            ),
            const SizedBox(height: 12),
            const Text(
              "The recipient's phone must do the same work, so a level "
              'that feels fast on your phone may be slower on theirs.',
            ),
            const SizedBox(height: 32),
            Text(
              'Which lock fits this device?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Veilmi can test how long each protection level takes '
              'on this device and suggest a suitable option.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isRunning ? null : _checkDevice,
              icon: _isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.speed_outlined),
              label: Text(_isRunning ? 'Checking...' : 'Check This Device'),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 24),
              SelectableText(
                _result,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
