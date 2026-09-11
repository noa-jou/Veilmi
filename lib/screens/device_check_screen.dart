import 'dart:async';

import 'package:flutter/material.dart';

import '../crypto/protection_level.dart';
import '../device_check/device_check_service.dart';
import '../l10n/app_localizations.dart';

// This screen helps the user decide which encryption strength level is best for this device.
// It is mainly a UI screen that explains the idea and then shows the benchmark result.
//
// In beginner terms:
// - test how fast the phone is,
// - compare the available security levels,
// - recommend the strongest level that still feels fast enough.
class DeviceCheckScreen extends StatelessWidget {
  const DeviceCheckScreen({super.key});

  // A shortcut to the app-wide device check service.
  DeviceCheckService get _service => DeviceCheckService.instance;

  // Start the benchmark without blocking the UI.
  // unawaited(...) means: "run this in the background and don't wait for it here".
  void _startCheck() {
    unawaited(_service.runCheck());
  }

  // Turn a ProtectionLevel enum into a readable localised string.
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

  // Format numbers like 600000 into 600,000 so they are easier to read in the UI.
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
    // This gets the correct language strings for the current app language.
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // The app bar at the top of the screen.
      appBar: AppBar(title: Text(l10n.deviceCheckTitle)),

      // AnimatedBuilder listens to the service state.
      // When the device benchmark changes, the UI updates automatically.
      body: AnimatedBuilder(
        animation: _service,
        builder: (context, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // This is the main intro section.
                Text(
                  l10n.whichLevelFits,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                Text(l10n.deviceCheckDescription),
                const SizedBox(height: 20),

                // A warning area that tells the user slower devices may need a weaker level.
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

                // This button starts the device benchmark.
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
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
                ),

                // While the benchmark runs, show progress information.
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

                // If the check fails, show an error message.
                if (_service.hasError) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.deviceCheckFailed,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],

                // If the benchmark is complete, show the result card.
                if (_service.hasResult) ...[
                  const SizedBox(height: 24),
                  _DeviceCheckResult(
                    service: _service,
                    l10n: l10n,
                    protectionTitle: _protectionTitle,
                  ),
                ],

                const SizedBox(height: 32),

                // A collapsible section explaining the idea behind protection levels.
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(
                      l10n.howProtectionWorks,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    initiallyExpanded: false,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Another collapsible section showing the three protection levels.
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    leading: const Icon(Icons.tune),
                    title: Text(
                      l10n.threeProtectionLevels,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    initiallyExpanded: false,
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: [
                      _ProtectionLevelCard(
                        title: l10n.compatibility,
                        turns: ProtectionLevel.compatibility.iterations,
                        turnsLabel: l10n.turns,
                        description: l10n.compatibilityDeviceDescription,
                        formatNumber: _formatNumber,
                      ),
                      const SizedBox(height: 8),
                      _ProtectionLevelCard(
                        title: l10n.balanced,
                        turns: ProtectionLevel.balanced.iterations,
                        turnsLabel: l10n.turns,
                        description: l10n.balancedDeviceDescription,
                        formatNumber: _formatNumber,
                      ),
                      const SizedBox(height: 8),
                      _ProtectionLevelCard(
                        title: l10n.stronger,
                        turns: ProtectionLevel.stronger.iterations,
                        turnsLabel: l10n.turns,
                        description: l10n.strongerDeviceDescription,
                        formatNumber: _formatNumber,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// This widget displays the measured device timings and the final recommendation.
// It is a small result box that reads better than a raw list of numbers.
class _DeviceCheckResult extends StatelessWidget {
  const _DeviceCheckResult({
    required this.service,
    required this.l10n,
    required this.protectionTitle,
  });

  final DeviceCheckService service;
  final AppLocalizations l10n;

  // Converts a protection level into a translated label, such as "Balanced".
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
          if (implementation != null) ...[
            SelectableText(l10n.pbkdf2Implementation(implementation)),
            const SizedBox(height: 16),
          ],

          // Show the measured time for each protection level.
          for (final level in ProtectionLevel.values) ...[
            if (service.timeFor(level) != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.protectionTime(
                    protectionTitle(l10n, level),
                    (service.timeFor(level)! / 1000).toStringAsFixed(1),
                  ),
                ),
              ),
          ],

          // Show the app's recommendation for this device.
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

// A reusable card showing one protection level and its iteration count.
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
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name of the protection level.
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),

            // The number of iterations in a readable format.
            Text(
              turnsLabel(formatNumber(turns)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),

            // A short description explaining what this level is for.
            Text(description),
          ],
        ),
      ),
    );
  }
}
