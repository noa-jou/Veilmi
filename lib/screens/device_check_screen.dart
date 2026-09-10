import 'dart:async';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';
import '../l10n/app_localizations.dart';

class DeviceCheckScreen extends StatefulWidget {
  const DeviceCheckScreen({super.key});

  @override
  State<DeviceCheckScreen> createState() => _DeviceCheckScreenState();
}

class _DeviceCheckScreenState extends State<DeviceCheckScreen> {
  static const int _recommendedMaxMilliseconds = 5000;

  bool _isRunning = false;
  String _result = '';

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

  Future<void> _checkDevice() async {
    if (_isRunning) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isRunning = true;
      _result = l10n.checkingDevice;
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
        l10n.pbkdf2Implementation(implementationCheck.runtimeType.toString()),
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
          l10n.protectionTime(
            _protectionTitle(l10n, level),
            (averageMilliseconds / 1000).toStringAsFixed(1),
          ),
        );
      }

      final strongerTime = times[ProtectionLevel.stronger] ?? double.infinity;
      final balancedTime = times[ProtectionLevel.balanced] ?? double.infinity;

      ProtectionLevel recommendation;

      if (strongerTime <= _recommendedMaxMilliseconds) {
        recommendation = ProtectionLevel.stronger;
      } else if (balancedTime <= _recommendedMaxMilliseconds) {
        recommendation = ProtectionLevel.balanced;
      } else {
        recommendation = ProtectionLevel.compatibility;
      }

      buffer.writeln();
      buffer.writeln(l10n.recommendedForDevice);
      buffer.writeln(_protectionTitle(l10n, recommendation));

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
        _result = l10n.deviceCheckFailed;
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deviceCheckTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              l10n.whichLevelFits,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(l10n.deviceCheckDescription),
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
              label: Text(_isRunning ? l10n.checking : l10n.checkThisDevice),
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
