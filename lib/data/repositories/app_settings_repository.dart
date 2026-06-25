import 'package:shared_preferences/shared_preferences.dart';

const String _useMockDoeKey = 'use_mock_doe';

/// User preferences: mock DoE toggle (Stage 6).
class AppSettingsRepository {
  AppSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Default true — local in-app Mock DoE requires no network.
  bool get useMockDoe => _prefs.getBool(_useMockDoeKey) ?? true;

  Future<void> setUseMockDoe(bool value) async {
    await _prefs.setBool(_useMockDoeKey, value);
  }
}
