import 'package:shared_preferences/shared_preferences.dart';

const String _useMockDoeKey = 'use_mock_doe';
const String _localeCodeKey = 'locale_code';

/// User preferences: mock DoE toggle, locale override (Stage 6).
class AppSettingsRepository {
  AppSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Default true — local in-app Mock DoE requires no network.
  bool get useMockDoe => _prefs.getBool(_useMockDoeKey) ?? true;

  String? get localeCode {
    final code = _prefs.getString(_localeCodeKey);
    if (code == null || code.isEmpty) {
      return null;
    }
    return code;
  }

  Future<void> setUseMockDoe(bool value) async {
    await _prefs.setBool(_useMockDoeKey, value);
  }

  Future<void> setLocaleCode(String? code) async {
    if (code == null || code.isEmpty) {
      await _prefs.remove(_localeCodeKey);
    } else {
      await _prefs.setString(_localeCodeKey, code);
    }
  }
}
