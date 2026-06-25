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
  String get captureRecording => 'Recording…';

  @override
  String get captureLaeqMeterLabel => 'LAeq level meter';

  @override
  String get guardOk => 'Ready to capture — hold phone upright at ~1.5 m.';

  @override
  String get guardMuffled => 'Device appears muffled — uncover the microphone.';

  @override
  String get guardPocketed =>
      'Phone appears pocketed — remove and hold upright.';

  @override
  String get guardObscured => 'Excessive handling detected — hold steady.';

  @override
  String get voicePromptReady => 'Ready to capture. Hold phone upright.';

  @override
  String get voicePromptMuffled => 'Uncover the microphone to continue.';

  @override
  String get voicePromptPocketed => 'Remove phone from pocket.';

  @override
  String get voicePromptObscured => 'Hold the phone steady.';

  @override
  String get voicePromptCaptureComplete => 'Evidence captured successfully.';

  @override
  String get onboardingTitle => 'Welcome to NoiseGuardian';

  @override
  String get onboardingIconLabel => 'NoiseGuardian logo';

  @override
  String get onboardingConsentIntro =>
      'Before you begin, please review how NoiseGuardian handles your data under Bangladesh\'s Personal Data Protection Ordinance (PDPO) 2025.';

  @override
  String get onboardingPurgePolicy =>
      'Audio purge: Raw audio is deleted immediately after feature extraction. Only signed evidence packets (LAeq, class, obfuscated location) are retained locally.';

  @override
  String get onboardingPdpoRights =>
      'Your rights: You may request access, correction, or deletion of your submitted evidence via the DoE portal. You may withdraw consent in Settings.';

  @override
  String get onboardingDataUse =>
      'Data use: Evidence is synced to the Department of Environment for enforcement. GPS coordinates are obfuscated to ~100 m before leaving your device.';

  @override
  String get onboardingAgree => 'I agree — start capturing';

  @override
  String get onboardingDecline => 'Decline';

  @override
  String get historySync => 'Sync';

  @override
  String get historyEmpty => 'No evidence queued yet.';

  @override
  String get historyExportPdf => 'Export PDF';

  @override
  String historyLaeqSubtitle(String value) {
    return 'LAeq $value dB(A)';
  }

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSyncing => 'Syncing';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusFailed => 'Failed';

  @override
  String get heatmapEmpty => 'No synced evidence for heatmap yet.';

  @override
  String get heatmapMapLegend =>
      'Green: below limit · Amber: elevated · Red: high';

  @override
  String heatmapCellCount(int count) {
    return 'n=$count';
  }

  @override
  String heatmapCellAvg(String value) {
    return 'avg $value dB';
  }

  @override
  String heatmapCellMax(String value) {
    return 'max $value dB';
  }

  @override
  String heatmapCellViolations(int count) {
    return 'violations $count';
  }

  @override
  String get settingsLowDataMode => 'Low-data mode (WiFi-only sync)';

  @override
  String get settingsLowDataHint =>
      'Blocks sync on mobile data to save bandwidth.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageBn => 'বাংলা';

  @override
  String get settingsMockDoeStatus => 'Using local Mock DoE (offline sync)';

  @override
  String get settingsExportLastPdf => 'Export last synced PDF';

  @override
  String get settingsNoSyncedEvidence => 'No synced evidence to export.';

  @override
  String get settingsDebugLog => 'Debug log (live)';

  @override
  String get settingsCopyPath => 'Copy path';

  @override
  String get settingsClearLog => 'Clear log';

  @override
  String get settingsRefreshLog => 'Refresh';

  @override
  String get settingsLogPathCopied => 'Log file path copied';

  @override
  String get settingsNoLogLines => 'No log lines yet';
}
