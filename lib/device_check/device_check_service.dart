import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../crypto/protection_level.dart';

// This service measures how fast the current phone can run PBKDF2.
// PBKDF2 is the password-to-key process used in the app.
//
// The goal is simple:
// - if a security level is too slow on this device,
// - the app can recommend a lower level so the app still feels usable.
class DeviceCheckService extends ChangeNotifier {
  // Private constructor so this can be used as a singleton.
  DeviceCheckService._();

  // There is only one shared device-check service for the app.
  static final DeviceCheckService instance = DeviceCheckService._();

  // If a level takes longer than this, we treat it as too slow for a good user experience.
  static const int recommendedMaxMilliseconds = 5000;

  // State flags for the running benchmark.
  bool _isRunning = false;
  bool _hasError = false;

  // Stores the PBKDF2 implementation name detected at runtime.
  // Example: the library may report the actual implementation type.
  String? _implementation;

  // Stores the time each protection level took on this device.
  final Map<ProtectionLevel, double> _times = {};

  // This is the final recommendation: the best level for this device.
  ProtectionLevel? _recommendation;

  // Tracks how many benchmark runs have finished so far.
  int _completedRuns = 0;

  // There are 9 total runs:
  // 3 levels x 3 timing checks each = 9
  static const int totalRuns = 9;

  // If a run is already in progress, we reuse the same task instead of starting a new one.
  Future<void>? _runningTask;

  bool get isRunning => _isRunning;
  bool get hasError => _hasError;
  String? get implementation => _implementation;
  ProtectionLevel? get recommendation => _recommendation;
  int get completedRuns => _completedRuns;

  // The benchmark is considered complete only when:
  // - it is no longer running,
  // - no error occurred,
  // - a recommendation exists,
  // - and at least one timing result is available.
  bool get hasResult =>
      !_isRunning && !_hasError && _recommendation != null && _times.isNotEmpty;

  // Return the measured time for one protection level.
  double? timeFor(ProtectionLevel level) {
    return _times[level];
  }

  // Start the benchmark if there is not already one running.
  Future<void> runCheck() {
    if (_runningTask != null) {
      return _runningTask!;
    }

    _runningTask = _runCheck();

    return _runningTask!;
  }

  // This is the actual benchmark logic.
  Future<void> _runCheck() async {
    // Reset all state before starting a new check.
    _isRunning = true;
    _hasError = false;
    _implementation = null;
    _recommendation = null;
    _times.clear();
    _completedRuns = 0;

    notifyListeners();

    try {
      // Create a PBKDF2 instance with a low iteration count first.
      // This is mainly used to check which implementation the library is using.
      final implementationCheck = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: ProtectionLevel.compatibility.iterations,
        bits: 256,
      );

      _implementation = implementationCheck.runtimeType.toString();

      // A fixed salt is used for each timing test.
      // The value is not secret for this benchmark; it is just a constant input.
      final salt = List<int>.generate(16, (index) => index);

      // A simple passphrase string used for the benchmark only.
      const passphrase = 'veilmi-device-check';

      // Test each protection level one by one.
      for (final level in ProtectionLevel.values) {
        final runTimes = <int>[];

        // Run the timer 3 times and average the result.
        for (var run = 0; run < 3; run++) {
          final pbkdf2 = Pbkdf2(
            macAlgorithm: Hmac.sha256(),
            iterations: level.iterations,
            bits: 256,
          );

          final stopwatch = Stopwatch()..start();

          // This is the actual expensive work.
          // PBKDF2 derives a key from the passphrase and salt.
          await pbkdf2.deriveKey(
            secretKey: SecretKey(passphrase.codeUnits),
            nonce: salt,
          );

          stopwatch.stop();

          // Store how long this one run took.
          runTimes.add(stopwatch.elapsedMilliseconds);

          _completedRuns++;
          notifyListeners();
        }

        // Average the three measurements to reduce random noise.
        final averageMilliseconds =
            runTimes.reduce((a, b) => a + b) / runTimes.length;

        _times[level] = averageMilliseconds;
        notifyListeners();
      }

      // Choose the best protection level for this device.
      // We prefer the strongest option that is still under 5 seconds.
      final strongerTime = _times[ProtectionLevel.stronger] ?? double.infinity;
      final balancedTime = _times[ProtectionLevel.balanced] ?? double.infinity;

      if (strongerTime <= recommendedMaxMilliseconds) {
        _recommendation = ProtectionLevel.stronger;
      } else if (balancedTime <= recommendedMaxMilliseconds) {
        _recommendation = ProtectionLevel.balanced;
      } else {
        _recommendation = ProtectionLevel.compatibility;
      }
    } catch (error) {
      // If anything fails during the benchmark, mark it as an error.
      _hasError = true;
    } finally {
      _isRunning = false;
      _runningTask = null;

      notifyListeners();
    }
  }
}
