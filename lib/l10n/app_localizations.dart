import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'NoiseGuardian'**
  String get appTitle;

  /// Bottom navigation label for capture tab
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get navCapture;

  /// Bottom navigation label for history tab
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// Bottom navigation label for heatmap tab
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get navHeatmap;

  /// Bottom navigation label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title for the capture screen
  ///
  /// In en, this message translates to:
  /// **'Capture Evidence'**
  String get captureTitle;

  /// Title for the history screen
  ///
  /// In en, this message translates to:
  /// **'Evidence History'**
  String get historyTitle;

  /// Title for the heatmap screen
  ///
  /// In en, this message translates to:
  /// **'Noise Heatmap'**
  String get heatmapTitle;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for calibration wizard
  ///
  /// In en, this message translates to:
  /// **'Microphone Calibration'**
  String get calibrationTitle;

  /// Calibration wizard introduction
  ///
  /// In en, this message translates to:
  /// **'Play reference pink noise in a quiet space. The app measures your microphone response and stores a correction factor (Cd).'**
  String get calibrationIntro;

  /// Button to begin calibration
  ///
  /// In en, this message translates to:
  /// **'Start calibration'**
  String get calibrationStart;

  /// Button to close calibration wizard after success
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get calibrationDone;

  /// Button to restart calibration
  ///
  /// In en, this message translates to:
  /// **'Calibrate again'**
  String get calibrationRetry;

  /// Settings entry to open calibration wizard
  ///
  /// In en, this message translates to:
  /// **'Calibrate microphone'**
  String get calibrationOpen;

  /// Shows stored correction factor
  ///
  /// In en, this message translates to:
  /// **'Current Cd: {value} dB'**
  String calibrationCurrentCd(String value);

  /// Success message after calibration
  ///
  /// In en, this message translates to:
  /// **'Calibration saved. Cd = {value} dB'**
  String calibrationSuccess(String value);

  /// Button to start audio capture
  ///
  /// In en, this message translates to:
  /// **'Record evidence'**
  String get captureRecord;

  /// Displayed A-weighted level
  ///
  /// In en, this message translates to:
  /// **'LAeq: {value} dB(A)'**
  String captureLaeq(String value);

  /// Classification result label
  ///
  /// In en, this message translates to:
  /// **'Class: {label}'**
  String captureClassLabel(String label);

  /// Classification confidence percentage
  ///
  /// In en, this message translates to:
  /// **'Confidence: {value}%'**
  String captureConfidence(String value);

  /// Shown while capture is in progress
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get captureRecording;

  /// Semantic label for LAeq color meter
  ///
  /// In en, this message translates to:
  /// **'LAeq level meter'**
  String get captureLaeqMeterLabel;

  /// Guard state OK message
  ///
  /// In en, this message translates to:
  /// **'Ready to capture — hold phone upright at ~1.5 m.'**
  String get guardOk;

  /// Guard state muffled message
  ///
  /// In en, this message translates to:
  /// **'Device appears muffled — uncover the microphone.'**
  String get guardMuffled;

  /// Guard state pocketed message
  ///
  /// In en, this message translates to:
  /// **'Phone appears pocketed — remove and hold upright.'**
  String get guardPocketed;

  /// Guard state obscured message
  ///
  /// In en, this message translates to:
  /// **'Excessive handling detected — hold steady.'**
  String get guardObscured;

  /// TTS when guard state is OK
  ///
  /// In en, this message translates to:
  /// **'Ready to capture. Hold phone upright.'**
  String get voicePromptReady;

  /// TTS when device is muffled
  ///
  /// In en, this message translates to:
  /// **'Uncover the microphone to continue.'**
  String get voicePromptMuffled;

  /// TTS when phone is pocketed
  ///
  /// In en, this message translates to:
  /// **'Remove phone from pocket.'**
  String get voicePromptPocketed;

  /// TTS when handling is excessive
  ///
  /// In en, this message translates to:
  /// **'Hold the phone steady.'**
  String get voicePromptObscured;

  /// TTS after successful capture
  ///
  /// In en, this message translates to:
  /// **'Evidence captured successfully.'**
  String get voicePromptCaptureComplete;

  /// Onboarding screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to NoiseGuardian'**
  String get onboardingTitle;

  /// Accessibility label for onboarding icon
  ///
  /// In en, this message translates to:
  /// **'NoiseGuardian logo'**
  String get onboardingIconLabel;

  /// Onboarding consent introduction
  ///
  /// In en, this message translates to:
  /// **'Before you begin, please review how NoiseGuardian handles your data under Bangladesh\'\'s Personal Data Protection Ordinance (PDPO) 2025.'**
  String get onboardingConsentIntro;

  /// Onboarding audio purge policy
  ///
  /// In en, this message translates to:
  /// **'Audio purge: Raw audio is deleted immediately after feature extraction. Only signed evidence packets (LAeq, class, obfuscated location) are retained locally.'**
  String get onboardingPurgePolicy;

  /// Onboarding PDPO rights
  ///
  /// In en, this message translates to:
  /// **'Your rights: You may request access, correction, or deletion of your submitted evidence via the DoE portal. You may withdraw consent in Settings.'**
  String get onboardingPdpoRights;

  /// Onboarding data use statement
  ///
  /// In en, this message translates to:
  /// **'Data use: Evidence is synced to the Department of Environment for enforcement. GPS coordinates are obfuscated to ~100 m before leaving your device.'**
  String get onboardingDataUse;

  /// Consent agree button
  ///
  /// In en, this message translates to:
  /// **'I agree — start capturing'**
  String get onboardingAgree;

  /// Consent decline button
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get onboardingDecline;

  /// History sync button label
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get historySync;

  /// History empty state
  ///
  /// In en, this message translates to:
  /// **'No evidence queued yet.'**
  String get historyEmpty;

  /// Export evidence as PDF
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get historyExportPdf;

  /// History list LAeq subtitle
  ///
  /// In en, this message translates to:
  /// **'LAeq {value} dB(A)'**
  String historyLaeqSubtitle(String value);

  /// Queue status pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Queue status syncing
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get statusSyncing;

  /// Queue status synced
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statusSynced;

  /// Queue status failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// Heatmap empty state
  ///
  /// In en, this message translates to:
  /// **'No synced evidence for heatmap yet.'**
  String get heatmapEmpty;

  /// Heatmap map colour legend
  ///
  /// In en, this message translates to:
  /// **'Green: below limit · Amber: elevated · Red: high'**
  String get heatmapMapLegend;

  /// Cell sample count
  ///
  /// In en, this message translates to:
  /// **'n={count}'**
  String heatmapCellCount(int count);

  /// Cell average LAeq
  ///
  /// In en, this message translates to:
  /// **'avg {value} dB'**
  String heatmapCellAvg(String value);

  /// Cell max LAeq
  ///
  /// In en, this message translates to:
  /// **'max {value} dB'**
  String heatmapCellMax(String value);

  /// Cell violation count
  ///
  /// In en, this message translates to:
  /// **'violations {count}'**
  String heatmapCellViolations(int count);

  /// Low-data toggle label
  ///
  /// In en, this message translates to:
  /// **'Low-data mode (WiFi-only sync)'**
  String get settingsLowDataMode;

  /// Low-data toggle hint
  ///
  /// In en, this message translates to:
  /// **'Blocks sync on mobile data to save bandwidth.'**
  String get settingsLowDataHint;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// Bengali language option
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get settingsLanguageBn;

  /// Read-only mock DoE indicator
  ///
  /// In en, this message translates to:
  /// **'Using local Mock DoE (offline sync)'**
  String get settingsMockDoeStatus;

  /// Export last synced evidence PDF
  ///
  /// In en, this message translates to:
  /// **'Export last synced PDF'**
  String get settingsExportLastPdf;

  /// Snackbar when no synced evidence
  ///
  /// In en, this message translates to:
  /// **'No synced evidence to export.'**
  String get settingsNoSyncedEvidence;

  /// Debug log section title
  ///
  /// In en, this message translates to:
  /// **'Debug log (live)'**
  String get settingsDebugLog;

  /// Copy log path button
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get settingsCopyPath;

  /// Clear debug log button
  ///
  /// In en, this message translates to:
  /// **'Clear log'**
  String get settingsClearLog;

  /// Refresh debug log button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get settingsRefreshLog;

  /// Snackbar after copying log path
  ///
  /// In en, this message translates to:
  /// **'Log file path copied'**
  String get settingsLogPathCopied;

  /// Empty debug log panel
  ///
  /// In en, this message translates to:
  /// **'No log lines yet'**
  String get settingsNoLogLines;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
