import 'dart:async';

import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';
import '../device_check/device_check_service.dart';
import '../l10n/app_localizations.dart';

// This screen explains the app's protection settings.
// It is not the encryption logic itself.
// Instead, it helps the user understand:
// - why some security levels are slower,
// - how the device speed affects the recommendation,
// - and which level is best for this phone.
class DeviceCheckScreen extends StatelessWidget {
  const DeviceCheckScreen({super.key});

  // A shortcut to the singleton service that performs the device check.
  DeviceCheckService get _service => DeviceCheckService.instance;

  // Starts the benchmark in the background.
  // unawaited(...) means: "run this without waiting for it here".
  void _startCheck() {
    unawaited(_service.runCheck());
  }

  // Convert a protection level enum into a user-facing label.
  // For example: Compatibility, Balanced, Stronger.
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

  // Format a number like 600000 into 600,000 for display.
  // This makes large numbers easier to read in the UI.
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

  @override
  Widget build(BuildContext context) {
    // This gets the translated strings for the current app language.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // The screen title shown in the app bar.
      appBar: AppBar(title: Text(l10n.deviceCheckTitle)),

      // AnimatedBuilder listens to the service state.
      // When the device check changes state (running, finished, failed), the UI updates.
      body: AnimatedBuilder(
        animation: _service,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intro section: explains the idea of protection levels.
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

                // Shows the three available security levels.
                Text(
                  l10n.threeProtectionLevels,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Each card shows a level and its iteration count.
                _ProtectionLevelCard(
                  title: l10n.compatibility,
                  turns: ProtectionLevel.compatibility.iterations,
                  turnsLabel: l10n.turns,
                  description: l10n.compatibilityDeviceDescription,
                  formatNumber: _formatNumber,
                ),
                const SizedBox(height: 12),
                _ProtectionLevelCard(
                  title: l10n.balanced,
                  turns: ProtectionLevel.balanced.iterations,
                  turnsLabel: l10n.turns,
                  description: l10n.balancedDeviceDescription,
                  formatNumber: _formatNumber,
                ),
                const SizedBox(height: 12),
                _ProtectionLevelCard(
                  title: l10n.stronger,
                  turns: ProtectionLevel.stronger.iterations,
                  turnsLabel: l10n.turns,
                  description: l10n.strongerDeviceDescription,
                  formatNumber: _formatNumber,
                ),
                const SizedBox(height: 32),

                // Explain to the user when each protection level should be used.
                Text(
                  l10n.whichLevelFits,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(l10n.deviceCheckDescription),
                const SizedBox(height: 20),

                // A warning box telling the user that slower devices may need a lower level.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.schedule_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.deviceCheckWarning)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // This button triggers the actual benchmark.
                // If a check is already running, the button is disabled.
                FilledButton.icon(
                  onPressed: _service.isRunning ? null : _startCheck,
                  icon: _service.isRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.speed_outlined),
                  label: Text(
                    _service.isRunning ? l10n.checking : l10n.checkThisDevice,
                  ),
                ),

                // While the benchmark is running, show a progress bar.
                if (_service.isRunning) ...[
                  const SizedBox(height: 24),
                  LinearProgressIndicator(
                    value:
                        _service.completedRuns / DeviceCheckService.totalRuns,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.checking} '
                    '${_service.completedRuns}/'
                    '${DeviceCheckService.totalRuns}',
                  ),
                ],

                // If something goes wrong, show an error message.
                if (_service.hasError) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.deviceCheckFailed,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],

                // If the benchmark finished, display the recommendation result.
                if (_service.hasResult) ...[
                  const SizedBox(height: 24),
                  _DeviceCheckResult(
                    service: _service,
                    l10n: l10n,
                    protectionTitle: _protectionTitle,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// This widget shows the actual benchmark results.
// It displays how long each protection level took on this device,
// and then recommends the best option.
class _DeviceCheckResult extends StatelessWidget {
  const _DeviceCheckResult({
    required this.service,
    required this.l10n,
    required this.protectionTitle,
  });

  final DeviceCheckService service;
  final AppLocalizations l10n;

  // This function turns a ProtectionLevel enum into a proper translated label.
  final String Function(AppLocalizations, ProtectionLevel) protectionTitle;

  @override
  Widget build(BuildContext context) {
    final implementation = service.implementation;
    final recommendation = service.recommendation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If the system tells us which PBKDF2 implementation is being used,
          // show it to the user.
          if (implementation != null) ...[
            SelectableText(l10n.pbkdf2Implementation(implementation)),
            const SizedBox(height: 16),
          ],

          // Show the time measured for each protection level.
          for (final level in ProtectionLevel.values) ...[
            if (service.timeFor(level) != null)
              Text(
                l10n.protectionTime(
                  protectionTitle(l10n, level),
                  (service.timeFor(level)! / 1000).toStringAsFixed(1),
                ),
              ),
          ],

          // Show the recommended protection level for this device.
          if (recommendation != null) ...[
            const SizedBox(height: 20),
            Text(
              l10n.recommendedForDevice,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              protectionTitle(l10n, recommendation),
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}

// A simple card used to display one protection level and its iteration count.
class _ProtectionLevelCard extends StatelessWidget {
  const _ProtectionLevelCard({
    required this.title,
    required this.turns,
    required this.turnsLabel,
    required this.description,
    required this.formatNumber,
  });

  final String title;
  final int turns;
  final String Function(String) turnsLabel;
  final String description;
  final String Function(int) formatNumber;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The protection level name, like Compatibility or Stronger.
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),

            // Show the estimated iteration count in a readable format.
            Text(
              turnsLabel(formatNumber(turns)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            // Explain what this level means in plain language.
            Text(description),
          ],
        ),
      ),
    );
  }
}
