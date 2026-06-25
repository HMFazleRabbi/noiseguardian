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
}
