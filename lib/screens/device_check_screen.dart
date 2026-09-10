import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';
import '../l10n/app_localizations.dart';

// This screen helps the user test how fast their device is.
// It measures how long the app's password hashing takes,
// then recommends the safest protection level that still feels smooth on that phone.
class DeviceCheckScreen extends StatefulWidget {
  const DeviceCheckScreen({super.key});

  @override
  State<DeviceCheckScreen> createState() => _DeviceCheckScreenState();
}

class _DeviceCheckScreenState extends State<DeviceCheckScreen> {
  // We consider 5 seconds a good maximum delay for a recommended setting.
  // If a stronger option takes longer than this, it may be too slow for the device.
  static const int _recommendedMaxMilliseconds = 5000;

  // These variables track whether the check is currently running,
  // and what message/result should be shown on screen.
  bool _isRunning = false;
  String _result = '';

  // Convert a protection level enum into a readable string.
  // Example: ProtectionLevel.balanced -> "Balanced"
  String _protectionTitle(AppLocalizations l10n, ProtectionLevel level) {
    switch (level) {
      case ProtectionLevel.compatibility:
        return l10n.compatibility;
      case ProtectionLevel.balanced:
        return l10n.balanced;
      case ProtectionLevel.stronger:
        return l10n.stronger;
    }
  }

  // This method runs the actual benchmark.
  // It measures how long each protection setting takes to hash a password on this device.
  Future<void> _checkDevice() async {
    // If the check is already running, ignore extra taps.
    if (_isRunning) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    // Show a loading message while the benchmark runs.
    setState(() {
      _isRunning = true;
      _result = l10n.checkingDevice;
    });

    final buffer = StringBuffer();
    final times = <ProtectionLevel, double>{};

    try {
      // This creates a PBKDF2 object to confirm that the hashing implementation exists.
      // PBKDF2 is the system used to make passwords slower to brute-force.
      final implementationCheck = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: ProtectionLevel.compatibility.iterations,
        bits: 256,
      );

      buffer.writeln(
        l10n.pbkdf2Implementation(implementationCheck.runtimeType.toString()),
      );
      buffer.writeln();

      // Use a fixed passphrase and salt so each run is comparable.
      final salt = List<int>.generate(16, (index) => index);
      const passphrase = 'veilmi-device-check';

      // Measure all available protection levels one by one.
      for (final level in ProtectionLevel.values) {
        final runTimes = <int>[];

        // Run the hash 3 times and calculate the average.
        // This helps make the result more stable.
        for (var run = 0; run < 3; run++) {
          final pbkdf2 = Pbkdf2(
            macAlgorithm: Hmac.sha256(),
            iterations: level.iterations,
            bits: 256,
          );

          final stopwatch = Stopwatch()..start();

          // This is the expensive work we are timing.
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

        // Add a message like: "Balanced: 2.3 seconds"
        buffer.writeln(
          l10n.protectionTime(
            _protectionTitle(l10n, level),
            (averageMilliseconds / 1000).toStringAsFixed(1),
          ),
        );
      }

      // Find which settings are fast enough for this device.
      final strongerTime = times[ProtectionLevel.stronger] ?? double.infinity;
      final balancedTime = times[ProtectionLevel.balanced] ?? double.infinity;

      ProtectionLevel recommendation;

      // Choose the strongest level that is still under 5 seconds.
      if (strongerTime <= _recommendedMaxMilliseconds) {
        recommendation = ProtectionLevel.stronger;
      } else if (balancedTime <= _recommendedMaxMilliseconds) {
        recommendation = ProtectionLevel.balanced;
      } else {
        recommendation = ProtectionLevel.compatibility;
      }

      // Add the recommendation to the result text.
      buffer.writeln();
      buffer.writeln(l10n.recommendedForDevice);
      buffer.writeln(_protectionTitle(l10n, recommendation));

      if (!mounted) {
        return;
      }

      // Save the final result to display on the screen.
      setState(() {
        _result = buffer.toString().trim();
      });
    } catch (error) {
      // If something fails during the benchmark, display an error instead.
      if (!mounted) {
        return;
      }

      setState(() {
        _result = l10n.deviceCheckFailed;
      });
    } finally {
      // Always stop the loading spinner when the test ends.
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // The screen is a vertical stack of information.
    // Each section explains a concept, then shows the app's protection options.
    return Scaffold(
      appBar: AppBar(title: Text(l10n.deviceCheckTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explain the basic idea: more turns means more work for attackers.
            Text(
              l10n.howProtectionWorks,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(l10n.lockedDoor),
            const SizedBox(height: 12),
            Text(l10n.sharedPassphraseKey),
            const SizedBox(height: 12),
            Text(l10n.lockTurns),
            const SizedBox(height: 12),
            Text(l10n.moreTurnsHarderGuessing),
            const SizedBox(height: 12),
            Text(l10n.moreTurnsMoreWork),
            const SizedBox(height: 12),
            Text(l10n.otherPhoneSameWork),
            const SizedBox(height: 32),

            // Show the three available security levels.
            Text(
              l10n.threeProtectionLevels,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ProtectionLevelCard(
              title: l10n.compatibility,
              turns: ProtectionLevel.compatibility.iterations,
              turnsLabel: l10n.turns,
              description: l10n.compatibilityDeviceDescription,
            ),
            const SizedBox(height: 12),
            _ProtectionLevelCard(
              title: l10n.balanced,
              turns: ProtectionLevel.balanced.iterations,
              turnsLabel: l10n.turns,
              description: l10n.balancedDeviceDescription,
            ),
            const SizedBox(height: 12),
            _ProtectionLevelCard(
              title: l10n.stronger,
              turns: ProtectionLevel.stronger.iterations,
              turnsLabel: l10n.turns,
              description: l10n.strongerDeviceDescription,
            ),
            const SizedBox(height: 32),

            // Explain why the user should run the device benchmark.
            Text(
              l10n.whichLevelFits,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(l10n.deviceCheckDescription),
            const SizedBox(height: 20),

            // This button starts the benchmark.
            FilledButton.icon(
              onPressed: _isRunning ? null : _checkDevice,
              icon: _isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.speed_outlined),
              label: Text(_isRunning ? l10n.checking : l10n.checkThisDevice),
            ),

            // If the result is available, show it under the button.
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

// This helper widget makes the protection level cards reusable.
// Each card contains a title, the number of turns, and a short explanation.
class _ProtectionLevelCard extends StatelessWidget {
  const _ProtectionLevelCard({
    required this.title,
    required this.turns,
    required this.turnsLabel,
    required this.description,
  });

  final String title;
  final int turns;
  final String Function(String) turnsLabel;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              turnsLabel(_formatNumber(turns)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }

  // Format a large number with commas for readability.
  // Example: 1000000 becomes 1,000,000
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
