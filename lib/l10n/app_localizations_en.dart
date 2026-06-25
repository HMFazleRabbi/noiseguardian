// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NoiseGuardian';

  @override
  String get navCapture => 'Capture';

  @override
  String get navHistory => 'History';

  @override
  String get navHeatmap => 'Heatmap';

  @override
  String get navSettings => 'Settings';

  @override
  String get captureTitle => 'Capture Evidence';

  @override
  String get historyTitle => 'Evidence History';

  @override
  String get heatmapTitle => 'Noise Heatmap';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get calibrationTitle => 'Microphone Calibration';

  @override
  String get calibrationIntro =>
      'Play reference pink noise in a quiet space. The app measures your microphone response and stores a correction factor (Cd).';

  @override
  String get calibrationStart => 'Start calibration';

  @override
  String get calibrationDone => 'Done';

  @override
  String get calibrationRetry => 'Calibrate again';

  @override
  String get calibrationOpen => 'Calibrate microphone';

  @override
  String calibrationCurrentCd(String value) {
    return 'Current Cd: $value dB';
  }

  @override
  String calibrationSuccess(String value) {
    return 'Calibration saved. Cd = $value dB';
  }

  @override
  String get captureRecord => 'Record evidence';

  @override
  String captureLaeq(String value) {
    return 'LAeq: $value dB(A)';
  }

  @override
  String captureClassLabel(String label) {
    return 'Class: $label';
  }

  @override
  String captureConfidence(String value) {
    return 'Confidence: $value%';
  }

  @override
  String get guardOk => 'Ready to capture — hold phone upright at ~1.5 m.';

  @override
  String get guardMuffled => 'Device appears muffled — uncover the microphone.';

  @override
  String get guardPocketed =>
      'Phone appears pocketed — remove and hold upright.';

  @override
  String get guardObscured => 'Excessive handling detected — hold steady.';
}
