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
  static const int _recommendedMaxMilliseconds = 5000;

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

      final strongerTime =
          times[ProtectionLevel.stronger] ?? double.infinity;
      final balancedTime =
          times[ProtectionLevel.balanced] ?? double.infinity;

      String recommendation;

      if (strongerTime <= _recommendedMaxMilliseconds) {
        recommendation = ProtectionLevel.stronger.title;
      } else if (balancedTime <= _recommendedMaxMilliseconds) {
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
      appBar: AppBar(
        title: const Text('Protection & Device Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How protection works',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Think of your message as a locked door.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Your shared passphrase is the key.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Before the door opens, the lock has to turn many times.',
            ),
            const SizedBox(height: 12),
            const Text(
              'More turns make it harder for someone to keep guessing '
              'the key.',
            ),
            const SizedBox(height: 12),
            const Text(
              'But more turns also make the phone work harder.',
            ),
            const SizedBox(height: 12),
            const Text(
              "The other person's phone has to do the same work too, "
              'so a very strong setting may be slow on an older phone.',
            ),
            const SizedBox(height: 32),
            Text(
              'The three protection levels',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ProtectionLevelCard(
              title: ProtectionLevel.compatibility.title,
              turns: ProtectionLevel.compatibility.iterations,
              description:
                  'Fewer turns. Faster, especially on older phones.',
            ),
            const SizedBox(height: 12),
            _ProtectionLevelCard(
              title: ProtectionLevel.balanced.title,
              turns: ProtectionLevel.balanced.iterations,
              description:
                  'More work for guessing, with a moderate phone workload.',
            ),
            const SizedBox(height: 12),
            _ProtectionLevelCard(
              title: ProtectionLevel.stronger.title,
              turns: ProtectionLevel.stronger.iterations,
              description:
                  'Many more turns. Harder to guess repeatedly, but slower '
                  'on some phones.',
            ),
            const SizedBox(height: 32),
            Text(
              'Which level fits this device?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Veilmi can measure how long each level takes on this phone '
              'and suggest one that should feel practical.',
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isRunning ? null : _checkDevice,
              icon: _isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.speed_outlined),
              label: Text(
                _isRunning
                    ? 'Checking...'
                    : 'Check This Device',
              ),
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

class _ProtectionLevelCard extends StatelessWidget {
  const _ProtectionLevelCard({
    required this.title,
    required this.turns,
    required this.description,
  });

  final String title;
  final int turns;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${_formatNumber(turns)} turns',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
  }
}