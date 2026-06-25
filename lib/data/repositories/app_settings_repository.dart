import 'package:shared_preferences/shared_preferences.dart';

/// User preferences (Stage 6 settings surface).
class AppSettingsRepository {
  AppSettingsRepository(this._prefs);

  final SharedPreferences _prefs;
}
