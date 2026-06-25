/// English UI strings (replaces generated l10n after MVP Stage 3 descope).
abstract final class AppStrings {
  static const appTitle = 'NoiseGuardian';

  // Navigation
  static const navCapture = 'Capture';
  static const navHistory = 'History';
  static const navSettings = 'Settings';

  // Capture
  static const captureTitle = 'Capture Evidence';
  static const captureRecord = 'Record evidence';
  static const captureRecording = 'Recording…';
  static const captureLaeqMeterLabel = 'LAeq level meter';

  static String captureLaeq(String value) => 'LAeq: $value dB(A)';
  static String captureClassLabel(String label) => 'Class: $label';
  static String captureConfidence(String value) => 'Confidence: $value%';

  // Guard advisory
  static const guardOk = 'Ready to capture — hold phone upright at ~1.5 m.';
  static const guardUnsteady = 'Excessive handling detected — hold steady.';

  // Calibration
  static const calibrationTitle = 'Microphone Calibration';
  static const calibrationIntro =
      'Play reference pink noise in a quiet space. The app measures your microphone response and stores a correction factor (Cd).';
  static const calibrationStart = 'Start calibration';
  static const calibrationDone = 'Done';
  static const calibrationRetry = 'Calibrate again';
  static const calibrationOpen = 'Calibrate microphone';

  static String calibrationCurrentCd(String value) => 'Current Cd: $value dB';
  static String calibrationSuccess(String value) =>
      'Calibration saved. Cd = $value dB';

  // Onboarding
  static const onboardingTitle = 'Welcome to NoiseGuardian';
  static const onboardingIconLabel = 'NoiseGuardian logo';
  static const onboardingConsentIntro =
      "Before you begin, please review how NoiseGuardian handles your data under Bangladesh's Personal Data Protection Ordinance (PDPO) 2025.";
  static const onboardingPurgePolicy =
      'Audio purge: Raw audio is deleted immediately after feature extraction. Only signed evidence packets (LAeq, class, obfuscated location) are retained locally.';
  static const onboardingPdpoRights =
      'Your rights: You may request access, correction, or deletion of your submitted evidence via the DoE portal. You may withdraw consent in Settings.';
  static const onboardingDataUse =
      'Data use: Evidence is synced to the Department of Environment for enforcement. GPS coordinates are obfuscated to ~100 m before leaving your device.';
  static const onboardingAgree = 'I agree — start capturing';
  static const onboardingDecline = 'Decline';

  // History
  static const historyTitle = 'Evidence History';
  static const historySync = 'Sync';
  static const historyEmpty = 'No evidence queued yet.';
  static const historyExportPdf = 'Export PDF';

  static String historyLaeqSubtitle(String value) => 'LAeq $value dB(A)';

  // Queue status
  static const statusPending = 'Pending';
  static const statusSyncing = 'Syncing';
  static const statusSynced = 'Synced';
  static const statusFailed = 'Failed';

  // Settings
  static const settingsTitle = 'Settings';
  static const settingsMockDoeStatus = 'Using local Mock DoE (offline sync)';
  static const settingsExportLastPdf = 'Export last synced PDF';
  static const settingsNoSyncedEvidence = 'No synced evidence to export.';
  static const settingsDebugLog = 'Debug log (live)';
  static const settingsCopyPath = 'Copy path';
  static const settingsClearLog = 'Clear log';
  static const settingsRefreshLog = 'Refresh';
  static const settingsLogPathCopied = 'Log file path copied';
  static const settingsNoLogLines = 'No log lines yet';
}
