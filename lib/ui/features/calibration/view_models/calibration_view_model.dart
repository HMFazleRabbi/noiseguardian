import 'package:flutter/material.dart';
import 'package:noise_guardian/core/logging/app_log.dart';
import 'package:noise_guardian/data/services/calibration_service.dart';
import 'package:noise_guardian/di/service_locator.dart';

enum CalibrationWizardStep { intro, playing, result }

class CalibrationViewModel extends ChangeNotifier {
  CalibrationViewModel({CalibrationService? calibrationService})
      : _service = calibrationService ?? getIt<CalibrationService>();

  final CalibrationService _service;

  CalibrationWizardStep _step = CalibrationWizardStep.intro;
  bool _busy = false;
  double? _savedCd;
  String? _errorMessage;

  CalibrationWizardStep get step => _step;
  bool get busy => _busy;
  double? get savedCd => _savedCd;
  String? get errorMessage => _errorMessage;

  Future<void> loadExisting() async {
    _savedCd = await _service.getCorrectionFactor();
    notifyListeners();
  }

  Future<void> startCalibration() async {
    _busy = true;
    _errorMessage = null;
    _step = CalibrationWizardStep.playing;
    notifyListeners();

    try {
      final service = _service;
      if (service is CalibrationServiceImpl) {
        final hasPermission = await service.hasMicrophonePermission();
        if (!hasPermission) {
          throw StateError('Microphone permission required for calibration');
        }
      }

      await _service.playReferencePinkNoise();
      await appLogInfo('calibration', 'Wizard started pink-noise playback');

      await Future<void>.delayed(const Duration(seconds: 2));

      // Stage 2: simulated power ratio until live capture wiring in Stage 3.
      const pMeasured = 0.63;
      const pRef = 1.0;
      _savedCd = await _service.saveCalibrationFromPowers(
        lRef: CalibrationServiceImpl.defaultLRef,
        pMeasured: pMeasured,
        pRef: pRef,
      );
      _step = CalibrationWizardStep.result;
    } catch (error, stack) {
      _errorMessage = error.toString();
      _step = CalibrationWizardStep.intro;
      await appLogError(
        'calibration',
        'Wizard failed',
        error: error,
        stackTrace: stack,
      );
    } finally {
      await _service.stopReferencePinkNoise();
      _busy = false;
      notifyListeners();
    }
  }

  void reset() {
    _step = CalibrationWizardStep.intro;
    _errorMessage = null;
    notifyListeners();
  }
}
