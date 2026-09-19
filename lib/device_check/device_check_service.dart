import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../crypto/protection_level.dart';

// This service measures how fast the current phone can run PBKDF2.
// PBKDF2 is the password-to-key process used in the app.
//
// The goal is simple:
// - measure how long each protection level takes on this device;
// - recommend the strongest level that should still feel practical.
//
// Benchmark results can naturally vary because phone temperature,
// CPU load, power-saving mode, and background activity may affect timing.
class DeviceCheckService extends ChangeNotifier {
  // Private constructor so this can be used as a singleton.
  DeviceCheckService._();

  // There is only one shared device-check service for the app.
  static final DeviceCheckService instance = DeviceCheckService._();

  // If a level takes longer than this, we treat it as too slow
  // for a good user experience.
  static const int recommendedMaxMilliseconds = 5000;

  // State flags for the running benchmark.
  bool _isRunning = false;
  bool _hasError = false;

  // Stores the PBKDF2 implementation name detected at runtime.
  String? _implementation;

  // Stores the final measured time for each protection level.
  final Map<ProtectionLevel, double> _times = {};

  // The final recommendation for this device.
  ProtectionLevel? _recommendation;

  // Tracks how many measured benchmark runs have finished.
  int _completedRuns = 0;

  // There are 9 measured runs:
  // 3 protection levels x 3 rounds.
  //
  // The warm-up run is not counted.
  static const int totalRuns = 9;

  // If a run is already in progress, reuse the same task
  // instead of starting another benchmark.
  Future<void>? _runningTask;

  bool get isRunning => _isRunning;
  bool get hasError => _hasError;
  String? get implementation => _implementation;
  ProtectionLevel? get recommendation => _recommendation;
  int get completedRuns => _completedRuns;

  // The benchmark is complete only when:
  // - it is no longer running;
  // - no error occurred;
  // - a recommendation exists;
  // - timing results are available.
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

  // Run one PBKDF2 operation and return its duration in milliseconds.
  Future<double> _measureLevel({
    required ProtectionLevel level,
    required SecretKey secretKey,
    required List<int> salt,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: level.iterations,
      bits: 256,
    );

    final stopwatch = Stopwatch()..start();

    await pbkdf2.deriveKey(secretKey: secretKey, nonce: salt);

    stopwatch.stop();

    // Keep sub-millisecond precision instead of rounding immediately
    // to a whole millisecond.
    return stopwatch.elapsedMicroseconds / 1000.0;
  }

  // Return the median value from three timing samples.
  //
  // Using the median makes one unusually slow or fast measurement
  // less likely to distort the final Device Check result.
  double _medianOfThree(List<double> values) {
    final sorted = List<double>.from(values)..sort();
    return sorted[1];
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
      // Create a PBKDF2 instance so we can record which implementation
      // the cryptography package is using on this device.
      final implementationCheck = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: ProtectionLevel.compatibility.iterations,
        bits: 256,
      );

      _implementation = implementationCheck.runtimeType.toString();

      // A fixed salt is fine for this benchmark because this is not
      // encrypting real user data.
      final salt = List<int>.generate(16, (index) => index);

      // A fixed passphrase used only for Device Check.
      const passphrase = 'veilmi-device-check';

      // Prepare the SecretKey before timing begins.
      final secretKey = SecretKey(passphrase.codeUnits);

      // ------------------------------------------------------------
      // Warm-up
      // ------------------------------------------------------------
      //
      // The first cryptographic operation can behave differently because
      // the runtime, library, or CPU may still be warming up.
      //
      // Run one small PBKDF2 operation first and do not count it.
      await _measureLevel(
        level: ProtectionLevel.compatibility,
        secretKey: secretKey,
        salt: salt,
      );

      // Store all three measured samples for every protection level.
      final samples = <ProtectionLevel, List<double>>{
        ProtectionLevel.compatibility: <double>[],
        ProtectionLevel.balanced: <double>[],
        ProtectionLevel.stronger: <double>[],
      };

      // ------------------------------------------------------------
      // Measured rounds
      // ------------------------------------------------------------
      //
      // Change the order in every round so no protection level is always
      // tested first or always tested last.
      //
      // Round 1:
      // Compatibility -> Balanced -> Stronger
      //
      // Round 2:
      // Balanced -> Stronger -> Compatibility
      //
      // Round 3:
      // Stronger -> Compatibility -> Balanced
      final rounds = <List<ProtectionLevel>>[
        [
          ProtectionLevel.compatibility,
          ProtectionLevel.balanced,
          ProtectionLevel.stronger,
        ],
        [
          ProtectionLevel.balanced,
          ProtectionLevel.stronger,
          ProtectionLevel.compatibility,
        ],
        [
          ProtectionLevel.stronger,
          ProtectionLevel.compatibility,
          ProtectionLevel.balanced,
        ],
      ];

      for (final round in rounds) {
        for (final level in round) {
          final milliseconds = await _measureLevel(
            level: level,
            secretKey: secretKey,
            salt: salt,
          );

          samples[level]!.add(milliseconds);

          _completedRuns++;
          notifyListeners();
        }
      }

      // ------------------------------------------------------------
      // Final timing results
      // ------------------------------------------------------------
      //
      // Each level now has three measurements.
      // Use the median rather than the average so one unusual run
      // has less influence on the displayed result.
      for (final level in ProtectionLevel.values) {
        final levelSamples = samples[level]!;

        _times[level] = _medianOfThree(levelSamples);
      }

      // ------------------------------------------------------------
      // Recommendation
      // ------------------------------------------------------------
      //
      // Prefer the strongest protection level that remains within
      // Veilmi's 5-second usability guideline.
      final strongerTime = _times[ProtectionLevel.stronger] ?? double.infinity;

      final balancedTime = _times[ProtectionLevel.balanced] ?? double.infinity;

      if (strongerTime <= recommendedMaxMilliseconds) {
        _recommendation = ProtectionLevel.stronger;
      } else if (balancedTime <= recommendedMaxMilliseconds) {
        _recommendation = ProtectionLevel.balanced;
      } else {
        _recommendation = ProtectionLevel.compatibility;
      }

      notifyListeners();
    } catch (error) {
      _hasError = true;

      if (kDebugMode) {
        debugPrint('Device Check failed: $error');
      }
    } finally {
      _isRunning = false;
      _runningTask = null;

      notifyListeners();
    }
  }
}
